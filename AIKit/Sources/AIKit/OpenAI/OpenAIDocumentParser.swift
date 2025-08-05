//
//  OpenAIDocumentParser.swift
//  AIKit
//
//  Created by Mayank Gandhi on 05/08/25.
//  Copyright © 2025 m. All rights reserved.
//

import Foundation

/// Handles document parsing and AI communication with OpenAI API
public final class OpenAIDocumentParser {
    
    // MARK: - Dependencies
    
    private let networkClient: OpenAINetworkClient
    
    // MARK: - Initialization
    
    public init(networkClient: OpenAINetworkClient) {
        self.networkClient = networkClient
    }
    
    // MARK: - Public Interface
    
    public func parseDocument<T: ParseableModel>(data: Data, fileName: String, as type: T.Type) async throws -> T {
        guard let openAIType = type as? (ParseableModel & OpenAISchemaDefinable).Type else {
            throw AIKitError.unsupportedFileType("Type \(T.self) does not support OpenAI schema definition")
        }
        return try await parseOpenAIDocument(data: data, fileName: fileName, as: openAIType) as! T
    }
    
    // MARK: - OpenAI-specific parsing
    
    public func parseOpenAIDocument<T: ParseableModel & OpenAISchemaDefinable>(data: Data, fileName: String, as type: T.Type) async throws -> T {
        // Check if the file is a supported image type for OpenAI vision
        guard isImageFile(fileName: fileName) else {
            throw AIKitError.unsupportedFileType("OpenAI vision only supports image files (JPEG, PNG, GIF, WebP). PDF files require a different parsing approach.")
        }
        
        // For OpenAI, we need to encode the document as base64 for vision models
        let base64Data = data.base64EncodedString()
        let mimeType = MimeTypeResolver.mimeType(for: fileName)
        
        // Create parsing prompt using the model's parseDefinition
        let prompt = """
        Please analyze this document and extract the information according to the following structure:
        
        \(type.parseDefinition)
        
        Return the information as structured JSON matching the schema provided.
        """
        let jsonSchema = type.jsonSchema
        
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
                    schema: jsonSchema
                )
            )
        )
        
        do {
            let requestData = try JSONEncoder().encode(chatRequest)
            let request = try networkClient.createChatRequest(endpoint: "chat/completions", body: requestData)
            let (data, httpResponse) = try await networkClient.executeRequest(request)
            
            guard httpResponse.statusCode == 200 else {
                let errorMessage = String(data: data, encoding: .utf8) ?? "Unknown error"
                throw AIKitError.parsingError(errorMessage)
            }
            
            let chatResponse = try JSONDecoder().decode(OpenAIChatResponse.self, from: data)
            
            guard let content = chatResponse.choices.first?.message.content else {
                throw AIKitError.parsingError("No content in response")
            }
            
            // With structured outputs, the response should be valid JSON
            guard let jsonData = content.data(using: .utf8) else {
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
    
    private func isImageFile(fileName: String) -> Bool {
        let pathExtension = (fileName as NSString).pathExtension.lowercased()
        let supportedImageTypes = ["jpg", "jpeg", "png", "gif", "webp", "heic", "heif"]
        return supportedImageTypes.contains(pathExtension)
    }

}
