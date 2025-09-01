//
//  DocumentFileManager.swift
//  Walnut
//
//  Created by Mayank Gandhi on 25/08/25.
//  Copyright © 2025 m. All rights reserved.
//

import Foundation

/// Service responsible for managing local document storage with organized folder structure
/// Folder structure: <Patient>/<MedicalCase>/<PrescriptionDate|BloodReportDate|UnparsedDocument>
struct DocumentFileManager {
    
    private let fileManager = FileManager.default
    
    /// Base directory for all patient documents
    private var documentsDirectory: URL {
        fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
            .appendingPathComponent("WalnutMedicalRecords")
    }
    
    // MARK: - Public Methods
    
    /// Saves a document file locally with the organized folder structure
    /// - Parameters:
    ///   - sourceURL: Source file URL to copy from
    ///   - date: Date for file naming (prescription date, blood report date, or current date for unparsed)
    ///   - fileName: Original file name
    /// - Returns: Local file URL where the document was saved
    func saveDocument(
        from sourceURL: URL,
        date: Date = Date(),
    ) throws -> URL {
        // Generate unique file name with date
        let fileName = sourceURL.lastPathComponent
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd_HH-mm-ss"
        let dateString = dateFormatter.string(from: date)
        
        let sanitizedFileName = sanitizeFileName(fileName)
        let destinationURL = documentsDirectory.appendingPathComponent(sanitizedFileName)
        
        // Copy file to destination
        try copyFile(from: sourceURL, to: destinationURL)
        
        return destinationURL
    }
    
    /// Saves document data directly to local storage with organized folder structure
    /// - Parameters:
    ///   - data: Document data to save
    ///   - date: Date for file naming (prescription date, blood report date, or current date for unparsed)
    ///   - fileName: File name with extension
    /// - Returns: Local file URL where the document was saved
    func saveDocument(
        data: Data,
        date: Date,
        fileName: String
    ) throws -> URL {
        
        // Generate unique file name with date
        let fileExtension = URL(fileURLWithPath: fileName).pathExtension
        
        let sanitizedFileName = sanitizeFileName(fileName)
        let finalFileName = fileExtension.isEmpty ? 
            "\(sanitizedFileName)" :
            "\(sanitizedFileName).\(fileExtension)"
        let destinationURL = documentsDirectory.appendingPathComponent(finalFileName)
        
        // Write data to destination
        try writeData(data, to: destinationURL)
        
        return destinationURL
    }
    
    /// Saves an unparsed document when parsing fails
    /// - Parameters:
    ///   - sourceURL: Source file URL to copy from
    ///   - fileName: Original file name
    /// - Returns: Local file URL where the document was saved
    func saveUnparsedDocument(
        from sourceURL: URL,
    ) throws -> URL {
        return try saveDocument(
            from: sourceURL,
            date: Date(),
        )
    }
    
    /// Checks if a file exists at the given URL
    func fileExists(at url: URL) -> Bool {
        return fileManager.fileExists(atPath: url.path)
    }
    
    // MARK: - Private Methods
    
   
    private func copyFile(from sourceURL: URL, to destinationURL: URL) throws {
        // Remove existing file if it exists
        guard fileManager.fileExists(atPath: sourceURL.path()) else {
            throw NSError(domain: "1234", code: 1234)
        }
        
        if fileManager.fileExists(atPath: destinationURL.path) {
            try fileManager.removeItem(at: destinationURL)
        }
        
        // Copy the file
        try fileManager.copyItem(at: sourceURL, to: destinationURL)
    }
    
    private func writeData(_ data: Data, to destinationURL: URL) throws {
        // Remove existing file if it exists
        if fileManager.fileExists(atPath: destinationURL.path) {
            try fileManager.removeItem(at: destinationURL)
        }
        
        // Write the data
        try data.write(to: destinationURL)
    }
    
    /// Sanitizes file/folder names to be safe for file system
    private func sanitizeFileName(_ name: String) -> String {
        let invalidCharacters = CharacterSet(charactersIn: ":/\\?%*|\"<>")
        return name
            .components(separatedBy: invalidCharacters)
            .joined(separator: "_")
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
