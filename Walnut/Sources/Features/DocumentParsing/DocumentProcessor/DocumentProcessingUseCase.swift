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
    private let repository: DocumentRepositoryProtocol
    private let documentFileManager: DocumentFileManager
    private weak var progressDelegate: DocumentProcessingProgressDelegate?
    
    init(
        aiService: UnifiedDocumentParsingService,
        repository: DocumentRepositoryProtocol,
        documentFileManager: DocumentFileManager = DocumentFileManager(),
        progressDelegate: DocumentProcessingProgressDelegate?
    ) {
        self.aiService = aiService
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
            // Step 1: Prepare file for processing and save locally
            await updateProgress(0.1, "Preparing file...")
            
            // Create local file URL based on selection type and save the file
            if let selectedDocument = store.selectedDocument {
                // Handle document file selection - save using URL method
                let localFileURL = try documentFileManager.saveDocument(
                    from: selectedDocument,
                    patientName: medicalCase.patient?.name ?? "Patient Name",
                    medicalCaseTitle: medicalCase.title ?? "Medical Case",
                    documentType: documentTypeToStorageType(selectedDocumentType),
                    date: Date()
                )
                // Use the local file as temp file for AI processing
                tempFileURL = localFileURL
                
            } else if let selectedImage = store.selectedImage {
                // Handle image selection - convert to data and save using Data method
                guard let imageData = selectedImage.jpegData(compressionQuality: 0.8) else {
                    throw DocumentProcessingError.filePreparationFailed(
                        NSError(
                            domain: "DocumentProcessing",
                            code: -1,
                            userInfo: [NSLocalizedDescriptionKey: "Failed to convert image to data"]
                        )
                    )
                }
                
                let fileName = "image_\(Int(Date().timeIntervalSince1970)).jpg"
                let localFileURL = try documentFileManager.saveDocument(
                    data: imageData,
                    patientName: medicalCase.patient?.name ?? "Patient Name",
                    medicalCaseTitle: medicalCase.title ?? "Medical Case",
                    documentType: documentTypeToStorageType(selectedDocumentType),
                    date: Date(),
                    fileName: fileName
                )
                // Use the local file as temp file for AI processing
                tempFileURL = localFileURL
                
            } else {
                throw DocumentProcessingError.filePreparationFailed(
                    NSError(domain: "DocumentProcessing", code: -1, 
                           userInfo: [NSLocalizedDescriptionKey: "No file selected"])
                )
            }
            
            // Step 2: Ensure directories exist (already done by saveDocument)
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
                    medicalCase: medicalCase,
                    documentType: selectedDocumentType
                )
                
                await updateProgress(1.0, "Document saved as unparsed!")
                
                return ProcessingResult(
                    documentType: .unknown, // We'll add this case
                    modelId: modelId,
                    originalFileName: tempFileURL?.lastPathComponent ?? "Unknown File"
                )
            }
            
        } catch {
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
            
            // File is already saved locally in the prepare step, just use the same URL
            return try await repository.savePrescription(
                parsedPrescription,
                to: medicalCase,
                fileURL: tempFileURL
            )
            
        case .labResult:
            let parsedBloodReport = try await aiService.parseDocument(from: tempFileURL, as: ParsedBloodReport.self)
            
            // File is already saved locally in the prepare step, just use the same URL
            return try await repository.saveBloodReport(
                parsedBloodReport,
                to: medicalCase,
                fileURL: tempFileURL
            )
            
        default:
            // This case is for non parsing documents, where we are just sharing
            return try await saveDocument(
                tempFileURL: tempFileURL,
                medicalCase: medicalCase,
                documentType: documentType
            )
            
        }
    }
    
    private func saveDocument(
        tempFileURL: URL,
        medicalCase: MedicalCase,
        documentType: DocumentType
    ) async throws -> PersistentIdentifier {
        // File is already saved locally in the prepare step
        // Create a Document record for unparsed document
        let fileSize = (try? FileManager.default.attributesOfItem(atPath: tempFileURL.path)[.size] as? Int64) ?? 0
        
        let document = Document(
            fileName: tempFileURL.lastPathComponent,
            fileURL: tempFileURL.lastPathComponent,
            documentType: documentType,
            fileSize: fileSize
        )
        
        // Add document to medical case's unparsed documents
        return try await repository.saveDocument(document, to: medicalCase)
    }
    
    private func saveUnparsedDocument(
        tempFileURL: URL,
        medicalCase: MedicalCase,
        documentType: DocumentType
    ) async throws -> PersistentIdentifier {
        // File is already saved locally in the prepare step
        // Create a Document record for unparsed document
        let fileSize = (try? FileManager.default.attributesOfItem(atPath: tempFileURL.path)[.size] as? Int64) ?? 0
        
        let document = Document(
            fileName: tempFileURL.lastPathComponent,
            fileURL: tempFileURL.lastPathComponent,
            documentType: documentType,
            fileSize: fileSize
        )
        
        // Add document to medical case's unparsed documents
        return try await repository.saveUnparsedDocument(document, to: medicalCase)
    }
    
    @MainActor
    private func updateProgress(_ progress: Double, _ status: String) {
        progressDelegate?.didUpdateProgress(progress, status: status)
    }
    
    private func documentTypeToStorageType(_ documentType: DocumentType) -> DocumentStorageType {
        switch documentType {
        case .prescription:
            return .prescription
        case .labResult:
            return .bloodReport
        default:
            return .otherDocuments
        }
    }
    
}
