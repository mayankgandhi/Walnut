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

