//
//  ClaudeFileUploadResponse.swift
//  Walnut
//
//  Created by Mayank Gandhi on 08/07/25.
//  Copyright © 2025 m. All rights reserved.
//


import Foundation

// MARK: - Models

struct ClaudeFileUploadResponse: Codable {
    let id: String
}

struct ClaudeMessageRequest: Codable {
    let model: String
    let maxTokens: Int
    let messages: [ClaudeMessage]
    
    enum CodingKeys: String, CodingKey {
        case model
        case maxTokens = "max_tokens"
        case messages
    }
}

struct ClaudeMessage: Codable {
    let role: String
    let content: [ClaudeContent]
}

enum ClaudeContent: Codable {
    case text(ClaudeTextContent)
    case document(ClaudeDocumentContent)
    
    private enum CodingKeys: String, CodingKey {
        case type
    }
    
    private enum ContentType: String, Codable {
        case text, document
    }
    
    func encode(to encoder: Encoder) throws {
        switch self {
        case .text(let content):
            try content.encode(to: encoder)
        case .document(let content):
            try content.encode(to: encoder)
        }
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(ContentType.self, forKey: .type)
        
        switch type {
        case .text:
            let content = try ClaudeTextContent(from: decoder)
            self = .text(content)
        case .document:
            let content = try ClaudeDocumentContent(from: decoder)
            self = .document(content)
        }
    }
}

struct ClaudeTextContent: Codable {
    let type: String = "text"
    let text: String
}

struct ClaudeDocumentContent: Codable {
    let type: String = "document"
    let source: ClaudeFileSource
    let title: String?
    let context: String?
    let citations: ClaudeCitations?
    
    init(fileId: String, title: String? = nil, context: String? = nil, citations: ClaudeCitations? = nil) {
        self.source = ClaudeFileSource(fileId: fileId)
        self.title = title
        self.context = context
        self.citations = citations
    }
}

struct ClaudeFileSource: Codable {
    let type: String = "file"
    let fileId: String
    
    enum CodingKeys: String, CodingKey {
        case type
        case fileId = "file_id"
    }
}

struct ClaudeCitations: Codable {
    let enabled: Bool
}

struct ClaudeMessageResponse: Codable {
    let id: String
    let type: String
    let role: String
    let model: String
    let content: [ClaudeResponseContent]
    
    enum CodingKeys: String, CodingKey {
        case id, type, role, model, content
    }
}

struct ClaudeResponseContent: Codable {
    let type: String
    let text: String?
}
