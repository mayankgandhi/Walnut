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
    
    init(patient: Patient) {
        self._viewModel = State(wrappedValue: PatientSettingsViewModel(patient: patient))
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: Spacing.large) {
                PatientHeaderCard(patient: viewModel.patient)
                
                // Patient Settings Section
                settingsSection(
                    title: "Settings",
                    items: viewModel.getPatientSettingsItems()
                )
                
                // App Settings Section
                settingsSection(
                    title: "App Settings",
                    items: viewModel.getAppSettingsItems()
                )
                
                // Export Progress (if exporting)
                if viewModel.isExporting {
                    exportProgressView
                }
                
                Spacer(minLength: Spacing.xl)
            }
            .padding(.horizontal, Spacing.medium)
            .padding(.top, Spacing.medium)
        }
        .sheet(isPresented: $viewModel.showEditPatient, onDismiss: {
            viewModel.dismissEditPatient()
        }) {
            PatientEditor(patient: viewModel.patient)
        }
        .sheet(isPresented: $viewModel.showAboutSheet, onDismiss: {
            viewModel.dismissAbout()
        }) {
            AboutSheet()
                .presentationDetents([.medium])
                .presentationCornerRadius(Spacing.large)
                .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $viewModel.showICloudSync, onDismiss: {
            viewModel.dismissICloudSync()
        }) {
            iCloudSyncSettingsView()
        }
        .alert("Export Complete", isPresented: $viewModel.exportCompleted) {
            Button("OK") {
                viewModel.resetExportState()
            }
        } message: {
            Text("Patient data has been successfully exported.")
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
    
    @ViewBuilder
    private func settingsSection(title: String, items: [SettingsMenuItem]) -> some View {
        VStack(alignment: .leading, spacing: Spacing.medium) {
            Text(title)
                .font(.headline)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            VStack(spacing: Spacing.xs) {
                ForEach(items) { item in
                    MenuListItem(
                        icon: item.icon,
                        title: item.title,
                        subtitle: item.subtitle,
                        iconColor: item.iconColor
                    ) {
                        item.action()
                    }
                }
            }
        }
    }
    
    private var exportProgressView: some View {
        VStack(spacing: Spacing.medium) {
            Text("Exporting Data...")
                .font(.headline)
                .foregroundStyle(.secondary)
            
            ProgressView(value: viewModel.exportProgress)
                .progressViewStyle(LinearProgressViewStyle())
                .scaleEffect(1.2)
            
            Text("\(Int(viewModel.exportProgress * 100))%")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(Spacing.medium)
        .background(
            RoundedRectangle(cornerRadius: Spacing.medium)
                .fill(.regularMaterial)
        )
        .padding(.horizontal, Spacing.medium)
    }
}

#Preview("Patient Settings") {
    NavigationStack {
        PatientSettingsView(patient: .samplePatient)
    }
    .modelContainer(for: Patient.self, inMemory: true)
}

#Preview("Patient Settings - With Medications") {
    NavigationStack {
        PatientSettingsView(patient: .samplePatientWithMedications)
    }
    .modelContainer(for: Patient.self, inMemory: true)
}
