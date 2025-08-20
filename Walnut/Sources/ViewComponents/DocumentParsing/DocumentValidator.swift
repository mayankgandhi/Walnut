//
//  DocumentValidator.swift
//  Walnut
//
//  Created by Claude on 16/08/25.
//  Copyright © 2025 m. All rights reserved.
//

import Foundation
import UIKit

/// Service for validating document files and providing detailed error information
struct DocumentValidator {
    
    /// Result of document validation
    struct ValidationResult {
        let isValid: Bool
        let error: ValidationError?
        
        static let valid = ValidationResult(isValid: true, error: nil)
        
        static func invalid(_ error: ValidationError) -> ValidationResult {
            return ValidationResult(isValid: false, error: error)
        }
    }
    
    /// Possible validation errors
    enum ValidationError {
        case fileNotFound(path: String)
        case fileNotReadable
        case fileEmpty
        case fileCorrupted
        case unsupportedFormat(extension: String)
        case permissionDenied
        case unknownError(Error)
        
        var localizedDescription: String {
            switch self {
            case .fileNotFound(let path):
                return "Document not found. The file may have been moved or deleted.\n\nPath: \(path)"
            case .fileNotReadable:
                return "Cannot access document. The file may be corrupted or you may not have permission to read it."
            case .fileEmpty:
                return "Document appears to be empty or corrupted."
            case .fileCorrupted:
                return "The file appears to be corrupted and cannot be opened."
            case .unsupportedFormat(let ext):
                return "Document format (\(ext.uppercased())) is not supported for preview."
            case .permissionDenied:
                return "Permission denied. You don't have access to read this document."
            case .unknownError(let error):
                return "Cannot read document information: \(error.localizedDescription)"
            }
        }
        
        var title: String {
            switch self {
            case .fileNotFound:
                return "Document Not Found"
            case .fileNotReadable:
                return "Cannot Access Document"
            case .fileEmpty:
                return "Empty Document"
            case .fileCorrupted:
                return "Corrupted Document"
            case .unsupportedFormat:
                return "Unsupported Format"
            case .permissionDenied:
                return "Permission Denied"
            case .unknownError:
                return "Document Error"
            }
        }
        
        var systemImage: String {
            switch self {
            case .fileNotFound:
                return "doc.questionmark.fill"
            case .fileNotReadable, .permissionDenied:
                return "lock.doc.fill"
            case .fileEmpty, .fileCorrupted:
                return "doc.text.fill"
            case .unsupportedFormat:
                return "doc.badge.ellipsis"
            case .unknownError:
                return "exclamationmark.triangle.fill"
            }
        }
    }
    
    /// Validates a document at the given URL
    /// - Parameter document: The document to validate
    /// - Returns: ValidationResult indicating success or failure with detailed error
    static func validate(_ document: Document) -> ValidationResult {
        return validate(url: document.fileURL)
    }
    
    /// Validates a document at the given URL
    /// - Parameter url: The file URL to validate
    /// - Returns: ValidationResult indicating success or failure with detailed error
    static func validate(url: URL) -> ValidationResult {
        let fileManager = FileManager.default
        let path = url.path
        
        // Check if file exists
        guard fileManager.fileExists(atPath: path) else {
            return .invalid(.fileNotFound(path: path))
        }
        
        // Check if file is readable
        guard fileManager.isReadableFile(atPath: path) else {
            return .invalid(.fileNotReadable)
        }
        
        // Check file attributes and size
        do {
            let attributes = try fileManager.attributesOfItem(atPath: path)
            
            // Check file size
            if let fileSize = attributes[.size] as? Int64 {
                if fileSize == 0 {
                    return .invalid(.fileEmpty)
                }
                
                // Check for reasonable file size limits (e.g., 500MB)
                if fileSize > 500_000_000 {
                    return .invalid(.fileCorrupted)
                }
            }
            
            // Check file permissions
            if let posixPermissions = attributes[.posixPermissions] as? NSNumber {
                let permissions = posixPermissions.intValue
                let isReadable = (permissions & 0o444) != 0 // Check read permissions
                if !isReadable {
                    return .invalid(.permissionDenied)
                }
            }
            
        } catch {
            return .invalid(.unknownError(error))
        }
        
        // Validate based on file type
        let fileExtension = url.pathExtension.lowercased()
        return validateFileType(url: url, extension: fileExtension)
    }
    
    /// Validates specific file types
    private static func validateFileType(url: URL, extension: String) -> ValidationResult {
        switch `extension` {
        case "pdf":
            return validatePDF(url: url)
        case "jpg", "jpeg", "png", "heic", "heif", "gif", "webp":
            return validateImage(url: url)
        case "txt", "md":
            return validateTextFile(url: url)
        default:
            return .invalid(.unsupportedFormat(extension: `extension`))
        }
    }
    
    /// Validates PDF files by attempting to load them
    private static func validatePDF(url: URL) -> ValidationResult {
        // Try to read the first few bytes to check if it's a valid PDF
        do {
            let data = try Data(contentsOf: url, options: .mappedIfSafe)
            
            // Check PDF header
            if data.count >= 4 {
                let header = data.prefix(4)
                if String(data: header, encoding: .ascii) == "%PDF" {
                    return .valid
                }
            }
            
            return .invalid(.fileCorrupted)
        } catch {
            return .invalid(.unknownError(error))
        }
    }
    
    /// Validates image files
    private static func validateImage(url: URL) -> ValidationResult {
        do {
            let data = try Data(contentsOf: url)
            
            // Check if data can be loaded as an image
            if data.count >= 10 {
                // Basic check for common image headers
                let header = data.prefix(10)
                
                // JPEG
                if header.starts(with: [0xFF, 0xD8, 0xFF]) {
                    return .valid
                }
                
                // PNG
                if header.starts(with: [0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A]) {
                    return .valid
                }
                
                // GIF
                if header.starts(with: "GIF8".data(using: .ascii) ?? Data()) {
                    return .valid
                }
                
                // For other formats, just check if we can create UIImage
                #if canImport(UIKit)
                if UIImage(data: data) != nil {
                    return .valid
                }
                #endif
            }
            
            return .invalid(.fileCorrupted)
        } catch {
            return .invalid(.unknownError(error))
        }
    }
    
    /// Validates text files
    private static func validateTextFile(url: URL) -> ValidationResult {
        do {
            _ = try String(contentsOf: url, encoding: .utf8)
            return .valid
        } catch {
            // Try other encodings
            do {
                _ = try String(contentsOf: url, encoding: .ascii)
                return .valid
            } catch {
                return .invalid(.fileCorrupted)
            }
        }
    }
    
    /// Quick check if a file type is supported for viewing
    static func isFileTypeSupported(_ url: URL) -> Bool {
        let fileExtension = url.pathExtension.lowercased()
        let supportedTypes = ["pdf", "jpg", "jpeg", "png", "gif", "webp", "heic", "heif", "txt", "md"]
        return supportedTypes.contains(fileExtension)
    }
}
