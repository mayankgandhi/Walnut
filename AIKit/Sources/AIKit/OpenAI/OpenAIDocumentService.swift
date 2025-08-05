//
//  OpenAIDocumentService.swift
//  AIKit
//
//  Created by Mayank Gandhi on 05/08/25.
//  Copyright © 2025 m. All rights reserved.
//

import Foundation

/// Main orchestrator service that coordinates file operations and document parsing
/// Maintains compatibility with the original ClaudeFilesService interface
public final class OpenAIDocumentService: ObservableObject {
    
    // MARK: - Dependencies
    
    private let networkClient: OpenAINetworkClient
    private let documentParser: OpenAIDocumentParser
    
    // MARK: - Initialization
    
    public init(apiKey: String) {
        self.networkClient = OpenAINetworkClient(apiKey: apiKey)
        self.documentParser = OpenAIDocumentParser(networkClient: networkClient)
    }
    
    // MARK: - Public Interface
    
    public func parseDocument<T: ParseableModel & OpenAISchemaDefinable>(data: Data, fileName: String, as type: T.Type) async throws -> T {
        return try await documentParser.parseOpenAIDocument(data: data, fileName: fileName, as: type)
    }
    
    public func uploadAndParseDocument<T: ParseableModel & OpenAISchemaDefinable>(
        from url: URL, 
        as type: T.Type
    ) async throws -> T {
        // For OpenAI, we don't need to upload files for parsing, we can directly parse the document
        let fileData = try Data(contentsOf: url)
        let fileName = url.lastPathComponent
        return try await parseDocument(data: fileData, fileName: fileName, as: type)
    }

}
