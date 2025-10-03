//
//  PatientNameScreen.swift
//  Walnut
//
//  Created by Claude on 23/09/25.
//  Copyright © 2025 m. All rights reserved.
//

import SwiftUI
import WalnutDesignSystem

/// Patient name screen for gathering patient's full name
struct PatientNameScreen: View {

    @Bindable var viewModel: OnboardingViewModel
    @State private var nameError: String?
    @FocusState private var isNameFocused: Bool

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: Spacing.xl) {

                OnboardingHeader(
                    icon: "person.circle.fill",
                    title: "Your Name",
                    subtitle: "What should we call you?"
                )

                // Name Input Section
                VStack(spacing: Spacing.large) {

                    // Friendly explanation
                    VStack(spacing: Spacing.medium) {
                        HStack {
                            Image(systemName: "person.badge.plus.fill")
                                .foregroundStyle(Color.healthPrimary)
                                .font(.title3)

                            Text("Personal Information")
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

                                Text("This will be displayed on your health records and used to personalize your experience.")
                                    .font(.system(.caption, design: .rounded))
                                    .foregroundStyle(.secondary)
                            }
                            .padding(.horizontal, Spacing.small)
                        }
                    }

                    // Name Input Field
                    TextFieldItem(
                        icon: "person.fill",
                        title: "Full Name",
                        text: $viewModel.patientSetupData.name,
                        placeholder: "Enter your full name",
                        helperText: "Please enter your first and last name",
                        errorMessage: nameError,
                        iconColor: Color.healthPrimary,
                        isRequired: true,
                        contentType: .name,
                        submitLabel: .next
                    )
                    .focused($isNameFocused)
                    .onSubmit {
                        validateAndProceed()
                    }
                }

                Spacer()
                    .frame(height: Spacing.xl)
            }
            .padding(.horizontal, Spacing.medium)
        }
        .onAppear {
            // Auto-focus the name field for better UX
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                isNameFocused = true
            }
        }
        .onChange(of: viewModel.patientSetupData.name) { _, newValue in
            // Clear error when user starts typing
            if !newValue.isEmpty && nameError != nil {
                nameError = nil
            }
            validateName(newValue)
        }
    }

    private func validateName(_ name: String) {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)

        if trimmedName.isEmpty {
            nameError = "Name is required"
            return
        }

        if trimmedName.count < 2 {
            nameError = "Name must be at least 2 characters"
            return
        }

        if trimmedName.count > 100 {
            nameError = "Name cannot exceed 100 characters"
            return
        }

        // Check for valid characters (letters, spaces, common name characters)
        let validNameCharacters = CharacterSet.letters
            .union(.whitespaces)
            .union(CharacterSet(charactersIn: "'-.,"))

        if !trimmedName.unicodeScalars.allSatisfy(validNameCharacters.contains) {
            nameError = "Name can only contain letters, spaces, and common punctuation"
            return
        }

        // Check for at least one letter
        if !trimmedName.contains(where: { $0.isLetter }) {
            nameError = "Name must contain at least one letter"
            return
        }

        nameError = nil
    }

    private func validateAndProceed() {
        validateName(viewModel.patientSetupData.name)

        if nameError == nil && !viewModel.patientSetupData.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            // Valid name, can proceed to next screen
            isNameFocused = false
        }
    }
}

// MARK: - Preview
#Preview {
    NavigationStack {
        PatientNameScreen(viewModel: OnboardingViewModel())
    }
}
