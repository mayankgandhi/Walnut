//
//  UnifiedDocumentParsingService.swift
//  AIKit
//
//  Created by Mayank Gandhi on 05/08/25.
//  Copyright © 2025 m. All rights reserved.
//

import Foundation

/// Unified service that routes document parsing to the appropriate service based on file type
public final class UnifiedDocumentParsingService: UnifiedParsingServiceProtocol, ObservableObject {
    
    // MARK: - Dependencies
    
    private let openAIService: OpenAIDocumentService
    
    // MARK: - Initialization
    
    public init(openAIAPIKey: String) {
        self.openAIService = OpenAIDocumentService(apiKey: openAIAPIKey)
    }
    
    // MARK: - AIDocumentServiceProtocol
    
    public func parseDocument<T: Codable>(data: Data, fileName: String, as type: T.Type) async throws -> T {
        return try await openAIService.parseDocument(data: data, fileName: fileName, as: type)
    }
    
    public func uploadAndParseDocument<T: Codable>(from url: URL, as type: T.Type, structDefinition: String?) async throws -> T {
        return try await parseDocument(from: url, as: type)
    }
    
    // MARK: - UnifiedParsingServiceProtocol
    
    /// Parse any supported document type by routing to the appropriate service
    public func parseDocument<T: Codable>(
        from url: URL,
        as type: T.Type
    ) async throws -> T {
        
        let fileExtension = url.pathExtension.lowercased()
        
        switch fileExtension {
        case "pdf":
            throw AIKitError.unsupportedFileType("PDF parsing requires specialized handling. Use a dedicated PDF parsing service.")
        case "jpg", "jpeg", "png", "gif", "webp", "heic", "heif":
            return try await parseImageDocument(from: url, as: type)
        default:
            throw AIKitError.unsupportedFileType("File type '\(fileExtension)' is not supported. Supported types: JPEG, PNG, GIF, WebP, HEIC, HEIF")
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
    
    /// Parse a prescription document (supports image formats)
    public func parsePrescription(from url: URL) async throws -> ParsedPrescription {
        return try await parseDocument(from: url, as: ParsedPrescription.self)
    }
    
    /// Parse a blood report document (supports image formats)
    public func parseBloodReport(from url: URL) async throws -> ParsedBloodReport {
        return try await parseDocument(from: url, as: ParsedBloodReport.self)
    }
    
    // MARK: - File Type Support
    
    /// Check if a file type is supported for parsing
    public func isFileTypeSupported(_ url: URL) -> Bool {
        let fileExtension = url.pathExtension.lowercased()
        let supportedTypes = ["jpg", "jpeg", "png", "gif", "webp", "heic", "heif"]
        return supportedTypes.contains(fileExtension)
    }
    
    /// Get the parsing method that will be used for a file
    public func getParsingMethod(for url: URL) -> ParsingMethod? {
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