//
//  PersistenceController.swift
//  Walnut
//
//  Created by Mayank Gandhi on 08/06/25.
//  Copyright © 2025 m. All rights reserved.
//


//
//  PersistenceController.swift
//  Cashew
//
//  Created by Mayank Gandhi on 07/05/25.
//  Copyright © 2025 m. All rights reserved.
//

import CloudKit
import Combine
import CoreData

class PersistenceController: ObservableObject {
    static let shared = PersistenceController()

    let container: NSPersistentCloudKitContainer

    init() {
        container = NSPersistentCloudKitContainer(name: "Walnut")

        // Configure CloudKit integration
        guard let description = container.persistentStoreDescriptions.first else {
            fatalError("Failed to retrieve a persistent store description")
        }

        // Enable CloudKit
        description.cloudKitContainerOptions = NSPersistentCloudKitContainerOptions(
            containerIdentifier: "iCloud.m.walnut"
        )

        // Configure history tracking for sync
        description.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
        description.setOption(true as NSNumber, forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)

        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Error loading persistent stores: \(error.localizedDescription)")
            }
        }

        // Enable automatic merging of changes
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }
}
