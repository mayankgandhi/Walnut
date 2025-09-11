//
//  AlarmSettingsView.swift
//  Walnut
//
//  Created by Claude Code on 10/09/25.
//  Copyright © 2025 m. All rights reserved.
//

import SwiftUI
import WalnutDesignSystem
import AlarmKit

struct AlarmSettingsView: View {
    @State private var viewModel: AlarmSettingsViewModel
    private let patient: Patient
    
    init(patient: Patient) {
        self.patient = patient
        self._viewModel = State(wrappedValue: AlarmSettingsViewModel(patient: patient))
    }
    
    var body: some View {
        MenuListItem(
            icon: viewModel.menuItem.icon,
            title: viewModel.menuItem.title,
            subtitle: viewModel.menuItem.subtitle,
            iconColor: viewModel.menuItem.iconColor
        ) {
            viewModel.presentAlarmSettings()
        }
        .sheet(isPresented: $viewModel.showAlarmSettings, onDismiss: {
            viewModel.dismissAlarmSettings()
        }) {
            AlarmSettingsDetailView(viewModel: viewModel)
        }
        .alert("Permission Required", isPresented: $viewModel.showPermissionAlert) {
            Button("Open Settings") {
                viewModel.openSystemSettings()
                viewModel.dismissPermissionAlert()
            }
            Button("Cancel", role: .cancel) {
                viewModel.dismissPermissionAlert()
            }
        } message: {
            Text("Medication alarms require permission to schedule notifications. Please enable alarms in Settings.")
        }
        .alert("Error", isPresented: $viewModel.showErrorAlert) {
            Button("OK") {
                viewModel.dismissError()
            }
        } message: {
            Text(viewModel.errorMessage ?? "An unknown error occurred.")
        }
    }
}

// MARK: - Alarm Settings Detail View

struct AlarmSettingsDetailView: View {
    let viewModel: AlarmSettingsViewModel
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Spacing.large) {
                    // Authorization Status Section
                    authorizationStatusSection
                    
                    // Active Alarms Section
                    if viewModel.isAuthorized {
                        activeAlarmsSection
                    }
                    
                    // Features Section
                    if viewModel.isAuthorized {
                        featuresSection
                    }
                    
                    // Instructions Section
                    instructionsSection
                }
                .padding(.horizontal, Spacing.medium)
                .padding(.top, Spacing.medium)
            }
            .navigationTitle("Medication Alarms")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        viewModel.dismissAlarmSettings()
                    }
                    .font(.system(size: 16, weight: .medium))
                }
            }
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
    }
    
    // MARK: - View Components
    
    @ViewBuilder
    private var authorizationStatusSection: some View {
        VStack(alignment: .leading, spacing: Spacing.small) {
            Text("Authorization Status")
                .font(.headline)
                .foregroundStyle(.secondary)
            
            HealthCard {
                HStack(spacing: Spacing.medium) {
                    // Status icon
                    Circle()
                        .fill(statusColor.opacity(0.15))
                        .frame(width: 40, height: 40)
                        .overlay {
                            Image(systemName: statusIcon)
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundStyle(statusColor)
                        }
                    
                    // Status details
                    VStack(alignment: .leading, spacing: 4) {
                        Text(statusTitle)
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.primary)
                        
                        Text(statusDescription)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    
                    Spacer()
                    
                    // Action button
                    if !viewModel.isAuthorized {
                        DSButton("Enable", style: .primary) {
                            viewModel.requestPermission()
                        }
                        .disabled(viewModel.isLoading)
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    private var activeAlarmsSection: some View {
        VStack(alignment: .leading, spacing: Spacing.small) {
            HStack {
                Text("Active Alarms")
                    .font(.headline)
                    .foregroundStyle(.secondary)
                
                Spacer()
                
                Text("\(viewModel.activeAlarmCount)")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.primary)
            }
            
            HealthCard {
                VStack(spacing: Spacing.medium) {
                    HStack(spacing: Spacing.medium) {
                        Image(systemName: "alarm.fill")
                            .font(.system(size: 24))
                            .foregroundStyle(.orange)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Medication Reminders")
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(.primary)
                            
                            Text("Alarms created from your medication schedule will appear here")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        
                        Spacer()
                    }
                    
                    if viewModel.activeAlarmCount > 0 {
                        Divider()
                        
                        DSButton("Cancel All Alarms", style: .secondary, icon: "xmark.circle") {
                            Task {
                                await viewModel.cancelAllAlarms()
                            }
                        }
                        .disabled(viewModel.isLoading)
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    private var featuresSection: some View {
        VStack(alignment: .leading, spacing: Spacing.small) {
            Text("Features")
                .font(.headline)
                .foregroundStyle(.secondary)
            
            VStack(spacing: Spacing.small) {
                featureItem(
                    icon: "bell.badge",
                    title: "Smart Reminders",
                    description: "Get notified when it's time to take your medication"
                )
                
                featureItem(
                    icon: "clock.arrow.2.circlepath",
                    title: "Snooze & Reschedule",
                    description: "Snooze reminders or reschedule if needed"
                )
                
                featureItem(
                    icon: "iphone.and.watch",
                    title: "Dynamic Island",
                    description: "Medication reminders appear in Dynamic Island and Live Activities"
                )
                
                featureItem(
                    icon: "checkmark.circle.fill",
                    title: "Quick Actions",
                    description: "Mark medications as taken directly from notifications"
                )
            }
        }
    }
    
    @ViewBuilder
    private var instructionsSection: some View {
        VStack(alignment: .leading, spacing: Spacing.small) {
            Text("How to Use")
                .font(.headline)
                .foregroundStyle(.secondary)
            
            HealthCard {
                VStack(alignment: .leading, spacing: Spacing.medium) {
                    instructionStep(
                        number: "1",
                        title: "Enable Permissions",
                        description: "Grant alarm permissions to receive medication reminders"
                    )
                    
                    instructionStep(
                        number: "2",
                        title: "Set Medication Schedule",
                        description: "Configure your medication frequencies in the medication tracker"
                    )
                    
                    instructionStep(
                        number: "3",
                        title: "Automatic Alarms",
                        description: "Alarms are automatically created based on your medication schedule"
                    )
                    
                    instructionStep(
                        number: "4",
                        title: "Manage from Lock Screen",
                        description: "Mark as taken, snooze, or open the app directly from notifications"
                    )
                }
            }
        }
    }
    
    // MARK: - Helper Views
    
    @ViewBuilder
    private func featureItem(icon: String, title: String, description: String) -> some View {
        HealthCard {
            HStack(spacing: Spacing.medium) {
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundStyle(Color.healthPrimary)
                    .frame(width: 24)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.primary)
                    
                    Text(description)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
            }
        }
    }
    
    @ViewBuilder
    private func instructionStep(number: String, title: String, description: String) -> some View {
        HStack(spacing: Spacing.medium) {
            // Step number
            Circle()
                .fill(Color.healthPrimary.opacity(0.15))
                .frame(width: 32, height: 32)
                .overlay {
                    Text(number)
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(Color.healthPrimary)
                }
            
            // Step content
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.primary)
                
                Text(description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
        }
    }
    
    // MARK: - Computed Properties
    
    private var statusColor: Color {
        switch viewModel.authorizationState {
        case .authorized: return .healthSuccess
        case .denied: return .healthError
        case .notDetermined: return .healthWarning
        @unknown default: return .secondary
        }
    }
    
    private var statusIcon: String {
        switch viewModel.authorizationState {
        case .authorized: return "checkmark.circle.fill"
        case .denied: return "xmark.circle.fill"
        case .notDetermined: return "questionmark.circle.fill"
        @unknown default: return "exclamationmark.circle.fill"
        }
    }
    
    private var statusTitle: String {
        switch viewModel.authorizationState {
        case .authorized: return "Authorized"
        case .denied: return "Permission Denied"
        case .notDetermined: return "Permission Required"
        @unknown default: return "Unknown Status"
        }
    }
    
    private var statusDescription: String {
        switch viewModel.authorizationState {
        case .authorized: return "Medication alarms are enabled and ready to use"
        case .denied: return "Please enable alarm permissions in System Settings"
        case .notDetermined: return "Tap Enable to allow medication alarm notifications"
        @unknown default: return "Check your system settings"
        }
    }
}

#Preview {
    AlarmSettingsView(patient: .samplePatient)
}
