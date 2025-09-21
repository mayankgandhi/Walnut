//
//  DocumentFileManager.swift
//  Walnut
//
//  Created by Mayank Gandhi on 25/08/25.
//  Copyright © 2025 m. All rights reserved.
//

import Foundation
import os.log

// MARK: - File Manager Errors

enum DocumentFileManagerError: LocalizedError {
    case directoryCreationFailed(URL, Error)
    case fileNotFound(URL)
    case fileCopyFailed(Error)
    case fileWriteFailed(Error)
    case permissionDenied(URL)
    case insufficientStorage
    case invalidFileName(String)
    
    var errorDescription: String? {
        switch self {
        case .directoryCreationFailed(let url, _):
            return "Failed to create directory at \(url.path)"
        case .fileNotFound(let url):
            return "File not found at \(url.path)"
        case .fileCopyFailed:
            return "Failed to copy file to local storage"
        case .fileWriteFailed:
            return "Failed to write file data to local storage"
        case .permissionDenied(let url):
            return "Permission denied for accessing \(url.path)"
        case .insufficientStorage:
            return "Insufficient storage space available"
        case .invalidFileName(let name):
            return "Invalid file name: \(name)"
        }
    }
}



// MARK: - File Type Prefixes for Organization

enum HealthRecordFilePrefix: String, CaseIterable {
    case prescriptions = "RX_"
    case bloodReports = "LAB_"
    case otherDocuments = "DOC_"
}

/// Service responsible for managing secure local document storage at root level
/// File naming: {Prefix}{UniqueTimestamp}_{OriginalName}
/// Root directory: WalnutHealthRecords/{PrefixedFileName}
actor DocumentFileManager {
    
    private let fileManager = FileManager.default
    private let logger = Logger(subsystem: "com.walnut.app", category: "DocumentFileManager")
    
    // MARK: - Directory Management
    
    /// Base directory for all health records (root level)
    private var baseDirectory: URL {
        fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
            .appendingPathComponent("WalnutHealthRecords")
    }
    
    /// Ensures base directory exists
    private func ensureBaseDirectoryExists() throws {
        do {
            try fileManager.createDirectory(
                at: baseDirectory,
                withIntermediateDirectories: true,
                attributes: [
                    .posixPermissions: 0o700, // Owner read/write/execute only
                    .protectionKey: URLFileProtection.complete // Encrypt when device is locked
                ]
            )
            logger.info("Created base directory: \(self.baseDirectory.path)")
        } catch {
            logger
                .error(
                    "Failed to create base directory \(self.baseDirectory.path): \(error.localizedDescription)"
                )
            throw DocumentFileManagerError.directoryCreationFailed(baseDirectory, error)
        }
    }
    
    // MARK: - Public Methods
    
    /// Saves a document file locally with secure root-level storage
    /// - Parameters:
    ///   - sourceURL: Source file URL to copy from
    ///   - prefix: File prefix indicating document type
    ///   - customName: Optional custom name, otherwise uses source filename
    /// - Returns: Local file URL where the document was saved
    func saveDocument(
        from sourceURL: URL,
        prefix: HealthRecordFilePrefix,
        customName: String? = nil
    ) throws -> URL {
        
        logger.info("Saving document from \(sourceURL.path) with prefix: \(prefix.rawValue)")
        
        // Validate source file exists
        guard fileManager.fileExists(atPath: sourceURL.path) else {
            logger.info("Document Not Found: \(sourceURL.path)")
            throw DocumentFileManagerError.fileNotFound(sourceURL)
        }
        
        // Check available storage
        try checkStorageAvailability(for: sourceURL)
        
        // Ensure base directory exists
        try ensureBaseDirectoryExists()
        
        // Generate unique filename with prefix
        let originalName = customName ?? sourceURL.lastPathComponent
        let uniqueFileName = try generateUniqueFileName(
            baseName: originalName,
            prefix: prefix
        )
        
        let destinationURL = baseDirectory.appendingPathComponent(uniqueFileName)
        
        // Copy file with error handling
        do {
            try copyFile(from: sourceURL, to: destinationURL)
            logger.info("Successfully saved document to: \(destinationURL.path)")
            return destinationURL
        } catch {
            throw DocumentFileManagerError.fileCopyFailed(error)
        }
    }
    
    /// Saves document data directly to local storage
    /// - Parameters:
    ///   - data: Document data to save
    ///   - prefix: File prefix indicating document type
    ///   - fileName: Base file name with extension
    /// - Returns: Local file URL where the document was saved
    func saveDocument(
        data: Data,
        prefix: HealthRecordFilePrefix,
        fileName: String
    ) throws -> URL {
        
        logger.info("Saving \(data.count) bytes with prefix: \(prefix.rawValue), fileName: \(fileName)")
        
        // Validate filename
        guard !fileName.isEmpty else {
            throw DocumentFileManagerError.invalidFileName(fileName)
        }
        
        // Check storage availability
        try checkStorageAvailability(dataSize: data.count)
        
        // Ensure base directory exists
        try ensureBaseDirectoryExists()
        
        // Generate unique filename with prefix
        let uniqueFileName = try generateUniqueFileName(
            baseName: fileName,
            prefix: prefix
        )
        
        let destinationURL = baseDirectory.appendingPathComponent(uniqueFileName)
        
        // Write data with error handling
        do {
            try writeData(data, to: destinationURL)
            logger.info("Successfully wrote data to: \(destinationURL.path)")
            return destinationURL
        } catch {
            throw DocumentFileManagerError.fileWriteFailed(error)
        }
    }
    
    
    /// Checks if a file exists at the given URL
    func fileExists(at url: URL) -> Bool {
        return fileManager.fileExists(atPath: url.path)
    }
    
    /// Gets file size for a given URL
    func fileSize(at url: URL) throws -> Int64 {
        let attributes = try fileManager.attributesOfItem(atPath: url.path)
        return attributes[.size] as? Int64 ?? 0
    }
    
    /// Resolves a stored filename to its full URL in the base directory
    /// - Parameter fileName: The filename stored in Document model
    /// - Returns: Full URL path to the file
    func resolveFileURL(from fileName: String) -> URL {
        return baseDirectory.appendingPathComponent(fileName)
    }
    
    
    // MARK: - Private Methods
    
    private func generateUniqueFileName(
        baseName: String,
        prefix: HealthRecordFilePrefix
    ) throws -> String {
        let sanitizedName = sanitizeFileName(baseName)
        let timestamp = Int(Date().timeIntervalSince1970)
        let randomSuffix = String(Int.random(in: 1000...9999))
        
        let nameWithoutExtension = URL(fileURLWithPath: sanitizedName).deletingPathExtension().lastPathComponent
        let fileExtension = URL(fileURLWithPath: sanitizedName).pathExtension
        
        let uniqueName = fileExtension.isEmpty 
            ? "\(prefix.rawValue)\(nameWithoutExtension)_\(timestamp)_\(randomSuffix)"
            : "\(prefix.rawValue)\(nameWithoutExtension)_\(timestamp)_\(randomSuffix).\(fileExtension)"
        
        // Ensure uniqueness by checking if file already exists in base directory
        var finalName = uniqueName
        var counter = 1
        
        while fileManager.fileExists(atPath: baseDirectory.appendingPathComponent(finalName).path) {
            finalName = fileExtension.isEmpty 
                ? "\(prefix.rawValue)\(nameWithoutExtension)_\(timestamp)_\(randomSuffix)_\(counter)"
                : "\(prefix.rawValue)\(nameWithoutExtension)_\(timestamp)_\(randomSuffix)_\(counter).\(fileExtension)"
            counter += 1
            
            // Prevent infinite loop
            if counter > 1000 {
                throw DocumentFileManagerError.invalidFileName("Unable to generate unique filename for: \(baseName)")
            }
        }
        
        return finalName
    }
    
    private func copyFile(from sourceURL: URL, to destinationURL: URL) throws {
        // Set secure attributes for the destination
        let attributes: [FileAttributeKey: Any] = [
            .posixPermissions: 0o600, // Owner read/write only
            .protectionKey: URLFileProtection.complete
        ]
        
        do {
            // Remove existing file if it exists
            if fileManager.fileExists(atPath: destinationURL.path) {
                try fileManager.removeItem(at: destinationURL)
            }
            
            // Copy the file
            try fileManager.copyItem(at: sourceURL, to: destinationURL)
            
            // Set secure attributes
            try fileManager.setAttributes(attributes, ofItemAtPath: destinationURL.path)
            
        } catch let error as NSError {
            if error.code == NSFileWriteFileExistsError || error.domain == NSCocoaErrorDomain {
                throw DocumentFileManagerError.fileCopyFailed(error)
            } else if error.code == NSFileWriteNoPermissionError {
                throw DocumentFileManagerError.permissionDenied(destinationURL)
            } else {
                throw DocumentFileManagerError.fileCopyFailed(error)
            }
        }
    }
    
    private func writeData(_ data: Data, to destinationURL: URL) throws {
        do {
            // Remove existing file if it exists
            if fileManager.fileExists(atPath: destinationURL.path) {
                try fileManager.removeItem(at: destinationURL)
            }
            
            // Write data with secure attributes
            try data.write(
                to: destinationURL,
                options: [.atomic, .completeFileProtection]
            )
            
            // Set secure permissions
            try fileManager.setAttributes(
                [.posixPermissions: 0o600],
                ofItemAtPath: destinationURL.path
            )
            
        } catch let error as NSError {
            if error.code == NSFileWriteNoPermissionError {
                throw DocumentFileManagerError.permissionDenied(destinationURL)
            } else if error.domain == NSPOSIXErrorDomain && error.code == ENOSPC {
                throw DocumentFileManagerError.insufficientStorage
            } else {
                throw DocumentFileManagerError.fileWriteFailed(error)
            }
        }
    }
    
    /// Sanitizes file/folder names to be safe for file system
    private func sanitizeFileName(_ name: String) -> String {
        let invalidCharacters = CharacterSet(charactersIn: ":/\\?%*|\"<>")
        let sanitized = name
            .components(separatedBy: invalidCharacters)
            .joined(separator: "_")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Ensure filename isn't empty after sanitization
        return sanitized.isEmpty ? "document" : sanitized
    }
    
    private func checkStorageAvailability(for fileURL: URL) throws {
        guard let fileSize = try? fileManager.attributesOfItem(atPath: fileURL.path)[.size] as? Int64 else {
            return // Can't determine size, proceed
        }
        
        try checkStorageAvailability(dataSize: Int(fileSize))
    }
    
    private func checkStorageAvailability(dataSize: Int) throws {
        guard let availableSpace = try? fileManager.attributesOfFileSystem(
            forPath: baseDirectory.path
        )[.systemFreeSize] as? Int64 else {
            return // Can't determine available space, proceed
        }
        
        // Require at least 10MB free space plus the file size
        let requiredSpace = Int64(dataSize) + (10 * 1024 * 1024)
        
        if availableSpace < requiredSpace {
            throw DocumentFileManagerError.insufficientStorage
        }
    }
    
}
