//
//  PatientDateOfBirthScreen.swift
//  Walnut
//
//  Created by Claude on 23/09/25.
//  Copyright © 2025 m. All rights reserved.
//

import SwiftUI
import WalnutDesignSystem

/// Patient date of birth screen for gathering patient's birth date
struct PatientDateOfBirthScreen: View {

    @Bindable var viewModel: OnboardingViewModel
    @State private var dateError: String?

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: Spacing.xl) {

                OnboardingHeader(
                    icon: "calendar.circle.fill",
                    title: "Date of Birth",
                    subtitle: "Help us personalize your health experience"
                )

                // Date of Birth Input Section
                VStack(spacing: Spacing.large) {

                    // Friendly explanation
                    VStack(spacing: Spacing.medium) {
                        HStack {
                            Image(systemName: "calendar.badge.plus")
                                .foregroundStyle(.blue)
                                .font(.title3)

                            Text("Birth Information")
                                .font(.title3.bold())
                                .foregroundStyle(.primary)

                            Spacer()
                        }
                        .padding(.horizontal, Spacing.small)

                        VStack(alignment: .leading, spacing: Spacing.small) {
                            HStack(spacing: Spacing.small) {
                                Image(systemName: "info.circle.fill")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)

                                Text("Used for age calculations, health assessments, and personalized health recommendations.")
                                    .font(.system(.caption, design: .rounded))
                                    .foregroundStyle(.secondary)
                            }
                            .padding(.horizontal, Spacing.small)
                        }
                    }

                    // Date of Birth Input Field
                    DatePickerItem(
                        icon: "calendar",
                        title: "Date of Birth",
                        selectedDate: $viewModel.patientSetupData.dateOfBirth,
                        helperText: "Select your birth date",
                        errorMessage: dateError,
                        iconColor: .blue,
                        isRequired: true
                    )

                    // Privacy Notice
                    VStack(spacing: Spacing.small) {
                        HStack(spacing: Spacing.small) {
                            Image(systemName: "lock.shield.fill")
                                .font(.caption)
                                .foregroundStyle(Color.healthSuccess)

                            Text("Your personal information is encrypted and stored securely on your device.")
                                .font(.system(.caption, design: .rounded))
                                .foregroundStyle(.secondary)
                        }
                        .padding(.horizontal, Spacing.small)
                    }
                    .padding(.vertical, Spacing.small)
                    .padding(.horizontal, Spacing.medium)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.healthSuccess.opacity(0.05))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.healthSuccess.opacity(0.2), lineWidth: 1)
                    )
                }

                Spacer()
                    .frame(height: Spacing.xl)
            }
            .padding(.horizontal, Spacing.medium)
        }
        .onChange(of: viewModel.patientSetupData.dateOfBirth) { _, newValue in
            validateDateOfBirth(newValue)
        }
    }

    private func validateDateOfBirth(_ date: Date?) {
        guard let date = date else {
            dateError = "Date of birth is required"
            return
        }

        let calendar = Calendar.current
        let now = Date()
        let minimumAge = calendar.date(byAdding: .year, value: -150, to: now) ?? now
        let maximumAge = calendar.date(byAdding: .year, value: -1, to: now) ?? now

        // Check if date is in the future
        if date > now {
            dateError = "Date of birth cannot be in the future"
            return
        }

        // Check for reasonable age limits
        if date < minimumAge {
            dateError = "Please enter a valid birth date"
            return
        }

        // Check if user is at least 1 year old (optional, depending on your use case)
        if date > maximumAge {
            dateError = "You must be at least 1 year old"
            return
        }

        dateError = nil
    }
}

// MARK: - Preview
#Preview {
    NavigationStack {
        PatientDateOfBirthScreen(viewModel: OnboardingViewModel())
    }
}
