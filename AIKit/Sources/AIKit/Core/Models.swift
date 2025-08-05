//
//  Models.swift
//  AIKit
//
//  Created by Mayank Gandhi on 05/08/25.
//  Copyright © 2025 m. All rights reserved.
//

import Foundation

public enum AIKitError: Error, LocalizedError {
    case invalidAPIKey
    case networkError(Error)
    case parsingError(String)
    case unsupportedFileType(String)
    case uploadError(String)
    case invalidFileData
    
    public var errorDescription: String? {
        switch self {
        case .invalidAPIKey:
            return "Invalid API key provided"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .parsingError(let message):
            return "Parsing error: \(message)"
        case .unsupportedFileType(let message):
            return message
        case .uploadError(let message):
            return "Upload error: \(message)"
        case .invalidFileData:
            return "Invalid file data provided"
        }
    }
}

// MARK: - File Processing

public enum ParsingMethod {
    case directVision
    case pdfFileUpload
    
    public var description: String {
        switch self {
        case .directVision:
            return "Direct AI Vision analysis"
        case .pdfFileUpload:
            return "PDF uploaded to AI service with file search and structured parsing"
        }
    }
}