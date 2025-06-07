//
//  Document.swift
//  Walnut
//
//  Created by Mayank Gandhi on 07/06/25.
//

import CoreData
import Foundation

// MARK: - Updated Document Entity
@objc(Document)
public class Document: NSManagedObject {
    @NSManaged public var id: UUID
    @NSManaged public var fileName: String
    @NSManaged public var fileURL: URL
    @NSManaged public var documentType: String
    @NSManaged public var uploadDate: Date

    @NSManaged public var rawAPIResponse: String?
    @NSManaged public var extractionError: String?
    
    @NSManaged public var thumbnailURL: URL?
    @NSManaged public var fileSize: Int64
    @NSManaged public var mimeType: String
    
    // Relationships
    @NSManaged public var labResults: NSSet?
    @NSManaged public var medicalRecords: NSSet?
    @NSManaged public var tags: NSSet?
    @NSManaged public var patient: Patient?
}

extension Document {
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
    
    @objc(addTagsObject:)
    @NSManaged public func addToTags(_ value: Tag)
    
    @objc(removeTagsObject:)
    @NSManaged public func removeFromTags(_ value: Tag)
    
    @objc(addTags:)
    @NSManaged public func addToTags(_ values: NSSet)
    
    @objc(removeTags:)
    @NSManaged public func removeFromTags(_ values: NSSet)
}
