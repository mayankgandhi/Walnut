//
//  Patient.swift
//  Walnut
//
//  Created by Mayank Gandhi on 07/06/25.
//

import CoreData
import Foundation

// MARK: - Updated Patient Entity
@objc(Patient)
public class Patient: NSManagedObject {

    @NSManaged public var id: UUID
    @NSManaged public var firstName: String
    @NSManaged public var lastName: String
    @NSManaged public var dateOfBirth: Date?
    @NSManaged public var gender: String?
    @NSManaged public var bloodType: String?
    @NSManaged public var emergencyContactName: String?
    @NSManaged public var emergencyContactPhone: String?

    @NSManaged public var insuranceProvider: String?
    @NSManaged public var insurancePolicyNumber: String?

    @NSManaged public var medicalRecordNumber: String?

    @NSManaged public var notes: String?
    @NSManaged public var isActive: Bool
    @NSManaged public var createdAt: Date
    @NSManaged public var updatedAt: Date
    
    // Relationships
    @NSManaged public var documents: NSSet?
    @NSManaged public var labResults: NSSet?
    @NSManaged public var medicalRecords: NSSet?
    @NSManaged public var testResults: NSSet? // Direct access to individual test results
}


// MARK: - Core Data Extensions
extension Patient {
    @objc(addDocumentsObject:)
    @NSManaged public func addToDocuments(_ value: Document)
    
    @objc(removeDocumentsObject:)
    @NSManaged public func removeFromDocuments(_ value: Document)
    
    @objc(addDocuments:)
    @NSManaged public func addToDocuments(_ values: NSSet)
    
    @objc(removeDocuments:)
    @NSManaged public func removeFromDocuments(_ values: NSSet)
    
    @objc(addLabResultsObject:)
    @NSManaged public func addToLabResults(_ value: LabResult)
    
    @objc(removeLabResultsObject:)
    @NSManaged public func removeFromLabResults(_ value: LabResult)
    
    @objc(addLabResults:)
    @NSManaged public func addToLabResults(_ values: NSSet)
    
    @objc(removeLabResults:)
    @NSManaged public func removeFromLabResults(_ values: NSSet)
    
    @objc(addMedicalRecordsObject:)
    @NSManaged public func addToMedicalRecords(_ value: MedicalRecord)
    
    @objc(removeMedicalRecordsObject:)
    @NSManaged public func removeFromMedicalRecords(_ value: MedicalRecord)
    
    @objc(addMedicalRecords:)
    @NSManaged public func addToMedicalRecords(_ values: NSSet)
    
    @objc(removeMedicalRecords:)
    @NSManaged public func removeFromMedicalRecords(_ values: NSSet)
    
    @objc(addTestResultsObject:)
    @NSManaged public func addToTestResults(_ value: TestResult)
    
    @objc(removeTestResultsObject:)
    @NSManaged public func removeFromTestResults(_ value: TestResult)
    
    @objc(addTestResults:)
    @NSManaged public func addToTestResults(_ values: NSSet)
    
    @objc(removeTestResults:)
    @NSManaged public func removeFromTestResults(_ values: NSSet)
}
