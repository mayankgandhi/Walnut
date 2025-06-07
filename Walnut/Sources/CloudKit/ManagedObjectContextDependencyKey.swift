//
//  ManagedObjectContextDependencyKey.swift
//  Walnut
//
//  Created by Mayank Gandhi on 08/06/25.
//  Copyright © 2025 m. All rights reserved.
//


import ComposableArchitecture
import CoreData
import SwiftUI

struct ManagedObjectContextDependencyKey: DependencyKey {
    static var liveValue: @Sendable () -> NSManagedObjectContext = {
        PersistenceController.shared.container.viewContext
    }
}

extension DependencyValues {
    var managedObjectContext: @Sendable () -> NSManagedObjectContext {
        get { self[ManagedObjectContextDependencyKey.self] }
        set { self[ManagedObjectContextDependencyKey.self] = newValue }
    }
}
