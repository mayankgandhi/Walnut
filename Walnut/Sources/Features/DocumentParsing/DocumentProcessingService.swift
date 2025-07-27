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

@Observable
class DocumentProcessingService {
    
    // MARK: - Dependencies
    
    private let claudeService: ClaudeFilesService
    private let modelContext: ModelContext
    
    // MARK: - State
    
    var isProcessing = false
    var processingProgress: Double = 0.0
    var processingStatus: String = ""
    var lastError: Error?
    
    // MARK: - Initialization
    
    init(claudeService: ClaudeFilesService, modelContext: ModelContext) {
        self.claudeService = claudeService
        self.modelContext = modelContext
    }
    
    // MARK: - Public Interface
    
    @MainActor
    func processDocument(
        from store: DocumentPickerStore,
        for medicalCase: MedicalCase,
        onCompletion: @escaping (Result<ProcessingResult, Error>) -> Void
    ) {
        guard store.validateSelection() else {
            onCompletion(.failure(DocumentProcessingError.noSelection))
            return
        }
        
        isProcessing = true
        processingProgress = 0.0
        processingStatus = "Preparing document..."
        lastError = nil
        
        Task {
            do {
                let result = try await processDocumentAsync(from: store, for: medicalCase)
                await MainActor.run {
                    self.isProcessing = false
                    self.processingProgress = 1.0
                    self.processingStatus = "Processing complete"
                    onCompletion(.success(result))
                }
            } catch {
                await MainActor.run {
                    self.isProcessing = false
                    self.lastError = error
                    self.processingStatus = "Processing failed"
                    onCompletion(.failure(error))
                }
            }
        }
    }
    
    // MARK: - Private Processing Logic
    
    private func processDocumentAsync(
        from store: DocumentPickerStore,
        for medicalCase: MedicalCase
    ) async throws -> ProcessingResult {
        
        // Step 1: Prepare file for upload
        await updateProgress(0.1, "Preparing file for upload...")
        let fileURL = try await prepareFileForUpload(from: store)
        
        // Step 2: Upload to Claude
        await updateProgress(0.3, "Uploading document...")
        let uploadResponse = try await claudeService.uploadDocument(at: fileURL)
        
        // Step 3: Parse document based on type
        await updateProgress(0.6, "Parsing document...")
        let parsedResult = try await parseDocument(
            fileId: uploadResponse.id,
            documentType: store.selectedDocumentType
        )
        
        // Step 4: Save to SwiftData
        await updateProgress(0.8, "Saving to database...")
        let savedModel = try await saveToDatabase(
            parsedResult: parsedResult,
            medicalCase: medicalCase,
            originalFileURL: fileURL,
            documentType: store.selectedDocumentType
        )
        
        // Step 5: Cleanup
        await updateProgress(0.9, "Cleaning up...")
        try await claudeService.deleteDocument(fileId: uploadResponse.id)
        cleanupTemporaryFile(at: fileURL)
        
        await updateProgress(1.0, "Complete!")
        
        return ProcessingResult(
            documentType: store.selectedDocumentType,
            modelId: savedModel.persistentModelID,
            originalFileName: fileURL.lastPathComponent
        )
    }
    
    // MARK: - File Preparation
    
    private func prepareFileForUpload(from store: DocumentPickerStore) async throws -> URL {
        if let documentURL = store.selectedDocument {
            // For PDF files, copy to temp directory with access
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
    
    // MARK: - Document Parsing
    
    private func parseDocument(
        fileId: String,
        documentType: DocumentType
    ) async throws -> Any {
        switch documentType {
        case .prescription:
            return try await claudeService.parseDocument(
                fileId: fileId,
                as: ParsedPrescription.self
            )
            
        case .labResult, .bloodWork:
            return try await claudeService.parseDocument(
                fileId: fileId,
                as: ParsedBloodReport.self
            )
        }
    }
    
    // MARK: - Database Operations
    
    @MainActor
    private func saveToDatabase(
        parsedResult: Any,
        medicalCase: MedicalCase,
        originalFileURL: URL,
        documentType: DocumentType
    ) async throws -> any PersistentModel {
        
        switch (parsedResult, documentType) {
        case (let parsedPrescription as ParsedPrescription, .prescription):
            let prescription = Prescription(
                parsedPrescription: parsedPrescription,
                medicalCase: medicalCase,
                fileURL: originalFileURL
            )
            modelContext.insert(prescription)
            try modelContext.save()
            return prescription
            
        case (let parsedBloodReport as ParsedBloodReport, .labResult), 
             (let parsedBloodReport as ParsedBloodReport, .bloodWork):
            let bloodReport = BloodReport(
                id: UUID(),
                testName: parsedBloodReport.testName,
                labName: parsedBloodReport.labName,
                category: parsedBloodReport.category,
                resultDate: parsedBloodReport.resultDate,
                reportURL: originalFileURL.absoluteString,
                notes: parsedBloodReport.notes,
                medicalCase: medicalCase
            )
            modelContext.insert(bloodReport)
            
            // Add test results after blood report is inserted
            let testResults = parsedBloodReport.testResults.map { testResult in
                BloodTestResult(
                    testName: testResult.testName,
                    value: testResult.value,
                    unit: testResult.unit,
                    referenceRange: testResult.referenceRange,
                    isAbnormal: testResult.isAbnormal,
                    bloodReport: bloodReport
                )
            }
            testResults.forEach { modelContext.insert($0) }
            try modelContext.save()
            return bloodReport
            
        default:
            throw DocumentProcessingError.unsupportedDocumentType
        }
    }
    
    // MARK: - Utilities
    
    @MainActor
    private func updateProgress(_ progress: Double, _ status: String) {
        processingProgress = progress
        processingStatus = status
    }
    
    private func cleanupTemporaryFile(at url: URL) {
        // Only cleanup if it's in temp directory and we created it
        if url.path.contains("tmp") && url.lastPathComponent.hasPrefix("temp_") {
            try? FileManager.default.removeItem(at: url)
        }
    }
}

// MARK: - Supporting Types

struct ProcessingResult {
    let documentType: DocumentType
    let modelId: PersistentIdentifier
    let originalFileName: String
}

enum DocumentProcessingError: LocalizedError {
    case noSelection
    case imageProcessingFailed
    case unsupportedDocumentType
    case parsingFailed(String)
    case saveFailed(String)
    
    var errorDescription: String? {
        switch self {
        case .noSelection:
            return "No document or image selected"
        case .imageProcessingFailed:
            return "Failed to process the selected image"
        case .unsupportedDocumentType:
            return "The selected document type is not supported"
        case .parsingFailed(let message):
            return "Failed to parse document: \(message)"
        case .saveFailed(let message):
            return "Failed to save document: \(message)"
        }
    }
}

// MARK: - Environment Extension

extension EnvironmentValues {
    @Entry var documentProcessingService: DocumentProcessingService? = nil
}
