//
//  JSONResponseParser.swift
//  AIKit
//
//  Created by Mayank Gandhi on 11/08/25.
//  Copyright © 2025 m. All rights reserved.
//

import Foundation

/// Handles JSON response parsing and cleaning for AI service responses
public struct JSONResponseParser {
    
    private let jsonDecoder: JSONDecoder
    
    public init(jsonDecoder: JSONDecoder) {
        self.jsonDecoder = jsonDecoder
    }
    
    // MARK: - Public Methods
    
    /// Parses OpenAI chat response content into a decodable model
    /// - Parameters:
    ///   - response: The OpenAI chat response
    ///   - type: The target model type to decode into
    /// - Returns: Decoded model instance
    /// - Throws: AIKitError.parsingError if parsing fails
    internal func parseOpenAIResponse<T: Decodable>(
        _ response: OpenAIChatResponse,
        as type: T.Type
    ) throws -> T {
        guard let content = response.choices.first?.message.content,
              let jsonData = content.data(using: .utf8) else {
            throw AIKitError.parsingError("No content in OpenAI response")
        }
        
        return try parseJSON(jsonData, as: type)
    }
    
    /// Parses Claude message response content into a decodable model
    /// - Parameters:
    ///   - response: The Claude message response
    ///   - type: The target model type to decode into
    /// - Returns: Decoded model instance
    /// - Throws: AIKitError.parsingError if parsing fails
    internal func parseClaudeResponse<T: Decodable>(
        _ response: ClaudeMessageResponse<T>,
        as type: T.Type
    ) throws -> T {
        guard let response = response.content.first?.input else {
            throw AIKitError.parsingError("No content in Claude response")
        }
        
//        let cleanedContent = cleanClaudeJSONResponse(content)
        
//        guard let jsonData = cleanedContent.data(using: .utf8) else {
//            throw AIKitError.parsingError("Could not convert cleaned response to data")
//        }
        
        return response
    }
    
    /// Parses raw JSON string into a decodable model
    /// - Parameters:
    ///   - jsonString: Raw JSON string
    ///   - type: The target model type to decode into
    /// - Returns: Decoded model instance
    /// - Throws: AIKitError.parsingError if parsing fails
    public func parseJSONString<T: Decodable>(
        _ jsonString: String,
        as type: T.Type
    ) throws -> T {
        guard let jsonData = jsonString.data(using: .utf8) else {
            throw AIKitError.parsingError("Could not convert JSON string to data")
        }
        
        return try parseJSON(jsonData, as: type)
    }
    
    /// Parses JSON data into a decodable model with configured decoder
    /// - Parameters:
    ///   - jsonData: JSON data to decode
    ///   - type: The target model type to decode into
    /// - Returns: Decoded model instance
    /// - Throws: AIKitError.parsingError if parsing fails
    public func parseJSON<T: Decodable>(
        _ jsonData: Data,
        as type: T.Type
    ) throws -> T {
        do {
            return try jsonDecoder.decode(type, from: jsonData)
        } catch {
            let jsonString = String(data: jsonData, encoding: .utf8) ?? "Invalid UTF-8 data"
            throw AIKitError.parsingError("Failed to decode JSON: \(error.localizedDescription). JSON content: \(jsonString)")
        }
    }
    
    // MARK: - Claude Response Cleaning
    
    /// Cleans Claude AI response content by removing markdown code blocks and extra formatting
    /// - Parameter content: Raw Claude response content
    /// - Returns: Cleaned JSON string
    public  func cleanClaudeJSONResponse(_ content: String) -> String {
        var text = content.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Remove markdown code blocks
        text = text.replacingOccurrences(of: "```json", with: "")
        text = text.replacingOccurrences(of: "```", with: "")
        
        // Remove any leading/trailing whitespace after cleaning
        text = text.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Handle cases where the response starts with text before JSON
        if let jsonStart = text.range(of: "{") {
            text = String(text[jsonStart.lowerBound...])
        }
        
        // Handle cases where the response has text after JSON
        if let jsonEnd = text.lastIndex(of: "}") {
            text = String(text[...jsonEnd])
        }
        
        return text
    }
    
    // MARK: - Response Validation
    
    /// Validates that a string contains valid JSON structure
    /// - Parameter jsonString: String to validate
    /// - Returns: True if the string appears to contain valid JSON structure
    public  func isValidJSONStructure(_ jsonString: String) -> Bool {
        let trimmed = jsonString.trimmingCharacters(in: .whitespacesAndNewlines)
        return (trimmed.hasPrefix("{") && trimmed.hasSuffix("}")) ||
               (trimmed.hasPrefix("[") && trimmed.hasSuffix("]"))
    }
    
    /// Extracts JSON object from mixed content (text + JSON)
    /// - Parameter content: Mixed content that may contain JSON
    /// - Returns: Extracted JSON string if found, nil otherwise
    public  func extractJSONFromMixedContent(_ content: String) -> String? {
        let cleaned = cleanClaudeJSONResponse(content)
        return isValidJSONStructure(cleaned) ? cleaned : nil
    }
}
