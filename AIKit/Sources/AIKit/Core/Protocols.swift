//
//  Protocols.swift
//  AIKit
//
//  Created by Mayank Gandhi on 05/08/25.
//  Copyright © 2025 m. All rights reserved.
//

import Foundation

// MARK: - Core AI Service Protocol

public protocol ParseDefinable {
    static var parseDefinition: String { get }
}

public typealias ParseableModel = Codable & ParseDefinable

/// Protocol for AI document parsing services
public protocol AIDocumentServiceProtocol {
    /// Parse a document using direct data and filename
    func parseDocument<T: ParseableModel>(data: Data, fileName: String, as type: T.Type) async throws -> T
    
    /// Upload and parse a document from URL (for services that require file upload)
    func uploadAndParseDocument<T: ParseableModel>(from url: URL, as type: T.Type) async throws -> T
}

// MARK: - File Upload Protocol

/// Protocol for services that support file upload
public protocol FileUploadServiceProtocol {
    associatedtype UploadResponse: Codable
    
    func uploadFile(data: Data, fileName: String) async throws -> UploadResponse
    func uploadDocument(at url: URL) async throws -> UploadResponse
    func deleteDocument(fileId: String) async throws
}

// MARK: - Network Client Protocol

/// Protocol for network operations
public protocol NetworkClientProtocol {
    func performNetworkRequest(for request: URLRequest) async throws -> Data
}

// MARK: - Document Parser Protocol

/// Protocol for document parsing operations
public protocol DocumentParserProtocol {
    func parseDocument<T: ParseableModel>(data: Data, fileName: String, as type: T.Type) async throws -> T
}

// MARK: - Unified Parsing Service Protocol

/// Protocol for services that can handle multiple file types
public protocol UnifiedParsingServiceProtocol: AIDocumentServiceProtocol {
    
    associatedtype ParseOutput: Codable
    
    /// Check if a file type is supported
    func isFileTypeSupported(_ url: URL) -> Bool
    
    /// Get the parsing method for a file
    func getParsingMethod(for url: URL) -> ParsingMethod?
    
    /// Parse a prescription from any supported format
    func parse(from url: URL) async throws -> ParseOutput
    
}
