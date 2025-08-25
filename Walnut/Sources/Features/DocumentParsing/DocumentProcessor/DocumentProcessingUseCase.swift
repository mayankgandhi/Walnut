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
    
    private let aiService: UnifiedDocumentParsingService
    private let fileService: FilePreparationService
    private let repository: DocumentRepositoryProtocol
    private let documentFileManager: DocumentFileManager
    private weak var progressDelegate: DocumentProcessingProgressDelegate?
    
    init(
        aiService: UnifiedDocumentParsingService,
        fileService: FilePreparationService,
        repository: DocumentRepositoryProtocol,
        documentFileManager: DocumentFileManager = DocumentFileManager(),
        progressDelegate: DocumentProcessingProgressDelegate?
    ) {
        self.aiService = aiService
        self.fileService = fileService
        self.repository = repository
        self.documentFileManager = documentFileManager
        self.progressDelegate = progressDelegate
    }
    
    func execute(
        from store: DocumentPickerStore,
        for medicalCase: MedicalCase,
        selectedDocumentType: DocumentType
    ) async throws -> ProcessingResult {
        
        var tempFileURL: URL?
        
        do {
            // Step 1: Prepare file for processing
            await updateProgress(0.1, "Preparing file...")
            tempFileURL = try await fileService.prepareFile(from: store)
            
            // Step 2: Ensure directories exist
            await updateProgress(0.2, "Setting up storage...")
            try documentFileManager.ensureDirectoriesExist()
            
            // Step 3: Parse document using AI service
            await updateProgress(0.4, "Parsing document...")
            
            do {
                let modelId = try await parseAndSaveDocument(
                    tempFileURL: tempFileURL!,
                    documentType: selectedDocumentType,
                    medicalCase: medicalCase
                )
                
                // Step 4: Cleanup temp file
                await updateProgress(0.9, "Cleaning up...")
                if let tempFileURL = tempFileURL {
                    fileService.cleanupTemporaryFile(at: tempFileURL)
                }
                
                await updateProgress(1.0, "Complete!")
                
                return ProcessingResult(
                    documentType: selectedDocumentType,
                    modelId: modelId,
                    originalFileName: tempFileURL?.lastPathComponent ?? "Unknown File"
                )
                
            } catch {
                // Step 4: If parsing fails, save as unparsed document
                await updateProgress(0.6, "Parsing failed, saving as unparsed document...")
                let modelId = try await saveUnparsedDocument(
                    tempFileURL: tempFileURL!,
                    medicalCase: medicalCase
                )
                
                // Step 5: Cleanup temp file
                await updateProgress(0.9, "Cleaning up...")
                if let tempFileURL = tempFileURL {
                    fileService.cleanupTemporaryFile(at: tempFileURL)
                }
                
                await updateProgress(1.0, "Document saved as unparsed!")
                
                return ProcessingResult(
                    documentType: .unknown, // We'll add this case
                    modelId: modelId,
                    originalFileName: tempFileURL?.lastPathComponent ?? "Unknown File"
                )
            }
            
        } catch {
            // Cleanup on error
            if let tempFileURL = tempFileURL {
                fileService.cleanupTemporaryFile(at: tempFileURL)
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
        tempFileURL: URL,
        documentType: DocumentType,
        medicalCase: MedicalCase
    ) async throws -> PersistentIdentifier {
        switch documentType {
        case .prescription:
            let parsedPrescription = try await aiService.parseDocument(from: tempFileURL, as: ParsedPrescription.self)
            
            // Save file locally with organized structure
            let localFileURL = try documentFileManager.saveDocument(
                from: tempFileURL,
                patientName: medicalCase.patient.fullName,
                medicalCaseTitle: medicalCase.title,
                documentType: DocumentStorageType.prescription,
                date: parsedPrescription.dateIssued,
                fileName: tempFileURL.lastPathComponent
            )
            
            return try await repository.savePrescription(
                parsedPrescription,
                to: medicalCase,
                fileURL: localFileURL
            )
            
        case .labResult:
            let parsedBloodReport = try await aiService.parseDocument(from: tempFileURL, as: ParsedBloodReport.self)
            
            // Save file locally with organized structure
            let localFileURL = try documentFileManager.saveDocument(
                from: tempFileURL,
                patientName: medicalCase.patient.fullName,
                medicalCaseTitle: medicalCase.title,
                documentType: DocumentStorageType.bloodReport,
                date: parsedBloodReport.resultDate,
                fileName: tempFileURL.lastPathComponent
            )
            
            return try await repository.saveBloodReport(
                parsedBloodReport,
                to: medicalCase,
                fileURL: localFileURL
            )
            
        default:
            // This case shouldn't be reached in normal parsing flow, but added for exhaustiveness
            throw DocumentProcessingError.parsingFailed(
                NSError(domain: "DocumentProcessing",
                        code: -1,
                        userInfo: [NSLocalizedDescriptionKey: "Cannot parse unknown document type"])
            )
        }
    }
    
    private func saveUnparsedDocument(
        tempFileURL: URL,
        medicalCase: MedicalCase
    ) async throws -> PersistentIdentifier {
        // Save file locally as unparsed document
        let localFileURL = try documentFileManager.saveUnparsedDocument(
            from: tempFileURL,
            patientName: medicalCase.patient.fullName,
            medicalCaseTitle: medicalCase.title,
            fileName: tempFileURL.lastPathComponent
        )
        
        // Create a Document record for unparsed document
        let fileSize = (try? FileManager.default.attributesOfItem(atPath: localFileURL.path)[.size] as? Int64) ?? 0
        let document = Document(
            fileName: tempFileURL.lastPathComponent,
            fileURL: localFileURL,
            documentType: .labResult,
            fileSize: fileSize
        )
        
        // Add document to medical case's unparsed documents
        return try await repository.saveUnparsedDocument(document, to: medicalCase)
    }
    
    @MainActor
    private func updateProgress(_ progress: Double, _ status: String) {
        progressDelegate?.didUpdateProgress(progress, status: status)
    }
    
}
