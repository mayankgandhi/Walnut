//
//  DocumentUploadStateManager.swift
//  Walnut
//
//  Created by Mayank Gandhi on 04/09/25.
//  Copyright © 2025 m. All rights reserved.
//

import SwiftUI
import SwiftData
import PostHog

// MARK: - Created Document Type
enum CreatedDocument {
    case prescription(Prescription)
    case bioMarkerReport(BioMarkerReport)
}

@Observable
class DocumentUploadStateManager {

    static let shared = DocumentUploadStateManager()

    private init() {}

    var isUploading = false
    var documentType: DocumentType?
    var uploadState: UploadViewBottomAccessory.UploadViewBottomAccessoryState = .preparing
    var progress: Double = 0.0
    var statusText: String?
    var error: Error?
    var createdDocument: CreatedDocument?

    private var processingService: DocumentProcessingService?
    
    func initializeProcessingService(claudeAIKey: String, openAIKey: String, modelContext: ModelContext) {   
        self.processingService = DocumentProcessingService.createWithAIKit(
            claudeKey: claudeAIKey,
            openAIKey: openAIKey,
            modelContext: modelContext
        )
    }
    
    @MainActor func processDocument(
        from store: DocumentPickerStore,
        for medicalCase: MedicalCase?,
        patient: Patient,
        selectedDocumentType: DocumentType
    ) {
        guard let processingService = processingService else {
            setError(DocumentProcessingError.configurationError("Processing service not initialized"))
            return
        }
        
        startUpload(documentType: selectedDocumentType)
        
        processingService.processDocument(
            from: store,
            for: medicalCase,
            patient: patient,
            selectedDocumentType: selectedDocumentType
        ) { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self.completeUpload()
                case .failure(let error):
                    self.setError(error)
                }
            }
        }
    }
    
    private func startUpload(documentType: DocumentType) {
        self.isUploading = true
        self.documentType = documentType
        self.uploadState = .preparing
        self.progress = 0.0
        self.statusText = nil
        self.error = nil
        self.createdDocument = nil
    }
    
    func updateProgress(_ progress: Double, status: String) {
        self.progress = progress
        self.statusText = status
        
        // Update state based on progress
        switch progress {
        case 0.0..<0.4:
            self.uploadState = .preparing
        case 0.4..<0.8:
            self.uploadState = .uploading
        case 0.8..<1.0:
            self.uploadState = .parsing
        case 1.0:
            self.uploadState = .completed
            hideAfterDelay()
        default:
            break
        }
    }
    
    func setError(_ error: Error) {
        self.error = error
        self.uploadState = .failed
        hideAfterDelay()
    }
    
    func completeUpload() {
        self.uploadState = .completed
        self.progress = 1.0
        hideAfterDelay()
    }
    
    private func hideAfterDelay() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            if self.uploadState == .completed || self.uploadState == .failed {
                self.reset()
            }
        }
    }
    
    func setCreatedDocument(_ document: CreatedDocument) {
        self.createdDocument = document
    }

    private func reset() {
        self.isUploading = false
        self.documentType = nil
        self.uploadState = .preparing
        self.progress = 0.0
        self.statusText = nil
        self.error = nil
        self.createdDocument = nil
    }
}
