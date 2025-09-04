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
    func savePrescription(_ parsedPrescription: ParsedPrescription, to medicalCase: MedicalCase, fileURL: URL) async throws -> PersistentIdentifier
    func saveBloodReport(_ parsedBloodReport: ParsedBloodReport, to medicalCase: MedicalCase, fileURL: URL) async throws -> PersistentIdentifier
    func saveDocument(_ document: Document, to medicalCase: MedicalCase) async throws -> PersistentIdentifier
    func saveUnparsedDocument(_ document: Document, to medicalCase: MedicalCase) async throws -> PersistentIdentifier
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
        
        // Insert test results into model context
        testResults.forEach { modelContext.insert($0) }
        
        // IMPORTANT: Add test results to the blood report's testResults array
        // This establishes the bidirectional relationship properly
        bloodReport.testResults?.append(contentsOf: testResults)
        
        // CRUCIAL: Add blood report to the medical case's bloodReports array
        // This establishes the bidirectional relationship between MedicalCase and BloodReport
        medicalCase.bloodReports?.append(bloodReport)
        
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
        
        try modelContext.save()
        return document.persistentModelID
    }
    
}
