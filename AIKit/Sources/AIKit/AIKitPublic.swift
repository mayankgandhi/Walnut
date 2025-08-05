//
//  AIKitPublic.swift
//  AIKit
//
//  Created by Mayank Gandhi on 05/08/25.
//  Copyright © 2025 m. All rights reserved.
//

import Foundation


// Core Services
public typealias AIKitUnifiedService = UnifiedDocumentParsingService
public typealias AIKitOpenAIService = OpenAIDocumentService

// MARK: - Convenience Factory

/// Factory for creating AIKit services
public struct AIKitFactory {
    
    /// Create a unified document parsing service with OpenAI
    public static func createUnifiedService(openAIAPIKey: String) -> UnifiedDocumentParsingService {
        return UnifiedDocumentParsingService(openAIAPIKey: openAIAPIKey)
    }
    
    /// Create an OpenAI-only document service
    public static func createOpenAIService(apiKey: String) -> OpenAIDocumentService {
        return OpenAIDocumentService(apiKey: apiKey)
    }
}

// MARK: - Configuration

/// Configuration options for AIKit
public struct AIKitConfiguration {
    public let openAIAPIKey: String?
    public let claudeAPIKey: String?
    
    public init(openAIAPIKey: String? = nil, claudeAPIKey: String? = nil) {
        self.openAIAPIKey = openAIAPIKey
        self.claudeAPIKey = claudeAPIKey
    }
    
    /// Create a unified service with the configured API keys
    public func createUnifiedService() throws -> UnifiedDocumentParsingService {
        guard let openAIAPIKey = openAIAPIKey else {
            throw AIKitError.invalidAPIKey
        }
        return UnifiedDocumentParsingService(openAIAPIKey: openAIAPIKey)
    }
}