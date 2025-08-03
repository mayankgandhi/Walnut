//
//  UnifiedDocumentParsingService.swift
//  Walnut
//
//  Created by Mayank Gandhi on 03/08/25.
//  Copyright © 2025 m. All rights reserved.
//

import Foundation

/// Unified service that routes document parsing to the appropriate service based on file type
final class UnifiedDocumentParsingService: ObservableObject {
    
    // MARK: - Dependencies
    
    private let openAIService: OpenAIDocumentService
    private let pdfParsingService: OpenAIPDFParsingService
    
    // MARK: - Initialization
    
    init(apiKey: String) {
        self.openAIService = OpenAIDocumentService(apiKey: apiKey)
        self.pdfParsingService = OpenAIPDFParsingService(apiKey: apiKey)
    }
    
    // MARK: - Document Parsing
    
    /// Parse any supported document type by routing to the appropriate service
    func parseDocument<T: Codable>(
        from url: URL,
        as type: T.Type
    ) async throws -> T {
        
        let fileExtension = url.pathExtension.lowercased()
        
        switch fileExtension {
        case "pdf":
            return try await pdfParsingService.parsePDFDocument(from: url, as: type)
        case "jpg", "jpeg", "png", "gif", "webp", "heic", "heif":
            return try await parseImageDocument(from: url, as: type)
        default:
            throw UnifiedParsingError.unsupportedFileType("File type '\(fileExtension)' is not supported. Supported types: PDF, JPEG, PNG, GIF, WebP, HEIC, HEIF")
        }
    }
    
    /// Parse image documents using OpenAI vision
    private func parseImageDocument<T: Codable>(
        from url: URL,
        as type: T.Type
    ) async throws -> T {
        let fileData = try Data(contentsOf: url)
        let fileName = url.lastPathComponent
        return try await openAIService.parseDocument(data: fileData, fileName: fileName, as: type)
    }
    
    // MARK: - Convenience Methods
    
    /// Parse a prescription document (supports both PDF and image formats)
    func parsePrescription(from url: URL) async throws -> ParsedPrescription {
        return try await parseDocument(from: url, as: ParsedPrescription.self)
    }
    
    /// Parse a blood report document (supports both PDF and image formats)
    func parseBloodReport(from url: URL) async throws -> ParsedBloodReport {
        return try await parseDocument(from: url, as: ParsedBloodReport.self)
    }
    
    // MARK: - File Type Support
    
    /// Check if a file type is supported for parsing
    func isFileTypeSupported(_ url: URL) -> Bool {
        let fileExtension = url.pathExtension.lowercased()
        let supportedTypes = ["pdf", "jpg", "jpeg", "png", "gif", "webp", "heic", "heif"]
        return supportedTypes.contains(fileExtension)
    }
    
    /// Get the parsing method that will be used for a file
    func getParsingMethod(for url: URL) -> ParsingMethod? {
        let fileExtension = url.pathExtension.lowercased()
        
        switch fileExtension {
        case "pdf":
            return .pdfFileUpload
        case "jpg", "jpeg", "png", "gif", "webp", "heic", "heif":
            return .directVision
        default:
            return nil
        }
    }
}

// MARK: - Supporting Types

enum ParsingMethod {
    case directVision
    case pdfFileUpload
    
    var description: String {
        switch self {
        case .directVision:
            return "Direct OpenAI Vision analysis"
        case .pdfFileUpload:
            return "PDF uploaded to OpenAI with file search and structured parsing"
        }
    }
}

enum UnifiedParsingError: Error, LocalizedError {
    case unsupportedFileType(String)
    
    var errorDescription: String? {
        switch self {
        case .unsupportedFileType(let message):
            return message
        }
    }
}