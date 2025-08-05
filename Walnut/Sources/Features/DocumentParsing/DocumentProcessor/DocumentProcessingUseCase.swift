//
//  DocumentProcessingUseCase.swift
//  Walnut
//
//  Created by Mayank Gandhi on 01/08/25.
//  Copyright © 2025 m. All rights reserved.
//

import Foundation
import SwiftData
import AIKit

// MARK: - Use Case Implementation

/// Encapsulates the business logic for document processing
struct DocumentProcessingUseCase {
    
    private let aiService: AIDocumentServiceProtocol
    private let fileService: FilePreparationService
    private let repository: DocumentRepositoryProtocol
    private weak var progressDelegate: DocumentProcessingProgressDelegate?
    
    init(
        aiService: AIDocumentServiceProtocol,
        fileService: FilePreparationService,
        repository: DocumentRepositoryProtocol,
        progressDelegate: DocumentProcessingProgressDelegate?
    ) {
        self.aiService = aiService
        self.fileService = fileService
        self.repository = repository
        self.progressDelegate = progressDelegate
    }
    
    func execute(
        from store: DocumentPickerStore,
        for medicalCase: MedicalCase
    ) async throws -> ProcessingResult {
        
        var fileURL: URL?
        
        do {
            // Step 1: Prepare file for processing
            await updateProgress(0.2, "Preparing file...")
            fileURL = try await fileService.prepareFile(from: store)
            
            // Step 2: Parse document directly using AI service
            await updateProgress(0.5, "Parsing document...")
            let modelId = try await parseAndSaveDocument(
                fileURL: fileURL!,
                documentType: store.selectedDocumentType,
                medicalCase: medicalCase
            )
            
            // Step 3: Cleanup
            await updateProgress(0.9, "Cleaning up...")
            if let fileURL = fileURL {
                fileService.cleanupTemporaryFile(at: fileURL)
            }
            
            await updateProgress(1.0, "Complete!")
            
            return ProcessingResult(
                documentType: store.selectedDocumentType,
                modelId: modelId,
                originalFileName: fileURL?.lastPathComponent ?? "Unknown File"
            )
            
        } catch {
            // Cleanup on error
            if let fileURL = fileURL {
                fileService.cleanupTemporaryFile(at: fileURL)
            }
            
            // Re-throw with context
            throw mapError(error)
        }
    }
    
    // MARK: - Error Handling
    
    private func mapError(_ error: Error) -> DocumentProcessingError {
        // Map different types of errors to appropriate DocumentProcessingError cases
        if error is DocumentProcessingError {
            return error as! DocumentProcessingError
        }
        
        // Add more specific error mapping based on error types you expect
        return .parsingFailed(error)
    }
    
    // MARK: - Private Methods
    
    private func parseAndSaveDocument(
        fileURL: URL,
        documentType: DocumentType,
        medicalCase: MedicalCase
    ) async throws -> PersistentIdentifier {
        switch documentType {
        case .prescription:
            let parsedPrescription = try await aiService.uploadAndParseDocument(
                from: fileURL,
                as: ParsedPrescription.self
            )
            return try await repository.savePrescription(
                parsedPrescription,
                to: medicalCase,
                fileURL: fileURL
            )
            
        case .labResult, .bloodWork:
            let parsedBloodReport = try await aiService.uploadAndParseDocument(
                from: fileURL,
                as: ParsedBloodReport.self
            )
            return try await repository.saveBloodReport(
                parsedBloodReport,
                to: medicalCase,
                fileURL: fileURL
            )
        }
    }
    
    @MainActor
    private func updateProgress(_ progress: Double, _ status: String) {
        progressDelegate?.didUpdateProgress(progress, status: status)
    }
    
}

// MARK: - Default File Preparation Service

struct DefaultFilePreparationService: FilePreparationService {
    
    func prepareFile(from store: DocumentPickerStore) async throws -> URL {
        if let documentURL = store.selectedDocument {
            // For PDF files, return the URL directly
            return documentURL
        } else if let image = store.selectedImage {
            // Save image to temporary file
            let tempDir = FileManager.default.temporaryDirectory
            let fileName = "temp_image_\(Date().timeIntervalSince1970).jpg"
            let tempURL = tempDir.appendingPathComponent(fileName)
            
            guard let imageData = image.jpegData(compressionQuality: 0.8) else {
                throw DocumentProcessingError.imageProcessingFailed
            }
            
            try imageData.write(to: tempURL)
            return tempURL
        } else {
            throw DocumentProcessingError.noSelection
        }
    }
    
    func cleanupTemporaryFile(at url: URL) {
        // Only cleanup if it's in temp directory and we created it
        if url.path.contains("tmp") && url.lastPathComponent.hasPrefix("temp_") {
            try? FileManager.default.removeItem(at: url)
        }
    }
    
}
