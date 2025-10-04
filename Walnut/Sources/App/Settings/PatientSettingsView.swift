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
                
//                HealthStackPro()
                
                // Patient Settings Section
                patientSettingsSection
                    .padding(.horizontal, Spacing.medium)
                
                // App Settings Section
                appSettingsSection
                    .padding(.horizontal, Spacing.medium)
                
                deadZoneSection
                    .padding(.horizontal, Spacing.medium)

                disclaimerSection
                    .padding(.horizontal, Spacing.medium)

                Spacer(minLength: Spacing.xl)
            }
        }
        .background {
            ContentBackgroundView(color: .blue)
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
                AboutView(patient: viewModel.patient)
                FAQView(patient: viewModel.patient)
                HelpSupportView(patient: viewModel.patient)
            }
        }
    }
    
    private var deadZoneSection: some View {
        VStack(alignment: .leading, spacing: Spacing.medium) {
            Text("Data")
                .font(.headline)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)

            VStack(spacing: Spacing.xs) {
                DeleteAllDataView(patient: viewModel.patient, modelContext: viewModel.modelContext)
            }
        }
    }

    private var disclaimerSection: some View {
        VStack(alignment: .leading, spacing: Spacing.small) {
            Text("Medical Disclaimer")
                .font(.headline)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)

            HealthCard {
                VStack(alignment: .leading, spacing: Spacing.small) {
                    Image(systemName: "info.circle.fill")
                        .font(.title2)
                        .foregroundStyle(.orange)

                    Text("This is a personal health journal app, not a medical or health tracking app. It is not intended to diagnose, treat, cure, or prevent any disease or medical condition.")
                        .font(.subheadline)
                        .foregroundStyle(.primary)
                        .fixedSize(horizontal: false, vertical: true)

                    Text("Please consult your personal medical health practitioners for any medical advice, diagnosis, or treatment. Always seek the advice of qualified health providers with any questions you may have regarding a medical condition.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }
}

