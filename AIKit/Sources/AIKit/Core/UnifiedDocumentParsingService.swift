//
//  UnifiedDocumentParsingService.swift
//  AIKit
//
//  Created by Mayank Gandhi on 05/08/25.
//  Copyright © 2025 m. All rights reserved.
//

import Foundation

/// Simple, unified service for parsing any supported document type
public final class UnifiedDocumentParsingService: DocumentParsingService, ObservableObject {

    // MARK: - Dependencies
    
    private let parser: DocumentParser
    
    // MARK: - Initialization
    
    public init(
        openAIKey: String,
        claudeKey: String
    ) {
        self.parser = DocumentParser(openAIKey: openAIKey, claudeKey: claudeKey)
    }
    
    // MARK: - DocumentParsingService
    
    public func parseDocument<T: ParseableModel>(data: Data, fileName: String, as type: T.Type) async throws -> T {
        let fileExtension = URL(fileURLWithPath: fileName).pathExtension.lowercased()
        
        switch fileExtension {
        case "pdf":
            return try await parser.parsePDF(data: data, fileName: fileName, as: type)
        case "jpg", "jpeg", "png", "gif", "webp", "heic", "heif":
            guard let openAIType = type as? (ParseableModel & OpenAISchemaDefinable).Type else {
                throw AIKitError.unsupportedFileType("Type \(T.self) does not support OpenAI schema definition")
            }
            return try await parser.parseImage(data: data, fileName: fileName, as: openAIType) as! T
        default:
            throw AIKitError.unsupportedFileType("File type '\(fileExtension)' is not supported. Supported types: PDF, JPEG, PNG, GIF, WebP, HEIC, HEIF")
        }
    }
    
    public func parseDocument<T: ParseableModel>(from url: URL, as type: T.Type) async throws -> T {
        let fileExtension = url.pathExtension.lowercased()
        
        switch fileExtension {
        case "pdf":
            return try await parser.parsePDF(from: url, as: type)
        case "jpg", "jpeg", "png", "gif", "webp", "heic", "heif":
            let fileData = try Data(contentsOf: url)
            let fileName = url.lastPathComponent
            return try await parseDocument(data: fileData, fileName: fileName, as: type)
        default:
            throw AIKitError.unsupportedFileType("File type '\(fileExtension)' is not supported. Supported types: PDF, JPEG, PNG, GIF, WebP, HEIC, HEIF")
        }
    }
    
    // MARK: - File Type Support
    
    public func isFileTypeSupported(_ url: URL) -> Bool {
        let fileExtension = url.pathExtension.lowercased()
        let supportedTypes = ["pdf", "jpg", "jpeg", "png", "gif", "webp", "heic", "heif"]
        return supportedTypes.contains(fileExtension)
    }
    
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
