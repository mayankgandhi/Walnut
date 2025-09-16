//
//  PatientSettingsView.swift
//  Walnut
//
//  Created by Mayank Gandhi on 11/08/25.
//  Copyright © 2025 m. All rights reserved.
//

import SwiftUI
import SwiftData
import WalnutDesignSystem

struct PatientSettingsView: View {

    @State private var viewModel: PatientSettingsViewModel
    
    init(patient: Patient, modelContext: ModelContext) {
        self._viewModel = State(
            wrappedValue: PatientSettingsViewModel(
                patient: patient,
                modelContext: modelContext
            )
        )
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: Spacing.medium) {
                NavBarHeader(
                        iconName: "settings",
                        iconColor: .blue,
                        title: "Settings",
                        subtitle: "Add your details and preferences here."
                    )
            
                PatientHeaderCard(patient: viewModel.patient)
                            .padding(.horizontal, Spacing.medium)

                // Patient Settings Section
                patientSettingsSection
                            .padding(.horizontal, Spacing.medium)

                // App Settings Section
                appSettingsSection
                            .padding(.horizontal, Spacing.medium)

                Spacer(minLength: Spacing.xl)
            }
        }
        .alert("Error", isPresented: $viewModel.showErrorAlert) {
            Button("OK") {
                viewModel.dismissError()
            }
        } message: {
            Text(viewModel.error?.localizedDescription ?? "An unknown error occurred.")
        }
    }
    
    // MARK: - View Components
    
    private var patientSettingsSection: some View {
        VStack(alignment: .leading, spacing: Spacing.medium) {
            Text("Settings")
                .font(.headline)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            VStack(spacing: Spacing.xs) {
                EditProfileView(patient: viewModel.patient)
                NotificationsView(patient: viewModel.patient)
                PrivacySecurityView(patient: viewModel.patient)
                DeleteAllDataView(patient: viewModel.patient, modelContext: viewModel.modelContext)
            }
        }
    }
    
    private var appSettingsSection: some View {
        VStack(alignment: .leading, spacing: Spacing.medium) {
            Text("App Settings")
                .font(.headline)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            VStack(spacing: Spacing.xs) {
                AppearanceView(patient: viewModel.patient)
                ICloudSyncView(patient: viewModel.patient)
                AlarmSettingsView(patient: viewModel.patient)
                AboutView(patient: viewModel.patient)
                HelpSupportView(patient: viewModel.patient)
            }
        }
    }
}

