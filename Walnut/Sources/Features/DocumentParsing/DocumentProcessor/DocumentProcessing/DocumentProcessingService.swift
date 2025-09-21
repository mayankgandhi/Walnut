//
//  DocumentProcessingService.swift
//  Walnut
//
//  Created by Mayank Gandhi on 29/07/25.
//  Copyright © 2025 m. All rights reserved.
//

import SwiftUI
import SwiftData
import Foundation
import AIKit
import PostHog

// MARK: - Protocols

/// Protocol for progress tracking
protocol DocumentProcessingProgressDelegate: AnyObject {
    @MainActor
    func didUpdateProgress(_ progress: Double, status: String)
    
    @MainActor
    func didCompleteProcessing(with result: Result<ProcessingResult, Error>)
}

// MARK: - Main Service

@Observable
class DocumentProcessingService {
    
    // MARK: - Dependencies
    
    private let aiService: UnifiedDocumentParsingService
    private let repository: DocumentRepositoryProtocol
    
    // MARK: - State
    
    var isProcessing = false
    var processingProgress: Double = 0.0
    var processingStatus: String = ""
    var lastError: Error?
    
    // MARK: - Delegates
    
    weak var progressDelegate: DocumentProcessingProgressDelegate?
    
    // MARK: - Initialization
    
    init(
        aiService: UnifiedDocumentParsingService,
        repository: DocumentRepositoryProtocol
    ) {
        self.aiService = aiService
        self.repository = repository
    }
    
    @MainActor
    func processDocument(
        from store: DocumentPickerStore,
        for medicalCase: MedicalCase?,
        patient: Patient,
        selectedDocumentType: DocumentType,
        onCompletion: @escaping (Result<ProcessingResult, Error>) -> Void
    ) {
        guard store.validateSelection() else {
            let error = DocumentProcessingError.noSelection
            handleProcessingCompletion(.failure(error))
            onCompletion(.failure(error))
            return
        }
        
        startProcessing()
        
        Task {
            do {
                let useCase = DocumentProcessingUseCase(
                    aiService: aiService,
                    repository: repository,
                    progressDelegate: self
                )
                
                let result = try await useCase.execute(
                    from: store,
                    for: medicalCase,
                    patient: patient,
                    selectedDocumentType: selectedDocumentType
                )
                
                await MainActor.run {
                    self.handleProcessingCompletion(.success(result))
                    onCompletion(.success(result))
                }
            } catch {
                await MainActor.run {
                    self.handleProcessingCompletion(.failure(error))
                    onCompletion(.failure(error))
                }
            }
        }
    }
    
    // MARK: - Private State Management
    
    @MainActor
    private func startProcessing() {
        isProcessing = true
        processingProgress = 0.0
        processingStatus = "Preparing document..."
        lastError = nil
    }
    
    @MainActor
    private func handleProcessingCompletion(_ result: Result<ProcessingResult, Error>) {
        isProcessing = false
        
        switch result {
        case .success:
            processingProgress = 1.0
            processingStatus = "Processing complete"
            lastError = nil
        case .failure(let error):
            lastError = error
            processingStatus = "Processing failed"
        }
        
        progressDelegate?.didCompleteProcessing(with: result)
    }
    
}

// MARK: - Progress Delegate Implementation

extension DocumentProcessingService: DocumentProcessingProgressDelegate {
    
    @MainActor
    func didUpdateProgress(_ progress: Double, status: String) {
        processingProgress = progress
        processingStatus = status
        
        // Update global upload state manager
        DocumentUploadStateManager.shared.updateProgress(progress, status: status)
    }
    
    @MainActor
    func didCompleteProcessing(with result: Result<ProcessingResult, Error>) {
        switch result {
        case .success(let processingResult):
            // Set the created document if available
            if let createdDocument = processingResult.createdDocument {
                DocumentUploadStateManager.shared.setCreatedDocument(createdDocument)
                DocumentUploadStateManager.shared.completeUpload()
            } else {
                DocumentUploadStateManager.shared
                    .setError(NSError(domain: "Document Upload Failed", code: -1))
            }
        case .failure(let error):
            DocumentUploadStateManager.shared.setError(error)
        }
    }
    
}


// MARK: - Supporting Types

struct ProcessingResult {
    let documentType: DocumentType
    let modelId: PersistentIdentifier
    let originalFileName: String
    let createdDocument: CreatedDocument?
}

// MARK: - Factory Methods

extension DocumentProcessingService {
    
    /// Creates a DocumentProcessingService using AIKit's unified parsing
    static func createWithAIKit(
        claudeKey: String,
        openAIKey: String,
        modelContext: ModelContext
    ) -> DocumentProcessingService {
    
        let aiService = AIKitFactory.createUnifiedService(
            claudeKey: claudeKey,
            openAIKey: openAIKey
        )
        let repository = DefaultDocumentRepository(modelContext: modelContext)
        
        return DocumentProcessingService(
            aiService: aiService,
            repository: repository
        )
    }
    
}
