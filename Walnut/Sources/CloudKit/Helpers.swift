//
//  Helpers.swift
//  Walnut
//
//  Created by Mayank Gandhi on 08/06/25.
//  Copyright © 2025 m. All rights reserved.
//

import CoreData
import Foundation

// MARK: - NSManagedObjectContext Extensions
extension NSManagedObjectContext {
    
    /// Performs a save operation with error handling
    func saveWithErrorHandling() {
        guard hasChanges else { return }
        
        do {
            try save()
        } catch {
            // Handle the error appropriately
            print("Core Data save error: \(error)")
            
            // Rollback changes on error
            rollback()
            
            // You might want to present this error to the user
            // or log it to your analytics service
        }
    }
    
    /// Fetch objects with a simple predicate
    func fetch<T: NSManagedObject>(_ entity: T.Type, predicate: NSPredicate? = nil, sortDescriptors: [NSSortDescriptor] = []) -> [T] {
        let request = NSFetchRequest<T>(entityName: String(describing: entity))
        request.predicate = predicate
        request.sortDescriptors = sortDescriptors
        
        do {
            return try fetch(request)
        } catch {
            print("Fetch error: \(error)")
            return []
        }
    }
    
    /// Count objects matching a predicate
    func count<T: NSManagedObject>(_ entity: T.Type, predicate: NSPredicate? = nil) -> Int {
        let request = NSFetchRequest<T>(entityName: String(describing: entity))
        request.predicate = predicate
        
        do {
            return try count(for: request)
        } catch {
            print("Count error: \(error)")
            return 0
        }
    }
}

// MARK: - NSManagedObject Extensions
extension NSManagedObject {
    
    /// Delete the object from its context
    func delete() {
        managedObjectContext?.delete(self)
    }
    
    /// Check if object exists in the persistent store
    var isTemporary: Bool {
        return objectID.isTemporaryID
    }
    
    /// Get entity name as string
    static var entityName: String {
        return String(describing: self)
    }
}










