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

// MARK: - Protocols

/// Protocol for AI document operations
protocol AIDocumentServiceProtocol {
    func uploadAndParseDocument<T: Codable>(from url: URL, as type: T.Type, structDefinition: String?) async throws -> T
}

/// Protocol for progress tracking
protocol DocumentProcessingProgressDelegate: AnyObject {
    @MainActor func didUpdateProgress(_ progress: Double, status: String)
    @MainActor func didCompleteProcessing(with result: Result<ProcessingResult, Error>)
}

/// Protocol for file operations
protocol FilePreparationService {
    func prepareFile(from store: DocumentPickerStore) async throws -> URL
    func cleanupTemporaryFile(at url: URL)
}

/// Protocol for database operations
protocol DocumentRepositoryProtocol {
    func savePrescription(_ parsedPrescription: ParsedPrescription, to medicalCase: MedicalCase, fileURL: URL) async throws -> PersistentIdentifier
    func saveBloodReport(_ parsedBloodReport: ParsedBloodReport, to medicalCase: MedicalCase, fileURL: URL) async throws -> PersistentIdentifier
}

// MARK: - Main Service

@Observable
class DocumentProcessingService {
    
    // MARK: - Dependencies
    
    private let aiService: AIDocumentServiceProtocol
    private let fileService: FilePreparationService
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
        aiService: AIDocumentServiceProtocol,
        fileService: FilePreparationService,
        repository: DocumentRepositoryProtocol
    ) {
        self.aiService = aiService
        self.fileService = fileService
        self.repository = repository
    }
    
    // MARK: - Public Interface
    
    @MainActor
    func processDocument(
        from store: DocumentPickerStore,
        for medicalCase: MedicalCase,
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
                    fileService: fileService,
                    repository: repository,
                    progressDelegate: self
                )
                
                let result = try await useCase.execute(from: store, for: medicalCase)
                
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
    }
    
    @MainActor
    func didCompleteProcessing(with result: Result<ProcessingResult, Error>) {
        // Additional handling can be added here if needed
    }
}

// MARK: - Default Document Repository

struct DefaultDocumentRepository: DocumentRepositoryProtocol {
    
    private let modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    
    @MainActor
    func savePrescription(
        _ parsedPrescription: ParsedPrescription,
        to medicalCase: MedicalCase,
        fileURL: URL
    ) async throws -> PersistentIdentifier {
        let prescription = Prescription(
            parsedPrescription: parsedPrescription,
            medicalCase: medicalCase,
            fileURL: fileURL
        )
        modelContext.insert(prescription)
        try modelContext.save()
        return prescription.persistentModelID
    }
    
    @MainActor
    func saveBloodReport(
        _ parsedBloodReport: ParsedBloodReport,
        to medicalCase: MedicalCase,
        fileURL: URL
    ) async throws -> PersistentIdentifier {
        let bloodReport = BloodReport(
            testName: parsedBloodReport.testName,
            labName: parsedBloodReport.labName,
            category: parsedBloodReport.category,
            resultDate: parsedBloodReport.resultDate,
            notes: parsedBloodReport.notes,
            medicalCase: medicalCase,
            fileURL: fileURL
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
        return bloodReport.persistentModelID
    }
    
}

// MARK: - Protocol Extensions

extension ClaudeDocumentService: AIDocumentServiceProtocol {
    // The existing ClaudeDocumentService already implements the required methods
}

extension OpenAIDocumentService: AIDocumentServiceProtocol {
    // The existing OpenAIDocumentService already implements the required methods
}

// MARK: - Supporting Types

struct ProcessingResult {
    let documentType: DocumentType
    let modelId: PersistentIdentifier
    let originalFileName: String
}

// MARK: - Factory Methods

extension DocumentProcessingService {
    
    /// Creates a DocumentProcessingService with default implementations using OpenAI
    static func createWithOpenAI(
        apiKey: String,
        modelContext: ModelContext
    ) -> DocumentProcessingService {
        let aiService = OpenAIDocumentService(apiKey: apiKey)
        let fileService = DefaultFilePreparationService()
        let repository = DefaultDocumentRepository(modelContext: modelContext)
        
        return DocumentProcessingService(
            aiService: aiService,
            fileService: fileService,
            repository: repository
        )
    }
    
    /// Creates a DocumentProcessingService with default implementations using Claude
    static func createWithClaude(
        apiKey: String,
        modelContext: ModelContext
    ) -> DocumentProcessingService {
        let aiService = ClaudeDocumentService(apiKey: apiKey)
        let fileService = DefaultFilePreparationService()
        let repository = DefaultDocumentRepository(modelContext: modelContext)
        
        return DocumentProcessingService(
            aiService: aiService,
            fileService: fileService,
            repository: repository
        )
    }
}

// MARK: - Environment Extension

extension EnvironmentValues {
    @Entry var documentProcessingService: DocumentProcessingService? = nil
}
