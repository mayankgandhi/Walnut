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
    
    func parseDocument<T: Codable>(fileId: String, as type: T.Type) async throws -> T {
        // Create parsing prompt
        let structDef = generateStructDefinition(for: type)
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
                throw ClaudeServiceError.parseFailed(errorMessage)
            }
            
            let messageResponse = try JSONDecoder().decode(ClaudeMessageResponse.self, from: data)
            
            guard let content = messageResponse.content.first?.text else {
                throw ClaudeServiceError.parseFailed("No content in response")
            }
            
            // Clean the JSON response
            let cleanedContent = cleanJSONResponse(content)
            
            // Parse the JSON response
            guard let jsonData = cleanedContent.data(using: .utf8) else {
                throw ClaudeServiceError.parseFailed("Could not convert response to data")
            }
            
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let parsedObject = try decoder.decode(type, from: jsonData)
            return parsedObject
            
        } catch let error as DecodingError {
            throw ClaudeServiceError.decodingError(error)
        } catch let error as ClaudeServiceError {
            throw error
        } catch {
            throw ClaudeServiceError.networkError(error)
        }
    }
    
    // MARK: - Private Helpers
    
    private func cleanJSONResponse(_ content: String) -> String {
        return content
            .replacingOccurrences(of: "\n", with: "")
            .replacingOccurrences(of: "```", with: "")
            .replacingOccurrences(of: "json", with: "")
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