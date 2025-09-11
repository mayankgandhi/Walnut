//
//  DeleteAllDataViewModel.swift
//  Walnut
//
//  Created by Claude Code on 10/09/25.
//  Copyright © 2025 m. All rights reserved.
//

import SwiftUI
import SwiftData
import Observation

@Observable
class DeleteAllDataViewModel {
    
    // MARK: - Published Properties
    var showDeleteConfirmation = false
    var isDeleting = false
    var showDeleteSuccess = false
    
    // MARK: - Private Properties
    private let patient: Patient
    private let modelContext: ModelContext
    
    // MARK: - Initializer
    init(patient: Patient, modelContext: ModelContext) {
        self.patient = patient
        self.modelContext = modelContext
    }
    
    // MARK: - Public Properties
    var menuItem: SettingsMenuItem {
        SettingsMenuItem(
            icon: "trash.circle.fill",
            title: "Delete All Data",
            subtitle: "Permanently delete all patient data",
            iconColor: .healthError,
            action: { [weak self] in
                self?.presentDeleteConfirmation()
            }
        )
    }
    
    // MARK: - Actions
    func presentDeleteConfirmation() {
        showDeleteConfirmation = true
    }
    
    func dismissDeleteConfirmation() {
        showDeleteConfirmation = false
    }
    
    func confirmDelete() {
        isDeleting = true
        
        Task {
            await performDeleteAllData()
        }
    }
    
    @MainActor
    private func performDeleteAllData() async {
        do {
            // Erase all SwiftData
            try modelContext.container.erase()
            
            // Wipe out documents directory
            let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let contents = try FileManager.default.contentsOfDirectory(at: documentsURL, includingPropertiesForKeys: nil)
            
            for fileURL in contents {
                try FileManager.default.removeItem(at: fileURL)
            }
            
            isDeleting = false
            showDeleteConfirmation = false
            showDeleteSuccess = true
            
            UserDefaults.standard.set(false, forKey: "hasCompletedOnboarding")
            
            assert(false)
            
        } catch {
            isDeleting = false
            // Handle error - could add error state here
            print("Failed to delete data: \(error)")
        }
    }
    
    func dismissDeleteSuccess() {
        showDeleteSuccess = false
    }
}
