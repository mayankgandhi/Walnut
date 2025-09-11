//
//  PatientSetupScreen.swift
//  Walnut
//
//  Created by Claude on 11/09/25.
//  Copyright © 2025 m. All rights reserved.
//

import SwiftUI
import WalnutDesignSystem

/// Patient setup screen for gathering patient information
struct PatientSetupScreen: View {

    @Bindable var viewModel: OnboardingViewModel
    @State private var showingDatePicker = false
    
    private let genderOptions = ["Male", "Female", "Non-binary", "Prefer not to say"]
    private let bloodTypeOptions = ["A+", "A-", "B+", "B-", "AB+", "AB-", "O+", "O-", "Unknown"]
    
    var body: some View {
        ScrollView {
            VStack(spacing: Spacing.xl) {
                // Header
                VStack(spacing: Spacing.medium) {
                    Image(systemName: "person.circle.fill")
                        .font(.system(size: 50))
                        .foregroundStyle(Color.healthPrimary)
                    
                    Text("Patient Information")
                        .font(.largeTitle.bold())
                    
                    Text("Let's set up your patient profile")
                        .font(.body)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, Spacing.medium)
                }
                .padding(.top, Spacing.large)
                
                // Form Fields
                VStack(spacing: Spacing.medium) {
                    // Full Name
                    HealthCard {
                        VStack(spacing: Spacing.small) {
                            HStack {
                                Text("Full Name")
                                    .font(.headline)
                                    .foregroundStyle(.primary)
                                Spacer()
                                Text("*")
                                    .foregroundStyle(Color.healthError)
                            }
                            
                            TextField("Enter your full name", text: $viewModel.patientSetupData.name)
                                .textFieldStyle(.roundedBorder)
                                .textContentType(.name)
                        }
                    }
                    
                    // Date of Birth
                    HealthCard {
                        VStack(spacing: Spacing.small) {
                            HStack {
                                Text("Date of Birth")
                                    .font(.headline)
                                    .foregroundStyle(.primary)
                                Spacer()
                                Text("*")
                                    .foregroundStyle(Color.healthError)
                            }
                            
                            Button(action: { showingDatePicker = true }) {
                                HStack {
                                    if let dateOfBirth = viewModel.patientSetupData.dateOfBirth {
                                        Text(dateOfBirth, style: .date)
                                            .foregroundStyle(.primary)
                                    } else {
                                        Text("Select your date of birth")
                                            .foregroundStyle(.secondary)
                                    }
                                    
                                    Spacer()
                                    
                                    Image(systemName: "calendar")
                                        .foregroundStyle(Color.healthPrimary)
                                }
                                .padding()
                                .background(.quaternary.opacity(0.3), in: RoundedRectangle(cornerRadius: 8))
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    
                    // Gender
                    HealthCard {
                        VStack(spacing: Spacing.small) {
                            HStack {
                                Text("Gender")
                                    .font(.headline)
                                    .foregroundStyle(.primary)
                                Spacer()
                            }
                            
                            Picker("Gender", selection: $viewModel.patientSetupData.gender) {
                                Text("Select gender").tag("")
                                ForEach(genderOptions, id: \.self) { gender in
                                    Text(gender).tag(gender)
                                }
                            }
                            .pickerStyle(.menu)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                    
                    // Blood Type
                    HealthCard {
                        VStack(spacing: Spacing.small) {
                            HStack {
                                Text("Blood Type")
                                    .font(.headline)
                                    .foregroundStyle(.primary)
                                Spacer()
                            }
                            
                            Picker("Blood Type", selection: $viewModel.patientSetupData.bloodType) {
                                Text("Select blood type").tag("")
                                ForEach(bloodTypeOptions, id: \.self) { bloodType in
                                    Text(bloodType).tag(bloodType)
                                }
                            }
                            .pickerStyle(.menu)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                    
                    // Additional Notes
                    HealthCard {
                        VStack(spacing: Spacing.small) {
                            HStack {
                                Text("Additional Notes")
                                    .font(.headline)
                                    .foregroundStyle(.primary)
                                Spacer()
                                Text("Optional")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            
                            TextField(
                                "Allergies, medical conditions, or other important information...",
                                text: $viewModel.patientSetupData.notes,
                                axis: .vertical
                            )
                            .textFieldStyle(.roundedBorder)
                            .lineLimit(3...6)
                        }
                    }
                }
                
                // Validation Errors
                if !viewModel.validatePatientSetup().isEmpty {
                    HealthCard {
                        VStack(spacing: Spacing.small) {
                            HStack {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundStyle(Color.healthError)
                                
                                Text("Required Fields")
                                    .font(.headline)
                                    .foregroundStyle(Color.healthError)
                                
                                Spacer()
                            }
                            
                            VStack(alignment: .leading, spacing: Spacing.xs) {
                                ForEach(viewModel.validatePatientSetup(), id: \.self) { error in
                                    Text("• \(error)")
                                        .font(.body)
                                        .foregroundStyle(Color.healthError)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                }
                            }
                        }
                    }
                }
                
                Spacer()
                    .frame(height: Spacing.xl)
            }
        }
        .padding(.horizontal, Spacing.large)
        .sheet(isPresented: $showingDatePicker) {
            DatePickerSheet(selectedDate: $viewModel.patientSetupData.dateOfBirth)
        }
    }
}

// MARK: - Date Picker Sheet
private struct DatePickerSheet: View {
    @Binding var selectedDate: Date?
    @Environment(\.dismiss) private var dismiss
    
    @State private var tempDate = Date()
    
    var body: some View {
        NavigationStack {
            VStack {
                DatePicker(
                    "Date of Birth",
                    selection: $tempDate,
                    in: ...Date(),
                    displayedComponents: .date
                )
                .datePickerStyle(.wheel)
                .labelsHidden()
                
                Spacer()
            }
            .padding()
            .navigationTitle("Date of Birth")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        selectedDate = tempDate
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
        .presentationDetents([.medium])
        .onAppear {
            tempDate = selectedDate ?? Calendar.current.date(byAdding: .year, value: -30, to: Date()) ?? Date()
        }
    }
}

// MARK: - Preview
#Preview {
    NavigationStack {
        PatientSetupScreen(viewModel: OnboardingViewModel())
            .environment(OnboardingViewModel())
    }
}
