//
//  AIKitPublic.swift
//  AIKit
//
//  Created by Mayank Gandhi on 05/08/25.
//  Copyright © 2025 m. All rights reserved.
//

import Foundation

// MARK: - Convenience Factory
/// Factory for creating AIKit services
public struct AIKitFactory {
    
    /// Create a unified document parsing service with OpenAI
    public static func createUnifiedService(
        claudeKey: String,
        openAIKey: String
    ) -> UnifiedDocumentParsingService {
        return UnifiedDocumentParsingService(
            openAIKey: openAIKey,
            claudeKey: claudeKey
        )
    }
    
}
