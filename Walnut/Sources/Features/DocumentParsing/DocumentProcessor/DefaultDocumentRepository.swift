//
//  DefaultDocumentRepository.swift
//  Walnut
//
//  Created by Mayank Gandhi on 04/09/25.
//  Copyright © 2025 m. All rights reserved.
//

import SwiftData
import Foundation
import AIKit

/// Protocol for database operations
protocol DocumentRepositoryProtocol {
    var modelContext: ModelContext { get }
    func savePrescription(_ parsedPrescription: ParsedPrescription, to medicalCase: MedicalCase, fileURL: URL) async throws -> PersistentIdentifier
    func saveBioMarkerReport(_ parsedBioMarkerReport: ParsedBioMarkerReport, to medicalCase: MedicalCase?, fileURL: URL) async throws -> PersistentIdentifier
    func saveBioMarkerReportToPatient(_ parsedBioMarkerReport: ParsedBioMarkerReport, to patient: Patient, fileURL: URL) async throws -> PersistentIdentifier
    func saveDocument(_ document: Document, to medicalCase: MedicalCase) async throws -> PersistentIdentifier
    func saveUnparsedDocument(_ document: Document, to medicalCase: MedicalCase) async throws -> PersistentIdentifier
}

// MARK: - Default Document Repository
struct DefaultDocumentRepository: DocumentRepositoryProtocol {

    let modelContext: ModelContext

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

        // Update medical case timestamp to trigger UI refresh
        medicalCase.updatedAt = Date()

        try modelContext.save()
        return prescription.persistentModelID
    }
    
    @MainActor
    func saveBioMarkerReport(
        _ parsedBioMarkerReport: ParsedBioMarkerReport,
        to medicalCase: MedicalCase?,
        fileURL: URL
    ) async throws -> PersistentIdentifier {

        // Route to appropriate save method based on medicalCase presence
        if let medicalCase = medicalCase {
            return try await saveBioMarkerReportToMedicalCase(parsedBioMarkerReport, to: medicalCase, fileURL: fileURL)
        } else {
            // If no medical case provided, we need patient info - this should be handled at a higher level
            throw DocumentProcessingError.configurationError("No medical case provided for blood report saving")
        }
    }

    @MainActor
    func saveBioMarkerReportToPatient(
        _ parsedBioMarkerReport: ParsedBioMarkerReport,
        to patient: Patient,
        fileURL: URL
    ) async throws -> PersistentIdentifier {
        let bloodReport = BioMarkerReport(
            testName: parsedBioMarkerReport.testName,
            labName: parsedBioMarkerReport.labName,
            category: parsedBioMarkerReport.category,
            resultDate: parsedBioMarkerReport.resultDate,
            notes: parsedBioMarkerReport.notes
        )

        // Set patient relationship directly
        bloodReport.patient = patient

        // Create document
        let document = Document(
            fileName: fileURL.lastPathComponent,
            fileURL: fileURL.lastPathComponent,
            documentType: .biomarkerReport,
            fileSize: (try? FileManager.default.attributesOfItem(atPath: fileURL.path)[.size] as? Int64) ?? 0
        )
        bloodReport.document = document

        modelContext.insert(bloodReport)
        modelContext.insert(document)

        // Add test results after blood report is inserted
        let testResults = parsedBioMarkerReport.testResults.map { testResult in
            BioMarkerResult(
                testName: testResult.testName,
                value: testResult.value,
                unit: testResult.unit,
                referenceRange: testResult.referenceRange,
                isAbnormal: testResult.isAbnormal,
                bloodReport: bloodReport
            )
        }

        // Insert test results into model context
        testResults.forEach { modelContext.insert($0) }
        bloodReport.testResults = testResults

        // Update patient timestamp to trigger UI refresh
        patient.updatedAt = Date()

        try modelContext.save()
        return bloodReport.persistentModelID
    }

    @MainActor
    private func saveBioMarkerReportToMedicalCase(
        _ parsedBioMarkerReport: ParsedBioMarkerReport,
        to medicalCase: MedicalCase,
        fileURL: URL
    ) async throws -> PersistentIdentifier {
        let bloodReport = BioMarkerReport(
            testName: parsedBioMarkerReport.testName,
            labName: parsedBioMarkerReport.labName,
            category: parsedBioMarkerReport.category,
            resultDate: parsedBioMarkerReport.resultDate,
            notes: parsedBioMarkerReport.notes,
            medicalCase: medicalCase,
            fileURL: fileURL
        )
        modelContext.insert(bloodReport)

        // Add test results after blood report is inserted
        let testResults = parsedBioMarkerReport.testResults.map { testResult in
            BioMarkerResult(
                testName: testResult.testName,
                value: testResult.value,
                unit: testResult.unit,
                referenceRange: testResult.referenceRange,
                isAbnormal: testResult.isAbnormal,
                bloodReport: bloodReport
            )
        }

        // Insert test results into model context
        testResults.forEach { modelContext.insert($0) }
        bloodReport.testResults = testResults

        // Update medical case timestamp to trigger UI refresh
        medicalCase.updatedAt = Date()

        try modelContext.save()
        return bloodReport.persistentModelID
    }

    @MainActor
    func saveDocument(
        _ document: Document,
        to medicalCase: MedicalCase
    ) async throws -> PersistentIdentifier {
        modelContext.insert(document)
        
        // Add document to medical case's unparsed documents array
        medicalCase.otherDocuments?.append(document)
        
        // Update medical case timestamp to trigger UI refresh
        medicalCase.updatedAt = Date()
        
        try modelContext.save()
        return document.persistentModelID
    }
        
    @MainActor
    func saveUnparsedDocument(
        _ document: Document,
        to medicalCase: MedicalCase
    ) async throws -> PersistentIdentifier {
        modelContext.insert(document)
        
        // Add document to medical case's unparsed documents array
        medicalCase.unparsedDocuments?.append(document)
        
        // Update medical case timestamp to trigger UI refresh
        medicalCase.updatedAt = Date()
        
        try modelContext.save()
        return document.persistentModelID
    }
    
}
