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
class BloodReport: Identifiable {
    
    @Attribute(.unique)
    var id: UUID
    
    var testName: String
    var labName: String
    var category: String
    var resultDate: Date
    var reportURL: String?
    var notes: String
    
    var createdAt: Date
    var updatedAt: Date
    
    var medicalCase: MedicalCase
    
    @Relationship(deleteRule: .cascade)
    var testResults: [BloodTestResult] = []
    
    init(id: UUID = UUID(),
         testName: String,
         labName: String,
         category: String,
         resultDate: Date,
         reportURL: String? = nil,
         notes: String = "",
         createdAt: Date = Date(),
         updatedAt: Date = Date(),
         medicalCase: MedicalCase,
         testResults: [BloodTestResult] = []) {
        self.id = id
        self.testName = testName
        self.labName = labName
        self.category = category
        self.resultDate = resultDate
        self.reportURL = reportURL
        self.notes = notes
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.medicalCase = medicalCase
        self.testResults = testResults
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
