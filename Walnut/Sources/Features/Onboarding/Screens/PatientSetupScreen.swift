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
    
    // Define options as enums that conform to CustomStringConvertible
    private enum GenderOption: String, CaseIterable, CustomStringConvertible {
        case male = "Male"
        case female = "Female"
        case nonBinary = "Non-binary"
        case preferNotToSay = "Prefer not to say"
        
        var description: String { rawValue }
    }
    
    private enum BloodTypeOption: String, CaseIterable, CustomStringConvertible {
        case aPositive = "A+"
        case aNegative = "A-"
        case bPositive = "B+"
        case bNegative = "B-"
        case abPositive = "AB+"
        case abNegative = "AB-"
        case oPositive = "O+"
        case oNegative = "O-"
        case unknown = "Unknown"
        
        var description: String { rawValue }
    }
    
    // State for picker selections
    @State private var selectedGender: GenderOption?
    @State private var selectedBloodType: BloodTypeOption?
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: Spacing.xl) {
                
                OnboardingHeader(
                    icon:  "person.circle.fill",
                    title: "Patient Information",
                    subtitle: "Let's set up your patient profile with some basic information")
                
                // Form Fields with improved design
                VStack(spacing: Spacing.large) {
                    // Personal Information Section
                    VStack(alignment: .leading, spacing: Spacing.medium) {
                        HStack {
                            Image(systemName: "person.2.fill")
                                .foregroundStyle(Color.healthPrimary)
                                .font(.title3)
                            
                            Text("Personal Information")
                                .font(.title3.bold())
                                .foregroundStyle(.primary)
                            
                            Spacer()
                        }
                        .padding(.horizontal, Spacing.small)
                        
                        VStack(spacing: Spacing.medium) {
                            // Full Name
                            TextFieldItem(
                                icon: "person.fill",
                                title: "Full Name",
                                text: $viewModel.patientSetupData.name,
                                placeholder: "Enter your full name",
                                helperText: "This will be displayed on your health records",
                                iconColor: Color.healthPrimary,
                                isRequired: true,
                                contentType: .name
                            )
                            
                            // Date of Birth
                            DatePickerItem(
                                icon: "calendar",
                                title: "Date of Birth",
                                selectedDate: $viewModel.patientSetupData.dateOfBirth,
                                helperText: "Used for age calculations and health assessments",
                                iconColor: .blue,
                                isRequired: true
                            )
                        }
                    }
                    
                    // Medical Information Section
                    VStack(alignment: .leading, spacing: Spacing.medium) {
                        HStack {
                            Image(systemName: "heart.text.square.fill")
                                .foregroundStyle(.red)
                                .font(.title3)
                            
                            Text("Medical Information")
                                .font(.title3.bold())
                                .foregroundStyle(.primary)
                            
                            Spacer()
                        }
                        .padding(.horizontal, Spacing.small)
                        
                        VStack(spacing: Spacing.medium) {
                            // Gender
                            MenuPickerItem(
                                icon: "person.fill",
                                title: "Gender",
                                selectedOption: $selectedGender,
                                options: GenderOption.allCases,
                                placeholder: "Select your gender",
                                helperText: "Optional - used for health recommendations",
                                iconColor: .purple
                            )
                            
                            // Blood Type
                            MenuPickerItem(
                                icon: "drop.fill",
                                title: "Blood Type",
                                selectedOption: $selectedBloodType,
                                options: BloodTypeOption.allCases,
                                placeholder: "Select your blood type",
                                helperText: "Important for emergency situations",
                                iconColor: .red
                            )
                        }
                    }
                    
                    // Additional Information Section
                    VStack(alignment: .leading, spacing: Spacing.medium) {
                        HStack {
                            Image(systemName: "note.text")
                                .foregroundStyle(.orange)
                                .font(.title3)
                            
                            Text("Additional Information")
                                .font(.title3.bold())
                                .foregroundStyle(.primary)
                            
                            Spacer()
                        }
                        .padding(.horizontal, Spacing.small)
                        
                        VStack(spacing: Spacing.medium) {
                            // Additional Notes - Custom multi-line field
                            VStack(alignment: .leading, spacing: 4) {
                                HStack(spacing: Spacing.medium) {
                                    // Icon section
                                    ZStack {
                                        Circle()
                                            .fill(
                                                LinearGradient(
                                                    gradient: Gradient(colors: [
                                                        Color.orange.opacity(0.08),
                                                        Color.orange.opacity(0.12)
                                                    ]),
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                )
                                            )
                                            .frame(width: 44, height: 44)
                                        
                                        Circle()
                                            .stroke(Color.orange.opacity(0.12), lineWidth: 1)
                                            .frame(width: 44, height: 44)
                                        
                                        Image(systemName: "note.text")
                                            .font(.system(size: 18, weight: .semibold))
                                            .foregroundStyle(Color.orange.opacity(0.8))
                                    }
                                    
                                    // Content section
                                    VStack(alignment: .leading, spacing: 2) {
                                        HStack(spacing: 4) {
                                            Text("Additional Notes")
                                                .font(.system(.subheadline, design: .rounded, weight: .medium))
                                                .foregroundStyle(.secondary)
                                            
                                            Spacer()
                                            
                                            Text("Optional")
                                                .font(.system(.caption, design: .rounded))
                                                .foregroundStyle(.tertiary)
                                                .padding(.horizontal, 8)
                                                .padding(.vertical, 2)
                                                .background(.quaternary.opacity(0.5), in: Capsule())
                                        }
                                        
                                        TextField(
                                            "Allergies, medical conditions, or other important information...",
                                            text: $viewModel.patientSetupData.notes,
                                            axis: .vertical
                                        )
                                        .font(.system(.body, design: .rounded))
                                        .foregroundStyle(.primary)
                                        .lineLimit(3...6)
                                    }
                                }
                                .padding(.horizontal, Spacing.medium)
                                .padding(.vertical, Spacing.small + 4)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color(.systemBackground))
                                )
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color(.systemGray5), lineWidth: 1)
                                )
                                .shadow(
                                    color: Color.black.opacity(0.05),
                                    radius: 2,
                                    x: 0,
                                    y: 1
                                )
                                
                                Text("Include any allergies, current medications, or medical conditions")
                                    .font(.system(.caption, design: .rounded))
                                    .foregroundStyle(.secondary)
                                    .padding(.horizontal, Spacing.medium)
                            }
                        }
                    }
                }
                
                // Enhanced Validation Errors with better visual design
                if !viewModel.validatePatientSetup().isEmpty {
                    VStack(alignment: .leading, spacing: Spacing.small) {
                        HStack(spacing: Spacing.medium) {
                            ZStack {
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            gradient: Gradient(colors: [
                                                Color.healthError.opacity(0.1),
                                                Color.healthError.opacity(0.15)
                                            ]),
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(width: 44, height: 44)
                                
                                Circle()
                                    .stroke(Color.healthError.opacity(0.2), lineWidth: 1.5)
                                    .frame(width: 44, height: 44)
                                
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundStyle(Color.healthError)
                            }
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Required Fields Missing")
                                    .font(.system(.headline, design: .rounded, weight: .semibold))
                                    .foregroundStyle(Color.healthError)
                                
                                Text("Please complete the following fields:")
                                    .font(.system(.subheadline, design: .rounded))
                                    .foregroundStyle(.secondary)
                            }
                            
                            Spacer()
                        }
                        
                        VStack(alignment: .leading, spacing: Spacing.xs) {
                            ForEach(viewModel.validatePatientSetup(), id: \.self) { error in
                                HStack(spacing: Spacing.small) {
                                    Image(systemName: "arrow.right.circle.fill")
                                        .font(.caption)
                                        .foregroundStyle(Color.healthError.opacity(0.7))
                                    
                                    Text(error)
                                        .font(.system(.body, design: .rounded))
                                        .foregroundStyle(Color.healthError)
                                }
                                .padding(.leading, Spacing.medium + 22) // Align with content
                            }
                        }
                    }
                    .padding(.horizontal, Spacing.medium)
                    .padding(.vertical, Spacing.medium)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.healthError.opacity(0.05))
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.healthError.opacity(0.3), lineWidth: 1)
                    )
                    .shadow(
                        color: Color.healthError.opacity(0.1),
                        radius: 4,
                        x: 0,
                        y: 2
                    )
                }
                
                Spacer()
                    .frame(height: Spacing.xl)
            }
        }
        .padding(.horizontal, Spacing.large)
        .onChange(of: selectedGender) { _, newValue in
            viewModel.patientSetupData.gender = newValue?.rawValue ?? ""
        }
        .onChange(of: selectedBloodType) { _, newValue in
            viewModel.patientSetupData.bloodType = newValue?.rawValue ?? ""
        }
        .onAppear {
            // Initialize selected values from view model
            selectedGender = GenderOption.allCases.first { $0.rawValue == viewModel.patientSetupData.gender }
            selectedBloodType = BloodTypeOption.allCases.first { $0.rawValue == viewModel.patientSetupData.bloodType }
        }
        
    }
}

// MARK: - Preview
#Preview {
    NavigationStack {
        PatientSetupScreen(viewModel: OnboardingViewModel())
    }
}
