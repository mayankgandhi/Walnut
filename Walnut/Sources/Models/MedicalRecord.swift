//
//  MedicalRecord.swift
//  Walnut
//
//  Created by Mayank Gandhi on 07/06/25.
//


import CoreData
import Foundation

// MARK: - Merged Medical Record Entity
@objc(MedicalRecord)
public class MedicalRecord: NSManagedObject {
    @NSManaged public var id: UUID
    
    // Basic Record Information
    @NSManaged public var recordType: String // "visit_summary", "prescription", "diagnosis", "procedure", "immunization", "lab_report"
    @NSManaged public var date: Date
    @NSManaged public var title: String
    @NSManaged public var summary: String?
    
    // Clinical Information
    @NSManaged public var providerName: String?
    
    // General notes and status
    @NSManaged public var notes: String?

    @NSManaged public var createdAt: Date
    @NSManaged public var updatedAt: Date
    
    // Relationships
    @NSManaged public var document: Document?
    @NSManaged public var patient: Patient?
    @NSManaged public var labResults: NSSet? // NEW: Associated lab results
}

// NEW: MedicalRecord extensions for lab results
extension MedicalRecord {
    @objc(addLabResultsObject:)
    @NSManaged public func addToLabResults(_ value: LabResult)
    
    @objc(removeLabResultsObject:)
    @NSManaged public func removeFromLabResults(_ value: LabResult)
    
    @objc(addLabResults:)
    @NSManaged public func addToLabResults(_ values: NSSet)
    
    @objc(removeLabResults:)
    @NSManaged public func removeFromLabResults(_ values: NSSet)
}
