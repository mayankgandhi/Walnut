//
//  DocumentParser.swift
//  AIKit
//
//  Created by Mayank Gandhi on 05/08/25.
//  Copyright © 2025 m. All rights reserved.
//

import Foundation

/// Unified document parser that handles both OpenAI and Claude parsing
public final class DocumentParser {
    
    // MARK: - Properties
    
    private let openAIClient: OpenAINetworkClient
    private let claudeClient: ClaudeNetworkClient
    private let claudeFileManager: ClaudeFileManager
    
    // MARK: - Initialization
    
    public init(openAIKey: String, claudeKey: String) {
        self.openAIClient = OpenAINetworkClient(apiKey: openAIKey)
        self.claudeClient = ClaudeNetworkClient(apiKey: claudeKey)
        self.claudeFileManager = ClaudeFileManager(networkClient: claudeClient)
    }
    
    // MARK: - Image Parsing (OpenAI Vision)
    
    public func parseImage<T: ParseableModel & OpenAISchemaDefinable>(
        data: Data, 
        fileName: String, 
        as type: T.Type
    ) async throws -> T {
        let base64Data = data.base64EncodedString()
        let mimeType = MimeTypeResolver.mimeType(for: fileName)
        
        let prompt = """
        Please analyze this document and extract the information according to the following structure:
        
        \(type.parseDefinition)
        
        Return the information as structured JSON matching the schema provided.
        """
        
        let chatRequest = OpenAIChatRequest(
            model: "gpt-4o",
            messages: [
                OpenAIMessage(
                    role: "user",
                    content: [
                        .text(OpenAITextContent(text: prompt)),
                        .imageUrl(OpenAIImageContent(
                            imageUrl: OpenAIImageUrl(url: "data:\(mimeType);base64,\(base64Data)")
                        ))
                    ]
                )
            ],
            maxTokens: 4096,
            temperature: 0.1,
            responseFormat: OpenAIResponseFormat(
                type: "json_schema",
                jsonSchema: OpenAIJSONSchemaWrapper(
                    name: String(describing: type),
                    strict: true,
                    schema: type.jsonSchema
                )
            )
        )
        
        let requestData = try JSONEncoder().encode(chatRequest)
        let request = try openAIClient.createChatRequest(endpoint: "chat/completions", body: requestData)
        let (data, httpResponse) = try await openAIClient.executeRequest(request)
        
        guard httpResponse.statusCode == 200 else {
            let errorMessage = String(data: data, encoding: .utf8) ?? "Unknown error"
            throw AIKitError.parsingError(errorMessage)
        }
        
        let chatResponse = try JSONDecoder().decode(OpenAIChatResponse.self, from: data)
        
        guard let content = chatResponse.choices.first?.message.content,
              let jsonData = content.data(using: .utf8) else {
            throw AIKitError.parsingError("No content in response")
        }
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode(type, from: jsonData)
    }
    
    // MARK: - PDF Parsing (Claude with file upload)
    
    public func parsePDF<T: ParseableModel>(
        data: Data, 
        fileName: String, 
        as type: T.Type
    ) async throws -> T {
        // Upload file to Claude
        let uploadResponse = try await claudeFileManager.uploadFile(data: data, fileName: fileName)
        
        // Parse using Claude
        let result = try await parseWithClaude(fileId: uploadResponse.id, as: type)
        
        // Clean up uploaded file
        try await claudeFileManager.deleteDocument(fileId: uploadResponse.id)
        
        return result
    }
    
    public func parsePDF<T: ParseableModel>(
        from url: URL, 
        as type: T.Type
    ) async throws -> T {
        let uploadResponse = try await claudeFileManager.uploadDocument(at: url)
        let result = try await parseWithClaude(fileId: uploadResponse.id, as: type)
        try await claudeFileManager.deleteDocument(fileId: uploadResponse.id)
        return result
    }
    
    // MARK: - Private Helpers
    
    private func parseWithClaude<T: ParseableModel>(fileId: String, as type: T.Type) async throws -> T {
        let prompt = """
        Please analyze this document and extract the information into the following JSON structure. 
        Return ONLY JSON and nothing else:
        \(type.parseDefinition)
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
        
        let requestData = try JSONEncoder().encode(messageRequest)
        let request = try claudeClient.createMessageRequest(endpoint: "messages", body: requestData)
        let (data, httpResponse) = try await claudeClient.executeRequest(request)
        
        guard httpResponse.statusCode == 200 else {
            let errorMessage = String(data: data, encoding: .utf8) ?? "Unknown error"
            throw AIKitError.parsingError(errorMessage)
        }
        
        let messageResponse = try JSONDecoder().decode(ClaudeMessageResponse.self, from: data)
        
        guard let content = messageResponse.content.first?.text else {
            throw AIKitError.parsingError("No content in response")
        }
        
        let cleanedContent = cleanJSONResponse(content)
        
        guard let jsonData = cleanedContent.data(using: .utf8) else {
            throw AIKitError.parsingError("Could not convert response to data")
        }
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode(type, from: jsonData)
    }
    
    private func cleanJSONResponse(_ content: String) -> String {
        var text = content
            .replacingOccurrences(of: "```", with: "")
            .replacingOccurrences(of: "json", with: "")
        text.removeFirst()
        text.removeLast()
        return text
    }
    
    // MARK: - File Type Support
    
    public func isImageFile(fileName: String) -> Bool {
        let pathExtension = (fileName as NSString).pathExtension.lowercased()
        let supportedImageTypes = ["jpg", "jpeg", "png", "gif", "webp", "heic", "heif"]
        return supportedImageTypes.contains(pathExtension)
    }
    
    public func isPDFFile(fileName: String) -> Bool {
        let pathExtension = (fileName as NSString).pathExtension.lowercased()
        return pathExtension == "pdf"
    }
}
