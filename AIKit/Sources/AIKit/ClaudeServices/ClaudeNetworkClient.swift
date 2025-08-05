//
//  ClaudeNetworkClient.swift
//  Walnut
//
//  Created by Mayank Gandhi on 08/07/25.
//  Copyright © 2025 m. All rights reserved.
//

import Foundation

/// Handles HTTP communication with Claude API
final class ClaudeNetworkClient: NetworkClientProtocol {
    
    // MARK: - Properties
    
    private let baseURL = "https://api.anthropic.com/v1"
    private let session = URLSession.shared
    private let apiKey: String
    
    // MARK: - Initialization
    
    init(apiKey: String) {
        self.apiKey = apiKey
    }
    
    // MARK: - Public Interface
    
    func createFileUploadRequest(endpoint: String, body: Data, contentType: String) throws -> URLRequest {
        guard let url = URL(string: "\(baseURL)/\(endpoint)") else {
            throw ClaudeServiceError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(apiKey, forHTTPHeaderField: "x-api-key")
        request.setValue("2023-06-01", forHTTPHeaderField: "anthropic-version")
        request.setValue("files-api-2025-04-14", forHTTPHeaderField: "anthropic-beta")
        request.setValue(contentType, forHTTPHeaderField: "Content-Type")
        request.httpBody = body
        
        return request
    }
    
    func createMessageRequest(endpoint: String, body: Data) throws -> URLRequest {
        guard let url = URL(string: "\(baseURL)/\(endpoint)") else {
            throw ClaudeServiceError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(apiKey, forHTTPHeaderField: "x-api-key")
        request.setValue("2023-06-01", forHTTPHeaderField: "anthropic-version")
        request.setValue("files-api-2025-04-14", forHTTPHeaderField: "anthropic-beta")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = body
        
        return request
    }
    
    func createDeleteRequest(endpoint: String) throws -> URLRequest {
        guard let url = URL(string: "\(baseURL)/\(endpoint)") else {
            throw ClaudeServiceError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue(apiKey, forHTTPHeaderField: "x-api-key")
        request.setValue("2023-06-01", forHTTPHeaderField: "anthropic-version")
        request.setValue("files-api-2025-04-14", forHTTPHeaderField: "anthropic-beta")
        
        return request
    }
    
    func executeRequest(_ request: URLRequest) async throws -> (Data, HTTPURLResponse) {
        do {
            let (data, response) = try await session.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw ClaudeServiceError.invalidResponse
            }
            
            return (data, httpResponse)
            
        } catch let error as ClaudeServiceError {
            throw error
        } catch {
            throw ClaudeServiceError.networkError(error)
        }
    }
    
    // MARK: - NetworkClientProtocol
    
    func performNetworkRequest(for request: URLRequest) async throws -> Data {
        let (data, _) = try await executeRequest(request)
        return data
    }
}