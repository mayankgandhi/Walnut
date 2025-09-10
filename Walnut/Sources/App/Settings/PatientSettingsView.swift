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
            VStack(spacing: Spacing.large) {
                PatientHeaderCard(patient: viewModel.patient)
                
                // Patient Settings Section
                patientSettingsSection
                
                // App Settings Section
                appSettingsSection
                
                Spacer(minLength: Spacing.xl)
            }
            .padding(.horizontal, Spacing.medium)
            .padding(.top, Spacing.medium)
        }
        .sheet(isPresented: $viewModel.showICloudSync, onDismiss: {
            viewModel.dismissICloudSync()
        }) {
            DSBottomSheet(title: "iCloud Sync"){
                iCloudSyncBottomSheetContent
            } content: {
                iCloudSyncSettingsView()
            }
            .presentationDetents([.height(600), .large])
            .presentationDragIndicator(.visible)
        }
        .alert("Error", isPresented: $viewModel.showErrorAlert) {
            Button("OK") {
                viewModel.dismissError()
            }
        } message: {
            Text(viewModel.error?.localizedDescription ?? "An unknown error occurred.")
        }
        .navigationTitle("Settings")
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
                AboutView(patient: viewModel.patient)
                HelpSupportView(patient: viewModel.patient)
            }
        }
    }
    
    private var iCloudSyncBottomSheetContent: some View {
        VStack(spacing: Spacing.medium) {
            // Header
            VStack(spacing: Spacing.xs) {
                Text("iCloud Sync")
                    .font(.title2.weight(.semibold))
                    .foregroundStyle(.primary)
                
                Text("Keep your medical data synchronized across all your devices")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.top, Spacing.small)
        }
    }
}

