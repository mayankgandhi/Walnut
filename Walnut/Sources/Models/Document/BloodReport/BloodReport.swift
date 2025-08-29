//
//  BloodReport.swift
//  Walnut
//
//  Created by Mayank Gandhi on 28/07/25.
//  Copyright © 2025 m. All rights reserved.
//

import Foundation
import SwiftData

@Model
class BloodReport: Identifiable, Sendable {
    
    @Attribute(.unique)
    var id: UUID?
    
    var testName: String?
    var labName: String?
    var category: String?
    var resultDate: Date?
    var notes: String?
    
    var createdAt: Date?
    var updatedAt: Date?
    
    var medicalCase: MedicalCase?
    
    @Relationship(deleteRule: .cascade, inverse: \Document.bloodReport)
    var document: Document?
    
    @Relationship(deleteRule: .cascade, inverse: \BloodTestResult.bloodReport)
    var testResults: [BloodTestResult] = []
    
    init(id: UUID = UUID(),
         testName: String,
         labName: String,
         category: String,
         resultDate: Date,
         notes: String = "",
         createdAt: Date = Date(),
         updatedAt: Date = Date(),
         medicalCase: MedicalCase,
         document: Document? = nil,
         testResults: [BloodTestResult] = []) {
        self.id = id
        self.testName = testName
        self.labName = labName
        self.category = category
        self.resultDate = resultDate
        self.notes = notes
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.medicalCase = medicalCase
        self.document = document
        self.testResults = testResults
    }
    
    convenience init(
        testName: String,
        labName: String,
        category: String,
        resultDate: Date,
        notes: String = "",
        medicalCase: MedicalCase,
        fileURL: URL,
        testResults: [BloodTestResult] = []
    ) {
        // Calculate actual file size
        let fileSize = (try? FileManager.default.attributesOfItem(atPath: fileURL.path)[.size] as? Int64) ?? 0
        
        self.init(
            testName: testName,
            labName: labName,
            category: category,
            resultDate: resultDate,
            notes: notes,
            medicalCase: medicalCase,
            document: Document(
                fileName: fileURL.lastPathComponent,
                fileURL: fileURL.lastPathComponent,
                documentType: .labResult,
                fileSize: fileSize
            ),
            testResults: testResults
        )
    }
}

// MARK: - Sample Data
extension BloodReport {
    @MainActor
    static func sampleReport(for medicalCase: MedicalCase) -> BloodReport {
        BloodReport(
            testName: "Complete Blood Count",
            labName: "LabCorp",
            category: "Hematology",
            resultDate: Date().addingTimeInterval(-86400 * 2),
            notes: "All values within normal range",
            medicalCase: medicalCase
        )
    }
}
