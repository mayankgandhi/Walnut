//
//  ClaudeDocumentService.swift
//  Walnut
//
//  Created by Mayank Gandhi on 08/07/25.
//  Copyright © 2025 m. All rights reserved.
//

import SwiftUI

/// Main orchestrator service that coordinates file operations and document parsing
/// Maintains the same interface as the original ClaudeFilesService for backward compatibility
final class ClaudeDocumentService: ObservableObject {
    
    // MARK: - Type Aliases
    
    typealias UploadResponse = ClaudeFileUploadResponse
    
    // MARK: - Dependencies
    
    private let networkClient: ClaudeNetworkClient
    private let fileManager: ClaudeFileManager
    private let documentParser: ClaudeDocumentParser
    
    // MARK: - Initialization
    
    init(apiKey: String) {
        self.networkClient = ClaudeNetworkClient(apiKey: apiKey)
        self.fileManager = ClaudeFileManager(networkClient: networkClient)
        self.documentParser = ClaudeDocumentParser(networkClient: networkClient)
    }
    
    // MARK: - File Upload
    
    func uploadFile(data: Data, fileName: String) async throws -> ClaudeFileUploadResponse {
        return try await fileManager.uploadFile(data: data, fileName: fileName)
    }
    
    func uploadDocument(at url: URL) async throws -> ClaudeFileUploadResponse {
        return try await fileManager.uploadDocument(at: url)
    }
    
    // MARK: - File Deletion
    
    func deleteDocument(fileId: String) async throws {
        try await fileManager.deleteDocument(fileId: fileId)
    }
    
    // MARK: - Document Parsing
    
    func parseDocument<T: ParseableModel>(data: Data, fileName: String, as type: T.Type) async throws -> T {
        let fileResponse = try await uploadFile(data: data, fileName: fileName)
        let parsedData = try await documentParser.parseDocument(fileId: fileResponse.id, as: type)
        try await deleteDocument(fileId: fileResponse.id)
        return parsedData
    }
    
    func parseDocument<T: ParseableModel>(fileId: String, as type: T.Type) async throws -> T {
        return try await documentParser.parseDocument(fileId: fileId, as: type)
    }
    
    // MARK: - Convenience Methods
    
    func uploadAndParseDocument<T: ParseableModel>(
        from url: URL, 
        as type: T.Type
    ) async throws -> T {
        let fileResponse = try await uploadDocument(at: url)
        let parsedData = try await parseDocument(fileId: fileResponse.id, as: type)
        try await deleteDocument(fileId: fileResponse.id)
        return parsedData
    }
}
