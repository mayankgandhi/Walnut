//
//  BaseNetworkClient.swift
//  AIKit
//
//  Created by Mayank Gandhi on 05/08/25.
//  Copyright © 2025 m. All rights reserved.
//

import Foundation

/// Base network client that handles common HTTP operations
public class BaseNetworkClient {
    
    // MARK: - Properties
    
    private let session = URLSession.shared
    let apiKey: String
    private let baseURL: String
    
    // MARK: - Initialization
    
    public init(apiKey: String, baseURL: String) {
        self.apiKey = apiKey
        self.baseURL = baseURL
    }
    
    // MARK: - Common Network Operations
    
    public func executeRequest(_ request: URLRequest) async throws -> (Data, HTTPURLResponse) {
        do {
            let (data, response) = try await session.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw AIKitError.invalidResponse
            }
            
            return (data, httpResponse)
            
        } catch let error as AIKitError {
            throw error
        } catch {
            throw AIKitError.networkError(error)
        }
    }
    
    public func performNetworkRequest(for request: URLRequest) async throws -> Data {
        let (data, response) = try await executeRequest(request)
        
        guard response.statusCode == 200 else {
            throw AIKitError.invalidResponse
        }
        
        return data
    }
    
    // MARK: - Request Building Helpers
    
    func createBaseRequest(endpoint: String, method: String) throws -> URLRequest {
        guard let url = URL(string: "\(baseURL)/\(endpoint)") else {
            throw AIKitError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        return request
    }
    
    func addJSONHeaders(to request: inout URLRequest) {
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    }
    
    func addMultipartHeaders(to request: inout URLRequest, contentType: String) {
        request.setValue(contentType, forHTTPHeaderField: "Content-Type")
    }
}
