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
    let responseFormat: OpenAIResponseFormat?
    
    enum CodingKeys: String, CodingKey {
        case model, messages, temperature
        case maxTokens = "max_tokens"
        case responseFormat = "response_format"
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

struct OpenAIResponseFormat: Codable {
    let type: String
    let jsonSchema: OpenAIJSONSchemaWrapper?
    
    enum CodingKeys: String, CodingKey {
        case type
        case jsonSchema = "json_schema"
    }
}

struct OpenAIJSONSchemaWrapper: Codable {
    let name: String
    let strict: Bool
    let schema: OpenAIJSONSchema
}

struct OpenAIJSONSchema: Codable {
    let type: String = "object"
    let properties: [String: Any]
    let required: [String]
    let additionalProperties: Bool
    
    enum CodingKeys: String, CodingKey {
        case type, properties, required
        case additionalProperties = "additionalProperties"
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(type, forKey: .type)
        try container.encode(required, forKey: .required)
        try container.encode(additionalProperties, forKey: .additionalProperties)
        
        let jsonData = try JSONSerialization.data(withJSONObject: properties)
        let jsonObject = try JSONSerialization.jsonObject(with: jsonData)
        try container.encode(AnyCodable(jsonObject), forKey: .properties)
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        required = try container.decode([String].self, forKey: .required)
        additionalProperties = try container.decode(Bool.self, forKey: .additionalProperties)
        let anyCodable = try container.decode(AnyCodable.self, forKey: .properties)
        properties = anyCodable.value as? [String: Any] ?? [:]
    }
    
    init(properties: [String: Any], required: [String], additionalProperties: Bool = false) {
        self.properties = properties
        self.required = required
        self.additionalProperties = additionalProperties
    }
}

struct AnyCodable: Codable {
    let value: Any
    
    init<T>(_ value: T?) {
        self.value = value ?? ()
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        
        if container.decodeNil() {
            value = ()
        } else if let bool = try? container.decode(Bool.self) {
            value = bool
        } else if let int = try? container.decode(Int.self) {
            value = int
        } else if let double = try? container.decode(Double.self) {
            value = double
        } else if let string = try? container.decode(String.self) {
            value = string
        } else if let array = try? container.decode([AnyCodable].self) {
            value = array.map { $0.value }
        } else if let dictionary = try? container.decode([String: AnyCodable].self) {
            value = dictionary.mapValues { $0.value }
        } else {
            value = ()
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        
        switch value {
        case is Void:
            try container.encodeNil()
        case let bool as Bool:
            try container.encode(bool)
        case let int as Int:
            try container.encode(int)
        case let double as Double:
            try container.encode(double)
        case let string as String:
            try container.encode(string)
        case let array as [Any]:
            try container.encode(array.map { AnyCodable($0) })
        case let dictionary as [String: Any]:
            try container.encode(dictionary.mapValues { AnyCodable($0) })
        default:
            try container.encodeNil()

        }
    }
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
