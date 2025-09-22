//
//  PatientEditor.swift
//  Walnut
//
//  Created by Mayank Gandhi on 03/07/25.
//  Copyright © 2025 m. All rights reserved.
//


import SwiftUI
import SwiftData
import WalnutDesignSystem

struct PatientEditor: View {
    
    let patient: Patient?
    
    init(patient: Patient? = nil) {
        self.patient = patient
    }
    
    private var editorTitle: String {
        patient == nil ? "Add Patient" : "Edit Patient"
    }
    
    @State private var name = ""
    @State private var dateOfBirth = Date()
    @State private var selectedGender: String? = nil
    @State private var selectedBloodType: String? = nil
    @State private var emergencyContactName = ""
    @State private var emergencyContactPhone = ""
    @State private var notes = ""
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    // Focus management for keyboard navigation
    @FocusState private var focusedField: FormField?
    
    private enum FormField: Hashable, CaseIterable {
        case firstName
        case lastName
        case emergencyContactName
        case emergencyContactPhone
        case notes
        
        // Define what type of field comes next in the UI order
        private enum NextFieldType {
            case textField(FormField)
            case nonTextFieldOrEnd
        }
        
        private var nextFieldInUI: NextFieldType {
            switch self {
            case .firstName:
                return .textField(.lastName)  // Next: Last Name
            case .lastName:
                return .nonTextFieldOrEnd  // Next: Gender Menu
            case .emergencyContactName:
                return .textField(.emergencyContactPhone)  // Next: Phone text field
            case .emergencyContactPhone:
                return .textField(.notes)  // Next: Notes text field
            case .notes:
                return .nonTextFieldOrEnd  // Next: Toggle (last field)
            }
        }
        
        var shouldDismissKeyboard: Bool {
            switch nextFieldInUI {
            case .nonTextFieldOrEnd:
                return true
            case .textField:
                return false
            }
        }
        
        var nextTextField: FormField? {
            switch nextFieldInUI {
            case .textField(let field):
                return field
            case .nonTextFieldOrEnd:
                return nil
            }
        }
        
        var appropriateSubmitLabel: SubmitLabel {
            return shouldDismissKeyboard ? .done : .next
        }
    }
    
    private let genderOptions = ["Male", "Female", "Not Specified"]
    private let bloodTypeOptions = ["A+", "A-", "B+", "B-", "AB+", "AB-", "O+", "O-", "Unknown"]
    
    @State private var selectedDateOfBirth: Date? = nil
    
    private var isFormValid: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        selectedDateOfBirth != nil
    }
    
    // Focus navigation helpers
    private func focusNextField(after currentField: FormField) {
        if currentField.shouldDismissKeyboard {
            // Next field is non-text field or it's the last field
            if currentField == .notes && isFormValid {
                // Special case: notes is the last text field, submit if form is valid
                submitForm()
            } else {
                // Dismiss keyboard
                focusedField = nil
            }
        } else if let nextField = currentField.nextTextField {
            // Move to next text field
            focusedField = nextField
        } else {
            // Fallback: dismiss keyboard
            focusedField = nil
        }
    }
    
    private func submitForm() {
        withAnimation(.easeInOut(duration: 0.3)) {
            save()
            dismiss()
        }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Spacing.large) {
                    VStack(alignment: .leading, spacing: Spacing.xs) {
                        Text("Personal Information")
                            .font(.headline)
                            .foregroundStyle(.secondary)
                            .padding(.horizontal, Spacing.medium)
                        
                        VStack(spacing: Spacing.medium) {
                            TextFieldItem(
                                icon: "person.fill",
                                title: "Name",
                                text: $name,
                                placeholder: "Enter first name",
                                iconColor: .healthPrimary,
                                isRequired: true,
                                contentType: .givenName,
                                submitLabel: FormField.firstName.appropriateSubmitLabel,
                                onSubmit: {
                                    focusNextField(after: .firstName)
                                }
                            )
                            .focused($focusedField, equals: .firstName)
                            
                            DatePickerItem(
                                icon: "calendar",
                                title: "Date of Birth",
                                selectedDate: $selectedDateOfBirth,
                                helperText: "Used for age calculations",
                                iconColor: .orange,
                                isRequired: true
                            )
                            
                            MenuPickerItem(
                                icon: "person.2.fill",
                                title: "Gender",
                                selectedOption: $selectedGender,
                                options: genderOptions,
                                placeholder: "Select gender",
                                iconColor: .purple
                            )
                            
                            MenuPickerItem(
                                icon: "drop.fill",
                                title: "Blood Type",
                                selectedOption: $selectedBloodType,
                                options: bloodTypeOptions,
                                placeholder: "Select blood type",
                                helperText: "Medical reference information",
                                iconColor: .red
                            )
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: Spacing.xs) {
                        Text("Emergency Contact")
                            .font(.headline)
                            .foregroundStyle(.secondary)
                            .padding(.horizontal, Spacing.medium)
                        
                        VStack(spacing: Spacing.medium) {
                            TextFieldItem(
                                icon: "person.crop.circle.badge.exclamationmark",
                                title: "Emergency Contact Name",
                                text: $emergencyContactName,
                                placeholder: "Enter contact name",
                                helperText: "Person to contact in case of emergency",
                                iconColor: .healthError,
                                contentType: .name,
                                submitLabel: FormField.emergencyContactName.appropriateSubmitLabel,
                                onSubmit: {
                                    focusNextField(after: .emergencyContactName)
                                }
                            )
                            .focused($focusedField, equals: .emergencyContactName)
                            
                            TextFieldItem(
                                icon: "phone.fill",
                                title: "Emergency Contact Phone",
                                text: $emergencyContactPhone,
                                placeholder: "Enter phone number",
                                iconColor: .green,
                                keyboardType: .phonePad,
                                contentType: .telephoneNumber,
                                submitLabel: FormField.emergencyContactPhone.appropriateSubmitLabel,
                                onSubmit: {
                                    focusNextField(after: .emergencyContactPhone)
                                }
                            )
                            .focused($focusedField, equals: .emergencyContactPhone)
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: Spacing.xs) {
                        Text("Additional Information")
                            .font(.headline)
                            .foregroundStyle(.secondary)
                            .padding(.horizontal, Spacing.medium)
                        
                        VStack(spacing: Spacing.medium) {
                            TextFieldItem(
                                icon: "note.text",
                                title: "Notes",
                                text: $notes,
                                placeholder: "Additional notes about the patient",
                                helperText: "Optional medical notes or special considerations",
                                iconColor: .gray,
                                submitLabel: FormField.notes.appropriateSubmitLabel,
                                onSubmit: {
                                    focusNextField(after: .notes)
                                }
                            )
                            .focused($focusedField, equals: .notes)
                        }
                    }
                    
                    Spacer(minLength: Spacing.xl)
                }
                .padding(.horizontal, Spacing.medium)
                .padding(.top, Spacing.medium)
            }
            .navigationTitle(editorTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        submitForm()
                    }
                    .disabled(!isFormValid)
                    .font(.system(size: 16, weight: .semibold))
                }
                
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", role: .cancel) {
                        dismiss()
                    }
                    .font(.system(size: 16, weight: .medium))
                }
            }
            .onAppear {
                if let patient {
                    loadPatientData(patient)
                    AnalyticsService.shared.track(.patient(.editorOpened))
                } else {
                    // Set default date for new patients
                    selectedDateOfBirth = dateOfBirth
                    AnalyticsService.shared.track(.patient(.editorOpened))
                }
            }
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
    }
    
    private func loadPatientData(_ patient: Patient) {
        name = patient.name ?? name
        dateOfBirth = patient.dateOfBirth ?? dateOfBirth
        selectedDateOfBirth = patient.dateOfBirth
        selectedGender = patient.gender
        selectedBloodType = patient.bloodType
        emergencyContactName = patient.emergencyContactName ?? emergencyContactName
        emergencyContactPhone = patient.emergencyContactPhone ?? emergencyContactPhone
        notes = patient.notes ?? notes
    }
    
    private func save() {
        let now = Date()

        let finalDateOfBirth = selectedDateOfBirth ?? dateOfBirth

        if let patient {
            // Edit existing patient
            patient.name = name.trimmingCharacters(in: .whitespacesAndNewlines)
            patient.dateOfBirth = finalDateOfBirth
            patient.gender = selectedGender ?? "Not Specified"
            patient.bloodType = selectedBloodType ?? "Unknown"
            patient.emergencyContactName = emergencyContactName.trimmingCharacters(in: .whitespacesAndNewlines)
            patient.emergencyContactPhone = emergencyContactPhone.trimmingCharacters(in: .whitespacesAndNewlines)
            patient.notes = notes.trimmingCharacters(in: .whitespacesAndNewlines)
            patient.updatedAt = now

            AnalyticsService.shared.track(.patient(.updated))
        } else {
            // Check subscription limits for new patient creation
            let subscriptionService = SubscriptionService.shared
            if !subscriptionService.isPremiumFeatureAvailable() {
                // For free users, check patient count limit (e.g., 3 patients max)
                let descriptor = FetchDescriptor<Patient>()
                let patientCount = (try? modelContext.fetchCount(descriptor)) ?? 0

                if patientCount >= 3 {
                    // Show upgrade prompt - this would typically be handled with an alert
                    // For now, we'll just return without saving
                    return
                }
            }

            // Create new patient
            let newPatient = Patient(
                id: UUID(),
                name: name.trimmingCharacters(in: .whitespacesAndNewlines),
                dateOfBirth: finalDateOfBirth,
                gender: selectedGender ?? "Not Specified",
                bloodType: selectedBloodType ?? "Unknown",
                emergencyContactName: emergencyContactName.trimmingCharacters(in: .whitespacesAndNewlines),
                emergencyContactPhone: emergencyContactPhone.trimmingCharacters(in: .whitespacesAndNewlines),
                notes: notes.trimmingCharacters(in: .whitespacesAndNewlines),
                createdAt: now,
                updatedAt: now,
                medicalCases: []
            )
            modelContext.insert(newPatient)

            AnalyticsService.shared.track(.patient(.created))
        }
    }
}

#Preview("Add Patient") {
    PatientEditor(patient: nil)
        .modelContainer(for: Patient.self, inMemory: true)
}

#Preview("Edit Patient") {
    PatientEditor(patient: .samplePatient)
        .modelContainer(for: Patient.self, inMemory: true)
}
