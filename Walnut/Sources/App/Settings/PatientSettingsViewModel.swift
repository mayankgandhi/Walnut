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
    var showEditPatient = false
    var showAboutSheet = false
    var showNotificationSettings = false
    var showExportData = false
    var showPrivacySettings = false
    var showAppearanceSettings = false
    var showHelpSupport = false
    var showICloudSync = false
    
    // Loading and Error States
    var isLoading = false
    var error: Error?
    var showErrorAlert = false
    
    // Export Progress
    var isExporting = false
    var exportProgress: Double = 0.0
    var exportCompleted = false
    
    // iCloud Sync
    var iCloudSyncService = iCloudSyncService()
    
    // MARK: - Private Properties
    let patient: Patient
    private let modelContext: ModelContext?
    
    // MARK: - Computed Properties
    
    var patientName: String {
        return patient.name ?? "Unknown Patient"
    }
    
    var hasPatientData: Bool {
        return patient.name != nil
    }
    
    // MARK: - Initializer
    
    init(patient: Patient, modelContext: ModelContext? = nil) {
        self.patient = patient
        self.modelContext = modelContext
    }
    
    // MARK: - Navigation Actions
    
    func showEditPatientScreen() {
        showEditPatient = true
    }
    
    func dismissEditPatient() {
        showEditPatient = false
    }
    
    func showAbout() {
        showAboutSheet = true
    }
    
    func dismissAbout() {
        showAboutSheet = false
    }
    
    func showNotifications() {
        showNotificationSettings = true
        // TODO: Implement notification settings navigation
    }
    
    func showAppearance() {
        showAppearanceSettings = true
        // TODO: Implement appearance settings navigation
    }
    
    func showHelpAndSupport() {
        showHelpSupport = true
        // TODO: Implement help and support navigation
    }
    
    func showPrivacy() {
        showPrivacySettings = true
        // TODO: Implement privacy settings navigation
    }
    
    func showICloudSyncScreen() {
        showICloudSync = true
    }
    
    func dismissICloudSync() {
        showICloudSync = false
    }
    
    // MARK: - Data Operations
    
    @MainActor
    func exportPatientData() async {
        guard !isExporting else { return }
        
        isExporting = true
        exportProgress = 0.0
        error = nil
        
        do {
            // Simulate export process with progress updates
            for progress in stride(from: 0.0, through: 1.0, by: 0.1) {
                exportProgress = progress
                try await Task.sleep(for: .milliseconds(200))
            }
            
            // TODO: Implement actual export functionality
            // This would involve:
            // 1. Gathering patient data from medical cases
            // 2. Formatting data (PDF, JSON, etc.)
            // 3. Presenting share sheet or saving to files
            
            exportCompleted = true
            exportProgress = 1.0
            
        } catch {
            self.error = error
            showErrorAlert = true
        }
        
        isExporting = false
    }
    
    func resetExportState() {
        exportCompleted = false
        exportProgress = 0.0
        isExporting = false
    }
    
    // MARK: - Settings Menu Items
    
    func getPatientSettingsItems() -> [SettingsMenuItem] {
        return [
            SettingsMenuItem(
                icon: "pencil.circle.fill",
                title: "Edit Profile",
                subtitle: "Update patient information",
                iconColor: .healthPrimary,
                action: { [weak self] in
                    self?.showEditPatientScreen()
                }
            ),
            SettingsMenuItem(
                icon: "bell.fill",
                title: "Notifications",
                subtitle: "Manage alerts and reminders",
                iconColor: .orange,
                action: { [weak self] in
                    self?.showNotifications()
                }
            ),
            SettingsMenuItem(
                icon: "doc.fill",
                title: "Export Data",
                subtitle: "Export medical records",
                iconColor: .blue,
                action: { [weak self] in
                    Task {
                        await self?.exportPatientData()
                    }
                }
            ),
            SettingsMenuItem(
                icon: "shield.fill",
                title: "Privacy & Security",
                subtitle: "Data protection settings",
                iconColor: .green,
                action: { [weak self] in
                    self?.showPrivacy()
                }
            )
        ]
    }
    
    func getAppSettingsItems() -> [SettingsMenuItem] {
        return [
            SettingsMenuItem(
                icon: "icloud.fill",
                title: "iCloud Sync",
                subtitle: iCloudSyncService.isEnabled ? "Enabled - \(iCloudSyncService.syncStatus.displayText)" : "Keep your data in sync across devices",
                iconColor: .blue,
                action: { [weak self] in
                    self?.showICloudSyncScreen()
                }
            ),
            SettingsMenuItem(
                icon: "paintbrush.fill",
                title: "Appearance",
                subtitle: "Theme and display options",
                iconColor: .purple,
                action: { [weak self] in
                    self?.showAppearance()
                }
            ),
            SettingsMenuItem(
                icon: "info.circle.fill",
                title: "About",
                subtitle: "App version and info",
                iconColor: .gray,
                action: { [weak self] in
                    self?.showAbout()
                }
            ),
            SettingsMenuItem(
                icon: "questionmark.circle.fill",
                title: "Help & Support",
                subtitle: "Get help and contact support",
                iconColor: .healthPrimary,
                action: { [weak self] in
                    self?.showHelpAndSupport()
                }
            )
        ]
    }
    
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