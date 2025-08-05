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
public final class OpenAIDocumentService: AIDocumentServiceProtocol, ObservableObject {
    
    // MARK: - Dependencies
    
    private let networkClient: OpenAINetworkClient
    private let documentParser: OpenAIDocumentParser
    
    // MARK: - Initialization
    
    public init(apiKey: String) {
        self.networkClient = OpenAINetworkClient(apiKey: apiKey)
        self.documentParser = OpenAIDocumentParser(networkClient: networkClient)
    }
    
    // MARK: - AIDocumentServiceProtocol
    
    public func parseDocument<T: Codable>(data: Data, fileName: String, as type: T.Type) async throws -> T {
        return try await documentParser.parseDocument(data: data, fileName: fileName, as: type)
    }
    
    public func uploadAndParseDocument<T: Codable>(
        from url: URL, 
        as type: T.Type, 
        structDefinition: String? = nil
    ) async throws -> T {
        // For OpenAI, we don't need to upload files for parsing, we can directly parse the document
        let fileData = try Data(contentsOf: url)
        let fileName = url.lastPathComponent
        return try await parseDocument(data: fileData, fileName: fileName, as: type)
    }
    
    // MARK: - Convenience Methods
    
    /// Parse a prescription document from URL
    public func parsePrescription(from url: URL) async throws -> ParsedPrescription {
        return try await uploadAndParseDocument(from: url, as: ParsedPrescription.self)
    }
    
    /// Parse a prescription document from data
    public func parsePrescription(data: Data, fileName: String) async throws -> ParsedPrescription {
        return try await parseDocument(data: data, fileName: fileName, as: ParsedPrescription.self)
    }
    
    /// Parse a blood report document from URL
    public func parseBloodReport(from url: URL) async throws -> ParsedBloodReport {
        return try await uploadAndParseDocument(from: url, as: ParsedBloodReport.self)
    }
    
    /// Parse a blood report document from data
    public func parseBloodReport(data: Data, fileName: String) async throws -> ParsedBloodReport {
        return try await parseDocument(data: data, fileName: fileName, as: ParsedBloodReport.self)
    }
}