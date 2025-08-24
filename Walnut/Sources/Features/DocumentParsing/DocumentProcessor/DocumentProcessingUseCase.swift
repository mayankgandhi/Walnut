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

// MARK: - Supporting Types

enum DocumentStorageType {
    case prescription
    case bloodReport
    case unparsed
    
    var folderName: String {
        switch self {
        case .prescription:
            return "Prescriptions"
        case .bloodReport:
            return "BloodReports"
        case .unparsed:
            return "UnparsedDocuments"
        }
    }
}

/// Service responsible for managing local document storage with organized folder structure
/// Folder structure: <Patient>/<MedicalCase>/<PrescriptionDate|BloodReportDate|UnparsedDocument>
struct DocumentFileManager {
    
    private let fileManager = FileManager.default
    
    /// Base directory for all patient documents
    private var documentsDirectory: URL {
        fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
            .appendingPathComponent("WalnutMedicalRecords")
    }
    
    // MARK: - Public Methods
    
    /// Saves a document file locally with the organized folder structure
    /// - Parameters:
    ///   - sourceURL: Source file URL to copy from
    ///   - patientName: Patient's full name for folder structure
    ///   - medicalCaseTitle: Medical case title for folder structure
    ///   - documentType: Type of document (prescription, bloodReport, unparsed)
    ///   - date: Date for file naming (prescription date, blood report date, or current date for unparsed)
    ///   - fileName: Original file name
    /// - Returns: Local file URL where the document was saved
    func saveDocument(
        from sourceURL: URL,
        patientName: String,
        medicalCaseTitle: String,
        documentType: DocumentStorageType,
        date: Date,
        fileName: String
    ) throws -> URL {
        
        // Create folder structure
        let patientFolder = createPatientFolder(patientName: patientName)
        let caseFolder = createMedicalCaseFolder(in: patientFolder, caseTitle: medicalCaseTitle)
        let documentFolder = createDocumentTypeFolder(in: caseFolder, type: documentType)
        
        // Generate unique file name with date
        let fileExtension = sourceURL.pathExtension
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd_HH-mm-ss"
        let dateString = dateFormatter.string(from: date)
        
        let sanitizedFileName = sanitizeFileName(fileName)
        let finalFileName = "\(dateString)_\(sanitizedFileName).\(fileExtension)"
        let destinationURL = documentFolder.appendingPathComponent(finalFileName)
        
        // Copy file to destination
        try copyFile(from: sourceURL, to: destinationURL)
        
        return destinationURL
    }
    
    /// Saves an unparsed document when parsing fails
    /// - Parameters:
    ///   - sourceURL: Source file URL to copy from
    ///   - patientName: Patient's full name for folder structure
    ///   - medicalCaseTitle: Medical case title for folder structure
    ///   - fileName: Original file name
    /// - Returns: Local file URL where the document was saved
    func saveUnparsedDocument(
        from sourceURL: URL,
        patientName: String,
        medicalCaseTitle: String,
        fileName: String
    ) throws -> URL {
        return try saveDocument(
            from: sourceURL,
            patientName: patientName,
            medicalCaseTitle: medicalCaseTitle,
            documentType: .unparsed,
            date: Date(),
            fileName: fileName
        )
    }
    
    /// Creates all necessary directories if they don't exist
    func ensureDirectoriesExist() throws {
        try fileManager.createDirectory(
            at: documentsDirectory,
            withIntermediateDirectories: true,
            attributes: nil
        )
    }
    
    /// Gets the folder path for a specific patient and medical case
    func getFolderPath(patientName: String, medicalCaseTitle: String) -> URL {
        let patientFolder = documentsDirectory
            .appendingPathComponent(sanitizeFileName(patientName))
        let caseFolder = patientFolder
            .appendingPathComponent(sanitizeFileName(medicalCaseTitle))
        return caseFolder
    }
    
    /// Checks if a file exists at the given URL
    func fileExists(at url: URL) -> Bool {
        return fileManager.fileExists(atPath: url.path)
    }
    
    // MARK: - Private Methods
    
    private func createPatientFolder(patientName: String) -> URL {
        let patientFolderName = sanitizeFileName(patientName)
        let patientFolder = documentsDirectory.appendingPathComponent(patientFolderName)
        
        try? fileManager.createDirectory(
            at: patientFolder,
            withIntermediateDirectories: true,
            attributes: nil
        )
        
        return patientFolder
    }
    
    private func createMedicalCaseFolder(in patientFolder: URL, caseTitle: String) -> URL {
        let caseFolderName = sanitizeFileName(caseTitle)
        let caseFolder = patientFolder.appendingPathComponent(caseFolderName)
        
        try? fileManager.createDirectory(
            at: caseFolder,
            withIntermediateDirectories: true,
            attributes: nil
        )
        
        return caseFolder
    }
    
    private func createDocumentTypeFolder(in caseFolder: URL, type: DocumentStorageType) -> URL {
        let typeFolder = caseFolder.appendingPathComponent(type.folderName)
        
        try? fileManager.createDirectory(
            at: typeFolder,
            withIntermediateDirectories: true,
            attributes: nil
        )
        
        return typeFolder
    }
    
    private func copyFile(from sourceURL: URL, to destinationURL: URL) throws {
        // Remove existing file if it exists
        if fileManager.fileExists(atPath: destinationURL.path) {
            try fileManager.removeItem(at: destinationURL)
        }
        
        // Copy the file
        try fileManager.copyItem(at: sourceURL, to: destinationURL)
    }
    
    /// Sanitizes file/folder names to be safe for file system
    private func sanitizeFileName(_ name: String) -> String {
        let invalidCharacters = CharacterSet(charactersIn: ":/\\?%*|\"<>")
        return name
            .components(separatedBy: invalidCharacters)
            .joined(separator: "_")
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

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
