//
//  LabResult.swift
//  Walnut
//
//  Created by Mayank Gandhi on 07/06/25.
//

import CoreData
import Foundation

// MARK: - Lab Result Entity
@objc(LabResult)
public class LabResult: NSManagedObject {
    // id
    @NSManaged public var id: UUID
    
    // Metadata
    @NSManaged public var createdAt: Date
    @NSManaged public var updatedAt: Date
    
    // Test Information
    @NSManaged public var testName: String
    @NSManaged public var resultDate: Date
    
    // Lab Information
    @NSManaged public var labName: String?
    
    // Result Status and Categories
    @NSManaged public var status: String // "normal", "abnormal", "critical", "pending"
    @NSManaged public var category: String? // "blood", "urine", "imaging", etc.
        
    // Relationships
    @NSManaged public var patient: Patient?
    @NSManaged public var document: Document?
    @NSManaged public var testResults: NSSet? // Individual test markers
    @NSManaged public var medicalRecord: MedicalRecord? // NEW: Associated medical record
}

extension LabResult {
    @objc(addTestResultsObject:)
    @NSManaged public func addToTestResults(_ value: TestResult)
    
    @objc(removeTestResultsObject:)
    @NSManaged public func removeFromTestResults(_ value: TestResult)
    
    @objc(addTestResults:)
    @NSManaged public func addToTestResults(_ values: NSSet)
    
    @objc(removeTestResults:)
    @NSManaged public func removeFromTestResults(_ values: NSSet)
}

// MARK: - LabResult Extensions
extension LabResult {
    
    /// Sorted test results
    var sortedTestResults: [TestResult] {
        let results = testResults?.allObjects as? [TestResult] ?? []
        return results.sorted { $0.markerName < $1.markerName }
    }
    
    /// Test results count
    var testResultCount: Int {
        return testResults?.count ?? 0
    }
    
    /// Check if result is abnormal
    var isAbnormal: Bool {
        return status.lowercased() == "abnormal" || status.lowercased() == "critical"
    }
    
    /// Status color
    var statusColor: String {
        switch status.lowercased() {
        case "normal":
            return "labNormal"
        case "abnormal":
            return "labWarning"
        case "critical":
            return "labCritical"
        default:
            return "textSecondary"
        }
    }
    
    /// Convenience initializer
    convenience init(context: NSManagedObjectContext, testName: String, patient: Patient) {
        self.init(context: context)
        self.id = UUID()
        self.testName = testName
        self.resultDate = Date()
        self.status = "pending"
        self.patient = patient
        self.createdAt = Date()
        self.updatedAt = Date()
    }
}
