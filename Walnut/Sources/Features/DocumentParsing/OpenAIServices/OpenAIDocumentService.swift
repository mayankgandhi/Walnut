//
//  OpenAIDocumentService.swift
//  Walnut
//
//  Created by Mayank Gandhi on 08/07/25.
//  Copyright © 2025 m. All rights reserved.
//

import SwiftUI

/// Main orchestrator service that coordinates file operations and document parsing
/// Maintains the same interface as the original ClaudeFilesService for backward compatibility
final class OpenAIDocumentService: ObservableObject {
    
    // MARK: - Dependencies
    
    private let networkClient: OpenAINetworkClient
    private let fileManager: OpenAIFileManager
    private let documentParser: OpenAIDocumentParser
    
    // MARK: - Initialization
    
    init(apiKey: String) {
        self.networkClient = OpenAINetworkClient(apiKey: apiKey)
        self.fileManager = OpenAIFileManager(networkClient: networkClient)
        self.documentParser = OpenAIDocumentParser(networkClient: networkClient)
    }
    
    // MARK: - File Upload
    
    func uploadFile(data: Data, fileName: String) async throws -> OpenAIFileUploadResponse {
        return try await fileManager.uploadFile(data: data, fileName: fileName)
    }
    
    func uploadDocument(at url: URL) async throws -> OpenAIFileUploadResponse {
        return try await fileManager.uploadDocument(at: url)
    }
    
    // MARK: - File Deletion
    
    func deleteDocument(fileId: String) async throws {
        try await fileManager.deleteDocument(fileId: fileId)
    }
    
    // MARK: - Document Parsing
    
    func parseDocument<T: Codable>(data: Data, fileName: String, as type: T.Type) async throws -> T {
        return try await documentParser.parseDocument(data: data, fileName: fileName, as: type)
    }
    
    // MARK: - Convenience Methods
    
    func uploadAndParseDocument<T: Codable>(
        from url: URL, 
        as type: T.Type, 
        structDefinition: String? = nil
    ) async throws -> T {
        // For OpenAI, we don't need to upload files for parsing, we can directly parse the document
        let fileData = try Data(contentsOf: url)
        let fileName = url.lastPathComponent
        return try await parseDocument(data: fileData, fileName: fileName, as: type)
    }
}