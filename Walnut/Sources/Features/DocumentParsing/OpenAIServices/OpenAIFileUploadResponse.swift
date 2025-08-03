//
//  OpenAIFileUploadResponse.swift
//  Walnut
//
//  Created by Mayank Gandhi on 08/07/25.
//  Copyright © 2025 m. All rights reserved.
//

import Foundation

// MARK: - Models

struct OpenAIFileUploadResponse: Codable {
    let id: String
    let object: String
    let bytes: Int
    let createdAt: Int
    let filename: String
    let purpose: String
    
    enum CodingKeys: String, CodingKey {
        case id, object, bytes, filename, purpose
        case createdAt = "created_at"
    }
}

struct OpenAIChatRequest: Codable {
    let model: String
    let messages: [OpenAIMessage]
    let maxTokens: Int?
    let temperature: Double?
    
    enum CodingKeys: String, CodingKey {
        case model, messages, temperature
        case maxTokens = "max_tokens"
    }
}

struct OpenAIMessage: Codable {
    let role: String
    let content: [OpenAIMessageContent]
}

enum OpenAIMessageContent: Codable {
    case text(OpenAITextContent)
    case imageUrl(OpenAIImageContent)
    
    private enum CodingKeys: String, CodingKey {
        case type
    }
    
    private enum ContentType: String, Codable {
        case text = "text"
        case imageUrl = "image_url"
    }
    
    func encode(to encoder: Encoder) throws {
        switch self {
        case .text(let content):
            try content.encode(to: encoder)
        case .imageUrl(let content):
            try content.encode(to: encoder)
        }
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(ContentType.self, forKey: .type)
        
        switch type {
        case .text:
            let content = try OpenAITextContent(from: decoder)
            self = .text(content)
        case .imageUrl:
            let content = try OpenAIImageContent(from: decoder)
            self = .imageUrl(content)
        }
    }
}

struct OpenAITextContent: Codable {
    let type: String = "text"
    let text: String
}

struct OpenAIImageContent: Codable {
    let type: String = "image_url"
    let imageUrl: OpenAIImageUrl
    
    enum CodingKeys: String, CodingKey {
        case type
        case imageUrl = "image_url"
    }
}

struct OpenAIImageUrl: Codable {
    let url: String
}

struct OpenAIChatResponse: Codable {
    let id: String
    let object: String
    let created: Int
    let model: String
    let choices: [OpenAIChoice]
}

struct OpenAIChoice: Codable {
    let index: Int
    let message: OpenAIResponseMessage
    let finishReason: String?
    
    enum CodingKeys: String, CodingKey {
        case index, message
        case finishReason = "finish_reason"
    }
}

struct OpenAIResponseMessage: Codable {
    let role: String
    let content: String?
}

// MARK: - Error Types

enum OpenAIServiceError: Error, LocalizedError {
    case invalidURL
    case invalidResponse
    case missingAPIKey
    case uploadFailed(String)
    case deleteFailed(String)
    case parseFailed(String)
    case networkError(Error)
    case decodingError(Error)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .invalidResponse:
            return "Invalid response from server"
        case .missingAPIKey:
            return "API key is missing"
        case .uploadFailed(let message):
            return "Upload failed: \(message)"
        case .parseFailed(let message):
            return "Parse failed: \(message)"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .decodingError(let error):
            return "Decoding error: \(error.localizedDescription)"
        case .deleteFailed(let message):
            return "Deletion error: \(message)"
        }
    }
}