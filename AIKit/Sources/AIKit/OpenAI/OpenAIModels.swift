//
//  OpenAIModels.swift
//  AIKit
//
//  Created by Mayank Gandhi on 05/08/25.
//  Copyright © 2025 m. All rights reserved.
//

import Foundation

// MARK: - OpenAI-specific Protocol Extension

/// Protocol extension for OpenAI JSON Schema support
public protocol OpenAISchemaDefinable: ParseDefinable {
    static var jsonSchema: OpenAIJSONSchema { get }
}

// MARK: - File Upload Models

public struct OpenAIFileUploadResponse: Codable {
    public let id: String
    public let object: String
    public let bytes: Int
    public let createdAt: Int
    public let filename: String
    public let purpose: String
    
    enum CodingKeys: String, CodingKey {
        case id, object, bytes, filename, purpose
        case createdAt = "created_at"
    }
}

// MARK: - Chat API Models

public struct OpenAIChatRequest: Codable {
    public let model: String
    public let messages: [OpenAIMessage]
    public let maxTokens: Int?
    public let temperature: Double?
    public let responseFormat: OpenAIResponseFormat?
    
    enum CodingKeys: String, CodingKey {
        case model, messages, temperature
        case maxTokens = "max_tokens"
        case responseFormat = "response_format"
    }
    
    public init(model: String, messages: [OpenAIMessage], maxTokens: Int? = nil, temperature: Double? = nil, responseFormat: OpenAIResponseFormat? = nil) {
        self.model = model
        self.messages = messages
        self.maxTokens = maxTokens
        self.temperature = temperature
        self.responseFormat = responseFormat
    }
}

public struct OpenAIMessage: Codable {
    public let role: String
    public let content: [OpenAIMessageContent]
    
    public init(role: String, content: [OpenAIMessageContent]) {
        self.role = role
        self.content = content
    }
}

public enum OpenAIMessageContent: Codable {
    case text(OpenAITextContent)
    case imageUrl(OpenAIImageContent)
    
    private enum CodingKeys: String, CodingKey {
        case type
    }
    
    private enum ContentType: String, Codable {
        case text
        case imageUrl = "image_url"
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(ContentType.self, forKey: .type)
        
        switch type {
        case .text:
            let textContent = try OpenAITextContent(from: decoder)
            self = .text(textContent)
        case .imageUrl:
            let imageContent = try OpenAIImageContent(from: decoder)
            self = .imageUrl(imageContent)
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        switch self {
        case .text(let textContent):
            try textContent.encode(to: encoder)
        case .imageUrl(let imageContent):
            try imageContent.encode(to: encoder)
        }
    }
}

public struct OpenAITextContent: Codable {
    public let type: String
    public let text: String
    
    public init(text: String) {
        self.type = "text"
        self.text = text
    }
}

public struct OpenAIImageContent: Codable {
    public let type: String
    public let imageUrl: OpenAIImageUrl
    
    enum CodingKeys: String, CodingKey {
        case type
        case imageUrl = "image_url"
    }
    
    public init(imageUrl: OpenAIImageUrl) {
        self.type = "image_url"
        self.imageUrl = imageUrl
    }
}

public struct OpenAIImageUrl: Codable {
    public let url: String
    public let detail: String?
    
    public init(url: String, detail: String? = "high") {
        self.url = url
        self.detail = detail
    }
}

public struct OpenAIResponseFormat: Codable {
    public let type: String
    public let jsonSchema: OpenAIJSONSchemaWrapper?
    
    enum CodingKeys: String, CodingKey {
        case type
        case jsonSchema = "json_schema"
    }
    
    public init(type: String = "json_object", jsonSchema: OpenAIJSONSchemaWrapper? = nil) {
        self.type = type
        self.jsonSchema = jsonSchema
    }
}

public struct OpenAIJSONSchemaWrapper: Codable {
    public let name: String
    public let strict: Bool
    public let schema: OpenAIJSONSchema
    
    public init(name: String, strict: Bool = true, schema: OpenAIJSONSchema) {
        self.name = name
        self.strict = strict
        self.schema = schema
    }
}

public struct OpenAIJSONSchema: Codable {
    public let type: String = "object"
    public let properties: [String: Any]
    public let required: [String]
    public let additionalProperties: Bool
    
    enum CodingKeys: String, CodingKey {
        case type, properties, required
        case additionalProperties = "additionalProperties"
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(type, forKey: .type)
        try container.encode(required, forKey: .required)
        try container.encode(additionalProperties, forKey: .additionalProperties)
        
        let jsonData = try JSONSerialization.data(withJSONObject: properties)
        let jsonObject = try JSONSerialization.jsonObject(with: jsonData)
        try container.encode(AnyCodable(jsonObject), forKey: .properties)
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        required = try container.decode([String].self, forKey: .required)
        additionalProperties = try container.decode(Bool.self, forKey: .additionalProperties)
        let anyCodable = try container.decode(AnyCodable.self, forKey: .properties)
        properties = anyCodable.value as? [String: Any] ?? [:]
    }
    
    public init(properties: [String: Any], required: [String], additionalProperties: Bool = false) {
        self.properties = properties
        self.required = required
        self.additionalProperties = additionalProperties
    }
}

public struct AnyCodable: Codable {
    public let value: Any
    
    public init<T>(_ value: T?) {
        self.value = value ?? ()
    }
    
    public init(from decoder: Decoder) throws {
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
    
    public func encode(to encoder: Encoder) throws {
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

// MARK: - Response Models

public struct OpenAIChatResponse: Codable {
    public let id: String
    public let object: String
    public let created: Int
    public let model: String
    public let choices: [OpenAIChoice]
    public let usage: OpenAIUsage
    public let systemFingerprint: String?
    
    enum CodingKeys: String, CodingKey {
        case id, object, created, model, choices, usage
        case systemFingerprint = "system_fingerprint"
    }
}

public struct OpenAIChoice: Codable {
    public let index: Int
    public let message: OpenAIResponseMessage
    public let logprobs: String?
    public let finishReason: String
    
    enum CodingKeys: String, CodingKey {
        case index, message, logprobs
        case finishReason = "finish_reason"
    }
}

public struct OpenAIResponseMessage: Codable {
    public let role: String
    public let content: String
    public let refusal: String?
}

public struct OpenAIUsage: Codable {
    public let promptTokens: Int
    public let completionTokens: Int
    public let totalTokens: Int
    
    enum CodingKeys: String, CodingKey {
        case promptTokens = "prompt_tokens"
        case completionTokens = "completion_tokens"
        case totalTokens = "total_tokens"
    }
}

