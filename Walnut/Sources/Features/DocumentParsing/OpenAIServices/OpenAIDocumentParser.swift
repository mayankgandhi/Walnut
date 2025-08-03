//
//  OpenAIDocumentParser.swift
//  Walnut
//
//  Created by Mayank Gandhi on 08/07/25.
//  Copyright © 2025 m. All rights reserved.
//

import Foundation

/// Handles document parsing and AI communication with OpenAI API
final class OpenAIDocumentParser {
    
    // MARK: - Dependencies
    
    private let networkClient: OpenAINetworkClient
    
    // MARK: - Initialization
    
    init(networkClient: OpenAINetworkClient) {
        self.networkClient = networkClient
    }
    
    // MARK: - Document Parsing
    
    func parseDocument<T: Codable>(data: Data, fileName: String, as type: T.Type) async throws -> T {
        // For OpenAI, we need to encode the document as base64 for vision models
        let base64Data = data.base64EncodedString()
        let mimeType = MimeTypeResolver.mimeType(for: fileName)
        
        // Create parsing prompt
        let structDef = generateStructDefinition(for: type)
        let prompt = """
        Please analyze this document and extract the information into the following JSON structure. 
        Return ONLY JSON and nothing else:
        \(structDef)
        The response is directly decoded by the same model shared.
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
            temperature: 0.1
        )
        
        do {
            let requestData = try JSONEncoder().encode(chatRequest)
            let request = try networkClient.createChatRequest(endpoint: "chat/completions", body: requestData)
            let (data, httpResponse) = try await networkClient.executeRequest(request)
            
            guard httpResponse.statusCode == 200 else {
                let errorMessage = String(data: data, encoding: .utf8) ?? "Unknown error"
                throw OpenAIServiceError.parseFailed(errorMessage)
            }
            
            let chatResponse = try JSONDecoder().decode(OpenAIChatResponse.self, from: data)
            
            guard let content = chatResponse.choices.first?.message.content else {
                throw OpenAIServiceError.parseFailed("No content in response")
            }
            
            // Clean the JSON response
            let cleanedContent = cleanJSONResponse(content)
            
            // Parse the JSON response
            guard let jsonData = cleanedContent.data(using: .utf8) else {
                throw OpenAIServiceError.parseFailed("Could not convert response to data")
            }
            
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let parsedObject = try decoder.decode(type, from: jsonData)
            return parsedObject
            
        } catch let error as DecodingError {
            throw OpenAIServiceError.decodingError(error)
        } catch let error as OpenAIServiceError {
            throw error
        } catch {
            throw OpenAIServiceError.networkError(error)
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
    
    private func generateStructDefinition<T: Codable>(for type: T.Type) -> String {
        switch type {
        case is ParsedPrescription.Type:
            return """
        Swift prescription parsing model: ParsedPrescription
        ParsedPrescription: dateIssued(Date), doctorName(String?), facilityName(String?), followUpDate(Date?), followUpTests([String]), notes(String?), medications([Medication])
        Medication: id(UUID), name(String), frequency([MedicationSchedule]), numberOfDays(Int), dosage(String?), instructions(String?)
        MedicationSchedule: mealTime(MealTime), timing(MedicationTime?), dosage(String?)
        Enums: MealTime(.breakfast/.lunch/.dinner/.bedtime), MedicationTime(.before/.after)
        """
        case is ParsedBloodReport.Type:
            return """
                    Swift blood report parsing model: ParsedBloodReport
                    ParsedBloodReport: testName(String), labName(String), category(String), resultDate(Date), notes(String), testResults([ParsedBloodTestResult])
                    ParsedBloodTestResult: testName(String), value(String), unit(String), referenceRange(String), isAbnormal(Bool)
                    
                    Please extract all blood test results from the lab report. The resultDate should be the date when the tests were performed or results were available.
                    """
        default:
            fatalError("Unsupported type \(String(describing: type))")
        }
    }
}
