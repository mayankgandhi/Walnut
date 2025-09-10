//
//  PatientSettingsViewModel.swift
//  Walnut
//
//  Created by Mayank Gandhi on 29/08/25.
//  Copyright © 2025 m. All rights reserved.
//

import SwiftUI
import SwiftData
import Observation
import CloudKit

@Observable
class PatientSettingsViewModel {
    
    // MARK: - Published Properties
    
    // Loading and Error States
    var isLoading = false
    var error: Error?
    var showErrorAlert = false
    
    // MARK: - Properties
    let patient: Patient
    let modelContext: ModelContext
    
    
    init(patient: Patient, modelContext: ModelContext) {
        self.patient = patient
        self.modelContext = modelContext
    }
    
    // MARK: - Computed Properties
    
    var patientName: String {
        return patient.name ?? "Unknown Patient"
    }
    
    var hasPatientData: Bool {
        return patient.name != nil
    }
    
    // MARK: - Initializer

    // MARK: - Settings Menu Items
    
    
    // MARK: - Error Handling
    
    func dismissError() {
        error = nil
        showErrorAlert = false
    }
    
    func handleError(_ error: Error) {
        self.error = error
        showErrorAlert = true
    }
}

// MARK: - Supporting Types

struct SettingsMenuItem: Identifiable {
    let id = UUID()
    let icon: String
    let title: String
    let subtitle: String
    let iconColor: Color
    let action: () -> Void
}

// MARK: - Extensions

extension PatientSettingsViewModel {
    
    /// Get app version information
    var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
    }
    
    /// Get app build number
    var buildNumber: String {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "Unknown"
    }
    
    /// Get app display name
    var appName: String {
        Bundle.main.infoDictionary?["CFBundleDisplayName"] as? String ?? "Walnut"
    }
}
