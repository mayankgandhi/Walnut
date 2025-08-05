//
//  UnifiedDocumentParsingService.swift
//  AIKit
//
//  Created by Mayank Gandhi on 05/08/25.
//  Copyright © 2025 m. All rights reserved.
//

import Foundation

/// Unified service that routes document parsing to the appropriate service based on file type
public final class UnifiedDocumentParsingService: AIDocumentServiceProtocol, ObservableObject {

    // MARK: - Dependencies
    
    private let openAIService: OpenAIDocumentService
    private let claudeService: ClaudeDocumentService
    
    // MARK: - Initialization
    
    public init() {
        self.openAIService = OpenAIDocumentService(apiKey: openAIKey)
        self.claudeService = ClaudeDocumentService(apiKey: claudeKey)
    }
    
    // MARK: - AIDocumentServiceProtocol
    
    public func parseDocument<T: ParseableModel>(data: Data, fileName: String, as type: T.Type) async throws -> T {
        let fileExtension = URL(fileURLWithPath: fileName).pathExtension.lowercased()
        
        switch fileExtension {
        case "pdf":
            return try await claudeService.parseDocument(data: data, fileName: fileName, as: type)
        default:
            guard let openAIType = type as? (ParseableModel & OpenAISchemaDefinable).Type else {
                throw AIKitError.unsupportedFileType("Type \(T.self) does not support OpenAI schema definition")
            }
            return try await openAIService.parseDocument(data: data, fileName: fileName, as: openAIType) as! T
        }
    }
    
    public func uploadAndParseDocument<T: ParseableModel>(from url: URL, as type: T.Type) async throws -> T {
        return try await parseDocument(from: url, as: type)
    }
    
    // MARK: - UnifiedParsingServiceProtocol
    
    /// Parse any supported document type by routing to the appropriate service
    public func parseDocument<T: ParseableModel>(
        from url: URL,
        as type: T.Type
    ) async throws -> T {
        
        let fileExtension = url.pathExtension.lowercased()
        
        switch fileExtension {
        case "pdf":
            return try await parsePDFDocument(from: url, as: type)
        case "jpg", "jpeg", "png", "gif", "webp", "heic", "heif":
            return try await parseImageDocument(from: url, as: type)
        default:
            throw AIKitError.unsupportedFileType("File type '\(fileExtension)' is not supported. Supported types: PDF, JPEG, PNG, GIF, WebP, HEIC, HEIF")
        }
    }
    
    /// Parse PDF documents using Claude
    private func parsePDFDocument<T: ParseableModel>(
        from url: URL,
        as type: T.Type
    ) async throws -> T {
        return try await claudeService.uploadAndParseDocument(from: url, as: type)
    }
    
    /// Parse image documents using OpenAI vision
    private func parseImageDocument<T: ParseableModel>(
        from url: URL,
        as type: T.Type
    ) async throws -> T {
        let fileData = try Data(contentsOf: url)
        let fileName = url.lastPathComponent
        return try await parseDocument(data: fileData, fileName: fileName, as: type)
    }
    
    // MARK: - File Type Support
    
    /// Check if a file type is supported for parsing
    public func isFileTypeSupported(_ url: URL) -> Bool {
        let fileExtension = url.pathExtension.lowercased()
        let supportedTypes = ["pdf", "jpg", "jpeg", "png", "gif", "webp", "heic", "heif"]
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
