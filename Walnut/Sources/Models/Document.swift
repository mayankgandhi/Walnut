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

// MARK: - Document Extensions
extension Document {
    
    /// File size formatted as string
    var formattedFileSize: String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useKB, .useMB, .useGB]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: fileSize)
    }
    
    /// Check if document is a PDF
    var isPDF: Bool {
        return mimeType.lowercased() == "application/pdf"
    }
    
    /// Check if document is an image
    var isImage: Bool {
        return mimeType.lowercased().hasPrefix("image/")
    }
    
    /// Associated tags as array
    var tagsArray: [Tag] {
        return tags?.allObjects as? [Tag] ?? []
    }
    
    /// Convenience initializer
    convenience init(context: NSManagedObjectContext, fileName: String, fileURL: URL, patient: Patient) {
        self.init(context: context)
        self.id = UUID()
        self.fileName = fileName
        self.fileURL = fileURL
        self.uploadDate = Date()
        self.patient = patient
        
        // Set document type based on file extension
        let fileExtension = fileURL.pathExtension.lowercased()
        switch fileExtension {
        case "pdf":
            self.documentType = "lab_report"
            self.mimeType = "application/pdf"
        case "jpg", "jpeg":
            self.documentType = "image"
            self.mimeType = "image/jpeg"
        case "png":
            self.documentType = "image"
            self.mimeType = "image/png"
        default:
            self.documentType = "other"
            self.mimeType = "application/octet-stream"
        }
    }
}
