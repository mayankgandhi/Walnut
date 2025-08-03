//
//  OpenAIFileManager.swift
//  Walnut
//
//  Created by Mayank Gandhi on 08/07/25.
//  Copyright © 2025 m. All rights reserved.
//

import Foundation

/// Handles file upload and deletion operations with OpenAI API
final class OpenAIFileManager {
    
    // MARK: - Dependencies
    
    private let networkClient: OpenAINetworkClient
    
    // MARK: - Initialization
    
    init(networkClient: OpenAINetworkClient) {
        self.networkClient = networkClient
    }
    
    // MARK: - File Upload
    
    func uploadFile(data: Data, fileName: String) async throws -> OpenAIFileUploadResponse {
        // Create multipart form data
        let boundary = MultipartFormBuilder.generateBoundary()
        let body = createOpenAIMultipartBody(
            boundary: boundary,
            filename: fileName,
            data: data,
            purpose: "assistants"
        )
        let contentType = MultipartFormBuilder.contentType(with: boundary)
        
        let request = try networkClient.createFileUploadRequest(
            endpoint: "files",
            body: body,
            contentType: contentType
        )
        
        let (data, httpResponse) = try await networkClient.executeRequest(request)
        
        guard httpResponse.statusCode == 200 else {
            let errorMessage = String(data: data, encoding: .utf8) ?? "Unknown error"
            throw OpenAIServiceError.uploadFailed(errorMessage)
        }
        
        do {
            let uploadResponse = try JSONDecoder().decode(OpenAIFileUploadResponse.self, from: data)
            return uploadResponse
        } catch let error as DecodingError {
            throw OpenAIServiceError.decodingError(error)
        }
    }
    
    func uploadDocument(at url: URL) async throws -> OpenAIFileUploadResponse {
        // Read file data
        let fileData = try Data(contentsOf: url)
        let filename = url.lastPathComponent
        
        return try await uploadFile(data: fileData, fileName: filename)
    }
    
    // MARK: - File Deletion
    
    func deleteDocument(fileId: String) async throws {
        let request = try networkClient.createDeleteRequest(endpoint: "files/\(fileId)")
        let (data, httpResponse) = try await networkClient.executeRequest(request)
        
        guard httpResponse.statusCode == 200 || httpResponse.statusCode == 204 else {
            let errorMessage = String(data: data, encoding: .utf8) ?? "Unknown error"
            throw OpenAIServiceError.deleteFailed(errorMessage)
        }
        
        // Success - file deleted
    }
    
    // MARK: - Private Helpers
    
    private func createOpenAIMultipartBody(boundary: String, filename: String, data: Data, purpose: String) -> Data {
        var body = Data()
        
        // Add purpose field
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"purpose\"\r\n\r\n".data(using: .utf8)!)
        body.append("\(purpose)\r\n".data(using: .utf8)!)
        
        // Add file field
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"\(filename)\"\r\n".data(using: .utf8)!)
        
        let mimeType = MimeTypeResolver.mimeType(for: filename)
        body.append("Content-Type: \(mimeType)\r\n\r\n".data(using: .utf8)!)
        body.append(data)
        body.append("\r\n".data(using: .utf8)!)
        
        // End boundary
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        
        return body
    }
}
