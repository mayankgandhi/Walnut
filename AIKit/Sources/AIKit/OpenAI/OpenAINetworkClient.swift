//
//  OpenAINetworkClient.swift
//  AIKit
//
//  Created by Mayank Gandhi on 05/08/25.
//  Copyright © 2025 m. All rights reserved.
//

import Foundation

/// Handles HTTP communication with OpenAI API
public final class OpenAINetworkClient: NetworkClientProtocol {
    
    // MARK: - Properties
    
    private let baseURL = "https://api.openai.com/v1"
    private let session = URLSession.shared
    private let apiKey: String
    
    // MARK: - Initialization
    
    public init(apiKey: String) {
        self.apiKey = apiKey
    }
    
    // MARK: - NetworkClientProtocol
    
    public func performNetworkRequest(for request: URLRequest) async throws -> Data {
        let (data, response) = try await executeRequest(request)
        
        guard response.statusCode == 200 else {
            throw OpenAIServiceError.invalidResponse
        }
        
        return data
    }
    
    // MARK: - Public Interface
    
    public func createFileUploadRequest(endpoint: String, body: Data, contentType: String) throws -> URLRequest {
        guard let url = URL(string: "\(baseURL)/\(endpoint)") else {
            throw OpenAIServiceError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue(contentType, forHTTPHeaderField: "Content-Type")
        request.httpBody = body
        
        return request
    }
    
    public func createChatRequest(endpoint: String, body: Data) throws -> URLRequest {
        guard let url = URL(string: "\(baseURL)/\(endpoint)") else {
            throw OpenAIServiceError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = body
        
        return request
    }
    
    public func createDeleteRequest(endpoint: String) throws -> URLRequest {
        guard let url = URL(string: "\(baseURL)/\(endpoint)") else {
            throw OpenAIServiceError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        
        return request
    }
    
    public func createGetRequest(endpoint: String) throws -> URLRequest {
        guard let url = URL(string: "\(baseURL)/\(endpoint)") else {
            throw OpenAIServiceError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        
        return request
    }
    
    public func createRequest(endpoint: String, method: String) throws -> URLRequest {
        guard let url = URL(string: "\(baseURL)/\(endpoint)") else {
            throw OpenAIServiceError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        
        return request
    }
    
    public func executeRequest(_ request: URLRequest) async throws -> (Data, HTTPURLResponse) {
        do {
            let (data, response) = try await session.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw OpenAIServiceError.invalidResponse
            }
            
            return (data, httpResponse)
            
        } catch let error as OpenAIServiceError {
            throw error
        } catch {
            throw OpenAIServiceError.networkError(error)
        }
    }
}