//
//  MedicalCaseEditor.swift
//  Walnut
//
//  Created by Mayank Gandhi on 05/07/25.
//  Copyright © 2025 m. All rights reserved.
//

import SwiftUI
import SwiftData
import WalnutDesignSystem

struct MedicalCaseEditor: View {
    
    let medicalCase: MedicalCase?
    let patient: Patient?
    
    init(medicalCase: MedicalCase? = nil,
         patient: Patient? = nil) {
        self.medicalCase = medicalCase
        self.patient = patient
    }
    
    private var editorTitle: String {
        medicalCase == nil ? "Add Medical Case" : "Edit Medical Case"
    }
    
    @State private var title = ""
    @State private var notes = ""
    @State private var selectedType: MedicalCaseType = .consultation
    @State private var selectedSpecialty: MedicalSpecialty? = .generalPractitioner
    @State private var isActive = true
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    // Focus management for keyboard navigation
    @FocusState private var focusedField: FormField?
    
    private enum FormField: Hashable, CaseIterable {
        case title
        case notes
        
        private enum NextFieldType {
            case textField(FormField)
            case nonTextFieldOrEnd
        }
        
        private var nextFieldInUI: NextFieldType {
            switch self {
            case .title:
                return .nonTextFieldOrEnd  // Next: Type picker
            case .notes:
                return .nonTextFieldOrEnd
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
    
    private var isFormValid: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        selectedSpecialty != nil
    }
    
    // Focus navigation helpers
    private func focusNextField(after currentField: FormField) {
        if currentField.shouldDismissKeyboard {
            if isFormValid {
                submitForm()
            } else {
                focusedField = nil
            }
        } else if let nextField = currentField.nextTextField {
            focusedField = nextField
        } else {
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
                    // Case Information Section
                    VStack(alignment: .leading, spacing: Spacing.xs) {
                        Text("Case Information")
                            .font(.headline)
                            .foregroundStyle(.secondary)
                            .padding(.horizontal, Spacing.medium)
                        
                        VStack(spacing: Spacing.medium) {
                            TextFieldItem(
                                icon: "doc.text.fill",
                                title: "Case Title",
                                text: $title,
                                placeholder: "Enter case title",
                                iconColor: .healthPrimary,
                                isRequired: true,
                                contentType: .none,
                                submitLabel: FormField.title.appropriateSubmitLabel,
                                onSubmit: {
                                    focusNextField(after: .title)
                                }
                            )
                            .focused($focusedField, equals: .title)
                            
                            MenuPickerItem(
                                icon: "medical.thermometer",
                                title: "Case Type",
                                selectedOption: Binding(
                                    get: { selectedType.displayName },
                                    set: { newValue in
                                        if let type = MedicalCaseType.allCases.first(where: { $0.displayName == newValue }) {
                                            selectedType = type
                                        }
                                    }
                                ),
                                options: MedicalCaseType.allCases.map { $0.displayName },
                                placeholder: "Select case type",
                                iconColor: .healthSuccess
                            )
                            
                            ButtonPickerItem(
                                icon: "stethoscope",
                                title: "Medical Specialty",
                                selectedOption: $selectedSpecialty,
                                options: Array(MedicalSpecialty.allCases),
                                placeholder: "Select specialty",
                                bottomSheetTitle: "Select Medical Specialty",
                                helperText: "Choose the relevant medical specialty",
                                iconColor: .healthPrimary,
                                isRequired: true
                            )
                            
                        }
                    }
                    
                    // Patient Information Section
                    VStack(alignment: .leading, spacing: Spacing.xs) {
                        Text("Patient Information")
                            .font(.headline)
                            .foregroundStyle(.secondary)
                            .padding(.horizontal, Spacing.medium)
                        
                        HealthCard {
                            HStack(spacing: Spacing.medium) {
                                PatientAvatar(
                                    name: patient?.name ?? "P",
                                    color: patient?.primaryColor ?? Color.blue,
                                    size: Size.avatarLarge
                                )
                                
                                VStack(alignment: .leading, spacing: Spacing.xs) {
                                    Text(patient?.name ?? "Patient")
                                        .font(.headline.weight(.semibold))
                                        .foregroundStyle(.primary)
                                    
                                    Text(
                                        "\(String(describing: patient?.age)) years old • \(String(describing: patient?.gender))"
                                    )
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                
                                Spacer()
                            }
                        }
                        
                    }
                    
                    // Clinical Details Section
                    VStack(alignment: .leading, spacing: Spacing.xs) {
                        Text("Clinical Details")
                            .font(.headline)
                            .foregroundStyle(.secondary)
                            .padding(.horizontal, Spacing.medium)
                        
                        VStack(spacing: Spacing.medium) {
                            TextFieldItem(
                                icon: "note.text",
                                title: "Clinical Notes",
                                text: $notes,
                                placeholder: "Clinical notes and observations",
                                helperText: "Record symptoms, observations, and findings",
                                iconColor: .orange,
                                submitLabel: FormField.notes.appropriateSubmitLabel,
                                onSubmit: {
                                    focusNextField(after: .notes)
                                }
                            )
                            .focused($focusedField, equals: .notes)
                          
                        }
                    }
                    
                    // Status Section
                    VStack(alignment: .leading, spacing: Spacing.xs) {
                        Text("Case Status")
                            .font(.headline)
                            .foregroundStyle(.secondary)
                            .padding(.horizontal, Spacing.medium)
                        
                        ToggleItem(
                            icon: isActive ? "checkmark.circle.fill" : "xmark.circle.fill",
                            title: "Active Case",
                            subtitle: "Currently being treated",
                            isOn: $isActive,
                            helperText: "Inactive cases are archived",
                            iconColor: isActive ? .healthSuccess : .healthError
                        )
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
                if let medicalCase {
                    loadMedicalCaseData(medicalCase)
                }
            }
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
    }
    
    private func loadMedicalCaseData(_ medicalCase: MedicalCase) {
        title = medicalCase.title ?? ""
        notes = medicalCase.notes ?? ""
        
        if let type = medicalCase.type {
            self.selectedType = type
        }
        
        if let specialty = medicalCase.specialty {
            self.selectedSpecialty = specialty
        }
        
        if let isActive = medicalCase.isActive {
            self.isActive = isActive
        }
    }
    
    private func save() {
        let now = Date()
        
        if let medicalCase {
            // Edit existing medical case
            medicalCase.title = title.trimmingCharacters(in: .whitespacesAndNewlines)
            medicalCase.notes = notes.trimmingCharacters(in: .whitespacesAndNewlines)
            medicalCase.type = selectedType
            medicalCase.specialty = selectedSpecialty
            medicalCase.isActive = isActive
            medicalCase.updatedAt = now
        } else {
            // Create new medical case
            let newMedicalCase = MedicalCase(
                id: UUID(),
                title: title.trimmingCharacters(in: .whitespacesAndNewlines),
                notes: notes.trimmingCharacters(in: .whitespacesAndNewlines),
                type: selectedType,
                specialty: selectedSpecialty ?? .generalPractitioner,
                isActive: isActive,
                createdAt: now,
                updatedAt: now,
                patient: patient
            )
            modelContext.insert(newMedicalCase)
        }
    }
}


// MARK: - Previews

#Preview("Add Medical Case") {
    MedicalCaseEditor(medicalCase: nil, patient: .samplePatient)
        .modelContainer(for: MedicalCase.self, inMemory: true)
}

#Preview("Edit Medical Case") {
    MedicalCaseEditor(medicalCase: .sampleCase, patient: .samplePatient)
        .modelContainer(for: MedicalCase.self, inMemory: true)
}
