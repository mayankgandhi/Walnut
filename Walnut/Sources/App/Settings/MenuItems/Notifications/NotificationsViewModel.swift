//
//  NotificationsViewModel.swift
//  Walnut
//
//  Created by Claude Code on 10/09/25.
//  Copyright © 2025 m. All rights reserved.
//

import SwiftUI
import SwiftData
import Observation
import WalnutDesignSystem

@Observable
class NotificationsViewModel {
    
    // MARK: - Published Properties
    var showNotificationSettings = false
    
    // MARK: - Private Properties
    private let patient: Patient
    
    // MARK: - Initializer
    init(patient: Patient) {
        self.patient = patient
    }
    
    // MARK: - Public Properties
    var menuItem: SettingsMenuItem {
        SettingsMenuItem(
            icon: "bell.fill",
            title: "Notifications",
            subtitle: "Manage alerts and reminders",
            iconColor: .orange,
            action: { [weak self] in
                self?.presentNotificationSettings()
            }
        )
    }
    
    // MARK: - Actions
    func presentNotificationSettings() {
        showNotificationSettings = true
    }
    
    func dismissNotificationSettings() {
        showNotificationSettings = false
    }
    
    // MARK: - Sheet Content
    var notificationSettingsBottomSheetContent: some View {
        VStack(spacing: Spacing.medium) {
            // Header
            VStack(spacing: Spacing.xs) {
                Text("Medication Reminders")
                    .font(.title2.weight(.semibold))
                    .foregroundStyle(.primary)
                
                Text("Configure notifications and alarms for your medication schedule")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.top, Spacing.small)
        }
    }
}