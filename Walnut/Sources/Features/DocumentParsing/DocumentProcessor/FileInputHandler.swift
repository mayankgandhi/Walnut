//
//  FileInputHandler.swift
//  Walnut
//
//  Created by Mayank Gandhi on 01/08/25.
//  Copyright © 2025 m. All rights reserved.
//

import Foundation
import SwiftUI

// MARK: - File Input Models

/// Represents different types of file input sources
enum FileInputSource {
    case documentURL(URL)
    case imageData(UIImage)
}

/// Contains prepared file data ready for processing
struct PreparedFileInput {
    let fileURL: URL
    let originalFileName: String
    let processingDate: Date
    let healthRecordPrefix: HealthRecordFilePrefix
}

// MARK: - File Input Handler Protocol

protocol FileInputHandling {
    func prepareFile(
        from source: FileInputSource,
        documentType: DocumentType,
        processingDate: Date
    ) async throws -> PreparedFileInput
}

// MARK: - File Input Handler Implementation

/// Handles preparation of files from various input sources
/// Separates file preparation concerns from document processing logic
class FileInputHandler: FileInputHandling {
    
    private let documentFileManager: DocumentFileManager
    
    init(documentFileManager: DocumentFileManager = DocumentFileManager()) {
        self.documentFileManager = documentFileManager
    }
    
    func prepareFile(
        from source: FileInputSource,
        documentType: DocumentType,
        processingDate: Date
    ) async throws -> PreparedFileInput {
        
        let healthRecordPrefix = getHealthRecordPrefix(for: documentType)
        
        switch source {
        case .documentURL(let url):
            return try await prepareDocumentFile(
                from: url,
                prefix: healthRecordPrefix,
                processingDate: processingDate
            )
            
        case .imageData(let image):
            return try await prepareImageFile(
                from: image,
                prefix: healthRecordPrefix,
                processingDate: processingDate
            )
        }
    }
    
    // MARK: - Private Methods
    
    private func prepareDocumentFile(
        from url: URL,
        prefix: HealthRecordFilePrefix,
        processingDate: Date
    ) async throws -> PreparedFileInput {
        
        let savedFileURL = try await documentFileManager.saveDocument(
            from: url,
            prefix: prefix,
            customName: url.lastPathComponent
        )
        
        return PreparedFileInput(
            fileURL: savedFileURL,
            originalFileName: url.lastPathComponent,
            processingDate: processingDate,
            healthRecordPrefix: prefix
        )
    }
    
    private func prepareImageFile(
        from image: UIImage,
        prefix: HealthRecordFilePrefix,
        processingDate: Date
    ) async throws -> PreparedFileInput {
        
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            throw DocumentProcessingError.filePreparationFailed(
                NSError(
                    domain: "FileInputHandler",
                    code: -1,
                    userInfo: [NSLocalizedDescriptionKey: "Failed to convert image to data"]
                )
            )
        }
        
        let fileName = "image_\(Int(processingDate.timeIntervalSince1970)).jpg"
        
        let savedFileURL = try await documentFileManager.saveDocument(
            data: imageData,
            prefix: prefix,
            fileName: fileName
        )
        
        return PreparedFileInput(
            fileURL: savedFileURL,
            originalFileName: fileName,
            processingDate: processingDate,
            healthRecordPrefix: prefix
        )
    }
    
    private func getHealthRecordPrefix(for documentType: DocumentType) -> HealthRecordFilePrefix {
        switch documentType {
        case .prescription:
            return .prescriptions
        case .biomarkerReport:
            return .bloodReports
        default:
            return .otherDocuments
        }
    }
}
