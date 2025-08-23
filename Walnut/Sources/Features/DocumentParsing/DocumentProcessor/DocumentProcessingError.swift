//
//  DocumentProcessingError.swift
//  Walnut
//
//  Created by Mayank Gandhi on 01/08/25.
//  Copyright © 2025 m. All rights reserved.
//

import Foundation

enum DocumentProcessingError: LocalizedError {
    case noSelection
    case imageProcessingFailed
    case unsupportedDocumentType
    case filePreparationFailed(Error)
    case uploadFailed(Error)
    case parsingFailed(Error)
    case saveFailed(Error)
    case cleanupFailed(Error)
    
    var errorDescription: String? {
        switch self {
        case .noSelection:
            return "No document or image selected"
        case .imageProcessingFailed:
            return "Failed to process the selected image"
        case .unsupportedDocumentType:
            return "The selected document type is not supported"
        case .filePreparationFailed(let error):
            return "Failed to prepare file for upload: \(error.localizedDescription)"
        case .uploadFailed(let error):
            return "Failed to upload document: \(error.localizedDescription)"
        case .parsingFailed(let error):
            return "Failed to parse document: \(error.localizedDescription)"
        case .saveFailed(let error):
            return "Failed to save document: \(error.localizedDescription)"
        case .cleanupFailed(let error):
            return "Failed to cleanup temporary files: \(error.localizedDescription)"
        }
    }
    
    var recoverySuggestion: String? {
        switch self {
        case .noSelection:
            return "Please select a document or image before processing"
        case .imageProcessingFailed:
            return "Try selecting a different image or check image format"
        case .unsupportedDocumentType:
            return "Please select a supported document type (Prescription, Lab Result, or Blood Work)"
        case .filePreparationFailed, .uploadFailed:
            return "Check your internet connection and try again"
        case .parsingFailed:
            return "The document may be corrupted or in an unsupported format"
        case .saveFailed:
            return "Check available storage space and try again"
        case .cleanupFailed:
            return "Temporary files may remain on device but processing completed"
        }
    }
}
