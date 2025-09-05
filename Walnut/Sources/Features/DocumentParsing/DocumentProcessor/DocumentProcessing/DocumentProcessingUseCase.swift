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

/// Encapsulates the business logic for document processing with clear separation of concerns
actor DocumentProcessingUseCase {
    
    private let aiService: UnifiedDocumentParsingService
    private let repository: DocumentRepositoryProtocol
    private let fileInputHandler: FileInputHandling
    private weak var progressDelegate: DocumentProcessingProgressDelegate?
    
    init(
        aiService: UnifiedDocumentParsingService,
        repository: DocumentRepositoryProtocol,
        fileInputHandler: FileInputHandling = FileInputHandler(),
        progressDelegate: DocumentProcessingProgressDelegate?
    ) {
        self.aiService = aiService
        self.repository = repository
        self.fileInputHandler = fileInputHandler
        self.progressDelegate = progressDelegate
    }
    
    /// Primary execute method with clean data input (no UI dependencies)
    func execute(
        input: DocumentProcessingInput
    ) async throws -> ProcessingResult {
        
        do {
            // Step 1: File Preparation
            let preparedFile = try await prepareFile(from: input)
            
            // Step 2: Document Processing  
            let stageData = DocumentProcessingStageData(
                preparedFile: preparedFile,
                medicalCase: input.medicalCase,
                documentType: input.documentType
            )
            
            let result = try await processDocument(stageData: stageData)
            return result
            
        } catch {
            throw mapError(error)
        }
    }
    
    /// Legacy method for backward compatibility with DocumentPickerStore
    func execute(
        from store: DocumentPickerStore,
        for medicalCase: MedicalCase,
        selectedDocumentType: DocumentType
    ) async throws -> ProcessingResult {
        
        let input = try DocumentProcessingInput.from(
            store: store,
            medicalCase: medicalCase,
            documentType: selectedDocumentType
        )
        
        return try await execute(input: input)
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
    
    // MARK: - Sequential Processing Chain
    
    private func prepareFile(from input: DocumentProcessingInput) async throws -> PreparedFileInput {
        await updateProgress(0.1, "Preparing file...")
        
        return try await fileInputHandler.prepareFile(
            from: input.fileSource,
            documentType: input.documentType,
            processingDate: input.processingDate
        )
    }
    
    private func processDocument(stageData: DocumentProcessingStageData) async throws -> ProcessingResult {
        await updateProgress(0.5, "Processing document...")
        
        do {
            let modelId = try await parseAndSaveDocument(
                fileURL: stageData.preparedFile.fileURL,
                documentType: stageData.documentType,
                medicalCase: stageData.medicalCase
            )
            
            await updateProgress(1.0, "Complete!")
            
            return ProcessingResult(
                documentType: stageData.documentType,
                modelId: modelId,
                originalFileName: stageData.preparedFile.originalFileName
            )
            
        } catch {
            // Fallback: Save as unparsed document
            return try await handleParsingFailure(
                stageData: stageData,
                error: error
            )
        }
    }
    
    private func handleParsingFailure(
        stageData: DocumentProcessingStageData,
        error: Error
    ) async throws -> ProcessingResult {
        await updateProgress(0.8, "Parsing failed, saving as unparsed document...")
        
        let modelId = try await saveUnparsedDocument(
            fileURL: stageData.preparedFile.fileURL,
            medicalCase: stageData.medicalCase,
            documentType: stageData.documentType
        )
        
        await updateProgress(1.0, "Document saved as unparsed!")
        
        return ProcessingResult(
            documentType: .unknown,
            modelId: modelId,
            originalFileName: stageData.preparedFile.originalFileName
        )
    }
    
    // MARK: - Private Methods
    
    private func parseAndSaveDocument(
        fileURL: URL,
        documentType: DocumentType,
        medicalCase: MedicalCase
    ) async throws -> PersistentIdentifier {
        switch documentType {
        case .prescription:
            let parsedPrescription = try await aiService.parseDocument(from: fileURL, as: ParsedPrescription.self)
            
            return try await repository.savePrescription(
                parsedPrescription,
                to: medicalCase,
                fileURL: fileURL
            )
            
        case .labResult:
            let parsedBloodReport = try await aiService.parseDocument(from: fileURL, as: ParsedBloodReport.self)
            
            return try await repository.saveBloodReport(
                parsedBloodReport,
                to: medicalCase,
                fileURL: fileURL
            )
            
        default:
            // For non-parsing documents, save them directly as documents
            return try await saveAsDocument(
                fileURL: fileURL,
                medicalCase: medicalCase,
                documentType: documentType
            )
        }
    }
    
    private func saveUnparsedDocument(
        fileURL: URL,
        medicalCase: MedicalCase,
        documentType: DocumentType
    ) async throws -> PersistentIdentifier {
        let documentFileManager = DocumentFileManager()
        let fileSize = try await documentFileManager.fileSize(at: fileURL)
        
        let document = Document(
            fileName: fileURL.lastPathComponent,
            fileURL: fileURL.lastPathComponent,
            documentType: documentType,
            fileSize: fileSize
        )
        
        return try await repository.saveUnparsedDocument(document, to: medicalCase)
    }
    
    private func saveAsDocument(
        fileURL: URL,
        medicalCase: MedicalCase,
        documentType: DocumentType
    ) async throws -> PersistentIdentifier {
        let documentFileManager = DocumentFileManager()
        let fileSize = try await documentFileManager.fileSize(at: fileURL)
        
        let document = Document(
            fileName: fileURL.lastPathComponent,
            fileURL: fileURL.lastPathComponent,
            documentType: documentType,
            fileSize: fileSize
        )
        
        return try await repository.saveDocument(document, to: medicalCase)
    }
    
    private func updateProgress(_ progress: Double, _ status: String) async {
        await progressDelegate?.didUpdateProgress(progress, status: status)
    }
    
}
