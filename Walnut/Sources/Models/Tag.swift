//
//  Tag.swift
//  Walnut
//
//  Created by Mayank Gandhi on 07/06/25.
//

import CoreData
import Foundation

// MARK: - Tag Entity
@objc(Tag)
public class Tag: NSManagedObject {
    @NSManaged public var id: UUID
    @NSManaged public var name: String
    @NSManaged public var color: String?
    @NSManaged public var createdAt: Date
    
    // Relationships
    @NSManaged public var documents: NSSet?
}


extension Tag {
    @objc(addDocumentsObject:)
    @NSManaged public func addToDocuments(_ value: Document)
    
    @objc(removeDocumentsObject:)
    @NSManaged public func removeFromDocuments(_ value: Document)
    
    @objc(addDocuments:)
    @NSManaged public func addToDocuments(_ values: NSSet)
    
    @objc(removeDocuments:)
    @NSManaged public func removeFromDocuments(_ values: NSSet)
}


// MARK: - Tag Extensions
extension Tag {
    
    /// Associated documents as array
    var documentsArray: [Document] {
        return documents?.allObjects as? [Document] ?? []
    }
    
    /// Document count
    var documentCount: Int {
        return documents?.count ?? 0
    }
    
    /// Convenience initializer
    convenience init(context: NSManagedObjectContext, name: String, color: String? = nil) {
        self.init(context: context)
        self.id = UUID()
        self.name = name
        self.color = color ?? "healthBlue"
        self.createdAt = Date()
    }
}
