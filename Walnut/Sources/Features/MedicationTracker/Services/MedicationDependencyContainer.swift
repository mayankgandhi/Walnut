//
//  MedicationDependencyContainer.swift
//  Walnut
//
//  Created by Mayank Gandhi on 10/09/25.
//  Copyright © 2025 m. All rights reserved.
//

import Foundation
import SwiftData
import SwiftUI

/// Dependency injection container for medication tracking services
final class MedicationDependencyContainer {
    
    // MARK: - Shared Instance
    
    static let shared = MedicationDependencyContainer()
    
    // MARK: - Private Properties
    
    private var scheduleServiceFactory: () -> MedicationScheduleServiceProtocol
    private var persistenceService: MedicationPersistenceServiceProtocol?
    
    // MARK: - Initialization
    
    private init() {
        // Default factory for schedule service
        self.scheduleServiceFactory = { MedicationScheduleService() }
    }
    
    // MARK: - Service Registration
    
    /// Register a custom schedule service factory
    func registerScheduleService(_ factory: @escaping () -> MedicationScheduleServiceProtocol) {
        self.scheduleServiceFactory = factory
    }
    
    /// Register a persistence service
    func registerPersistenceService(_ service: MedicationPersistenceServiceProtocol) {
        self.persistenceService = service
    }
    
    // MARK: - Service Resolution
    
    /// Resolve a schedule service instance
    func resolveScheduleService() -> MedicationScheduleServiceProtocol {
        return scheduleServiceFactory()
    }
    
    /// Resolve a persistence service instance
    func resolvePersistenceService() -> MedicationPersistenceServiceProtocol? {
        return persistenceService
    }
}

// MARK: - Persistence Service Protocol

/// Protocol for medication persistence operations
protocol MedicationPersistenceServiceProtocol {
    /// Save dose status update
    func saveDoseStatusUpdate(_ dose: ScheduledDose) async throws
    
    /// Save medication changes
    func saveMedicationChanges(_ medication: Medication) async throws
    
    /// Load medication history
    func loadMedicationHistory(for medication: Medication, limit: Int) async throws -> [ScheduledDose]
}

// MARK: - SwiftData Implementation

/// SwiftData implementation of the persistence service
final class SwiftDataMedicationPersistenceService: MedicationPersistenceServiceProtocol {
    
    private let modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    func saveDoseStatusUpdate(_ dose: ScheduledDose) async throws {
        // Implementation would save dose status to SwiftData
        // This is a placeholder for the actual persistence logic
        try modelContext.save()
    }
    
    func saveMedicationChanges(_ medication: Medication) async throws {
        medication.updatedAt = Date()
        try modelContext.save()
    }
    
    func loadMedicationHistory(for medication: Medication, limit: Int) async throws -> [ScheduledDose] {
        // Implementation would load historical dose data
        // This is a placeholder that returns empty array
        return []
    }
}

// MARK: - Environment Key for Dependency Injection

struct MedicationDependencyContainerKey: EnvironmentKey {
    static let defaultValue = MedicationDependencyContainer.shared
}

extension EnvironmentValues {
    var medicationContainer: MedicationDependencyContainer {
        get { self[MedicationDependencyContainerKey.self] }
        set { self[MedicationDependencyContainerKey.self] = newValue }
    }
}
