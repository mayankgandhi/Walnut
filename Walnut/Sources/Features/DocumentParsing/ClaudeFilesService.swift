//
//  ClaudeFilesService.swift
//  Walnut
//
//  Created by Mayank Gandhi on 08/07/25.
//  Copyright © 2025 m. All rights reserved.
//

import SwiftUI

final class ClaudeFilesService: ObservableObject {
    private let baseURL = "https://api.anthropic.com/v1"
    private let session = URLSession.shared
    private let apiKey: String
    
    init(apiKey: String) {
        self.apiKey = apiKey
    }
    
    // MARK: - File Upload
    
    private func uploadDocument(at url: URL) async throws -> ClaudeFileUploadResponse {
        guard let uploadURL = URL(string: "\(baseURL)/files") else {
            throw ClaudeServiceError.invalidURL
        }
        
        // Read file data
        let fileData = try Data(contentsOf: url)
        let filename = url.lastPathComponent
        let mimeType = mimeType(for: url)
        
        // Create multipart form data
        let boundary = UUID().uuidString
        var request = URLRequest(url: uploadURL)
        request.httpMethod = "POST"
        request.setValue(apiKey, forHTTPHeaderField: "x-api-key")
        request.setValue("2023-06-01", forHTTPHeaderField: "anthropic-version")
        request.setValue("files-api-2025-04-14", forHTTPHeaderField: "anthropic-beta")
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        let body = createMultipartBody(boundary: boundary, 
                                     filename: filename, 
                                     data: fileData, 
                                     mimeType: mimeType)
        request.httpBody = body
        
        do {
            let (data, response) = try await session.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw ClaudeServiceError.invalidResponse
            }
            
            guard httpResponse.statusCode == 200 else {
                let errorMessage = String(data: data, encoding: .utf8) ?? "Unknown error"
                throw ClaudeServiceError.uploadFailed(errorMessage)
            }
            
            let uploadResponse = try JSONDecoder().decode(ClaudeFileUploadResponse.self, from: data)
            return uploadResponse
            
        } catch let error as DecodingError {
            throw ClaudeServiceError.decodingError(error)
        } catch let error as ClaudeServiceError {
            throw error
        } catch {
            throw ClaudeServiceError.networkError(error)
        }
    }
    
    func deleteDocument(fileId: String) async throws {
        guard let deleteURL = URL(string: "\(baseURL)/files/\(fileId)") else {
            throw ClaudeServiceError.invalidURL
        }
        
        var request = URLRequest(url: deleteURL)
        request.httpMethod = "DELETE"
        request.setValue(apiKey, forHTTPHeaderField: "x-api-key")
        request.setValue("2023-06-01", forHTTPHeaderField: "anthropic-version")
        request.setValue("files-api-2025-04-14", forHTTPHeaderField: "anthropic-beta")
        
        do {
            let (data, response) = try await session.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw ClaudeServiceError.invalidResponse
            }
            
            guard httpResponse.statusCode == 200 || httpResponse.statusCode == 204 else {
                let errorMessage = String(data: data, encoding: .utf8) ?? "Unknown error"
                throw ClaudeServiceError.deleteFailed(errorMessage)
            }
            
            // Success - file deleted
            
        } catch let error as ClaudeServiceError {
            throw error
        } catch {
            throw ClaudeServiceError.networkError(error)
        }
    }

    // MARK: - Document Parsing
    
    private func parseDocument<T: Codable>(fileId: String, as type: T.Type, structDefinition: String? = nil) async throws -> T {
        guard let messageURL = URL(string: "\(baseURL)/messages") else {
            throw ClaudeServiceError.invalidURL
        }
        
        // Create parsing prompt
        let structDef = structDefinition ?? generateStructDefinition(for: type)
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
        
        var request = URLRequest(url: messageURL)
        request.httpMethod = "POST"
        request.setValue(apiKey, forHTTPHeaderField: "x-api-key")
        request.setValue("2023-06-01", forHTTPHeaderField: "anthropic-version")
        request.setValue("files-api-2025-04-14", forHTTPHeaderField: "anthropic-beta")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            let requestData = try JSONEncoder().encode(messageRequest)
            request.httpBody = requestData
            
            let (data, response) = try await session.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw ClaudeServiceError.invalidResponse
            }
            
            guard httpResponse.statusCode == 200 else {
                let errorMessage = String(data: data, encoding: .utf8) ?? "Unknown error"
                throw ClaudeServiceError.parseFailed(errorMessage)
            }
            
            let messageResponse = try JSONDecoder().decode(ClaudeMessageResponse.self, from: data)
            
            guard let content = messageResponse.content.first?.text else {
                throw ClaudeServiceError.parseFailed("No content in response")
            }
            
            var newContent = content
                .replacingOccurrences(of: "\n", with: "")
                .replacingOccurrences(of: "```", with: "")
                .replacingOccurrences(of: "json", with: "")
            
            // Parse the JSON response
            guard let jsonData = newContent.data(using: .utf8) else {
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
    
    // MARK: - Convenience Method
    
    func uploadAndParseDocument<T: Codable>(
        from url: URL, 
        as type: T.Type, 
        structDefinition: String? = nil
    ) async throws -> T {
        let fileResponse = try await uploadDocument(at: url)
        let parsedData = try await parseDocument(fileId: fileResponse.id, as: type, structDefinition: structDefinition)
        try await deleteDocument(fileId: fileResponse.id)
        return parsedData
    }
    
    // MARK: - Helper Methods
    
    private func createMultipartBody(boundary: String, filename: String, data: Data, mimeType: String) -> Data {
        var body = Data()
        
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"\(filename)\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: \(mimeType)\r\n\r\n".data(using: .utf8)!)
        body.append(data)
        body.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
        
        return body
    }
    
    private func mimeType(for url: URL) -> String {
        let pathExtension = url.pathExtension.lowercased()
        switch pathExtension {
        case "pdf":
            return "application/pdf"
        case "txt":
            return "text/plain"
        case "json":
            return "application/json"
        case "csv":
            return "text/csv"
        case "jpg", "jpeg":
            return "image/jpeg"
        case "png":
            return "image/png"
        case "gif":
            return "image/gif"
        case "webp":
            return "image/webp"
        default:
            return "application/octet-stream"
        }
    }
    
    private func generateStructDefinition<T: Codable>(for type: T.Type) -> String {
        """
        Swift prescription parsing model: ParsedPrescription
        ParsedPrescription: dateIssued(Date), doctorName(String?), facilityName(String?), followUpDate(Date?), followUpTests([String]), notes(String?), medications([Medication])
        Medication: id(UUID), name(String), frequency([MedicationSchedule]), numberOfDays(Int), dosage(String?), instructions(String?)
        MedicationSchedule: mealTime(MealTime), timing(MedicationTime?), dosage(String?)
        Enums: MealTime(.breakfast/.lunch/.dinner/.bedtime), MedicationTime(.before/.after)
        """
    }
}

// MARK: - Usage Example


