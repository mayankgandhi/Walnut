//
//  ClaudeDocumentParser.swift
//  Walnut
//
//  Created by Mayank Gandhi on 08/07/25.
//  Copyright © 2025 m. All rights reserved.
//

import Foundation

/// Handles document parsing and AI communication with Claude API
final class ClaudeDocumentParser {
    
    // MARK: - Dependencies
    
    private let networkClient: ClaudeNetworkClient
    
    // MARK: - Initialization
    
    init(networkClient: ClaudeNetworkClient) {
        self.networkClient = networkClient
    }
    
    // MARK: - Document Parsing
    
    func parseDocument<T: ParseableModel>(data: Data, fileName: String, as type: T.Type) async throws -> T {
        fatalError("Direct data parsing not supported - use ClaudeDocumentService instead")
    }
    
    func parseDocument<T: ParseableModel>(fileId: String, as type: T.Type) async throws -> T {
        // Create parsing prompt using the model's parseDefinition
        let structDef = type.parseDefinition
        let prompt = """
        Please analyze this document and extract the information into the following JSON structure. 
        Return ONLY JSON and nothing else:
        \(structDef)
        The response is directly decoded by the same model shared. 
        """
        
        let messageRequest = ClaudeMessageRequest(
            model: "claude-sonnet-4-20250514",
            maxTokens: 4096,
            messages: [
                ClaudeMessage(
                    role: "user",
                    content: [
                        .text(ClaudeTextContent(text: prompt)),
                        .document(ClaudeDocumentContent(fileId: fileId, citations: ClaudeCitations(enabled: true)))
                    ]
                )
            ]
        )
        
        do {
            let requestData = try JSONEncoder().encode(messageRequest)
            let request = try networkClient.createMessageRequest(endpoint: "messages", body: requestData)
            let (data, httpResponse) = try await networkClient.executeRequest(request)
            
            guard httpResponse.statusCode == 200 else {
                let errorMessage = String(data: data, encoding: .utf8) ?? "Unknown error"
                throw AIKitError.parsingError(errorMessage)
            }
            
            let messageResponse = try JSONDecoder().decode(ClaudeMessageResponse.self, from: data)
            
            guard let content = messageResponse.content.first?.text else {
                throw AIKitError.parsingError("No content in response")
            }
            
            // Clean the JSON response
            let cleanedContent = cleanJSONResponse(content)
            
            // Parse the JSON response
            guard let jsonData = cleanedContent.data(using: .utf8) else {
                throw AIKitError.parsingError("Could not convert response to data")
            }
            
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let parsedObject = try decoder.decode(type, from: jsonData)
            return parsedObject
            
        } catch let error as DecodingError {
            throw AIKitError.decodingError(error)
        } catch let error as AIKitError {
            throw error
        } catch {
            throw AIKitError.networkError(error)
        }
    }
    
    // MARK: - Private Helpers
    
    // Helper function to extract JSON from code blocks
    private func cleanJSONResponse(_ content: String) -> String {
        var text = content
            .replacingOccurrences(of: "```", with: "")
            .replacingOccurrences(of: "json", with: "")
        text.removeFirst()
        text.removeLast()
        return text
    }
    
}
