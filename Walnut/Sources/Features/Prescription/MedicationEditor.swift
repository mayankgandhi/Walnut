//
//  MedicationEditor.swift
//  Walnut
//
//  Created by Mayank Gandhi on 11/08/25.
//  Copyright © 2025 m. All rights reserved.
//

import SwiftUI
import SwiftData
import WalnutDesignSystem

struct MedicationEditor: View {
    
    let medication: Medication?
    let onSave: (Medication) -> Void
    
    init(medication: Medication? = nil, onSave: @escaping (Medication) -> Void) {
        self.medication = medication
        self.onSave = onSave
    }
    
    private var editorTitle: String {
        medication == nil ? "Add Medication" : "Edit Medication"
    }
    
    @State private var medicationName = ""
    @State private var dosage = ""
    @State private var instructions = ""
    @State private var numberOfDays: Int? = 7
    @State private var selectedFrequencies: [MedicationSchedule] = []
    
    // Frequency selection states
    @State private var breakfastBefore = false
    @State private var breakfastAfter = false
    @State private var lunchBefore = false
    @State private var lunchAfter = false
    @State private var dinnerBefore = false
    @State private var dinnerAfter = false
    @State private var bedtimeBefore = false
    @State private var bedtimeAfter = false
    
    @Environment(\.dismiss) private var dismiss
    
    // Focus management for keyboard navigation
    @FocusState private var focusedField: FormField?
    
    private enum FormField: Hashable, CaseIterable {
        case medicationName
        case dosage
        case instructions
        
        private enum NextFieldType {
            case textField(FormField)
            case nonTextFieldOrEnd
        }
        
        private var nextFieldInUI: NextFieldType {
            switch self {
            case .medicationName:
                return .textField(.dosage)
            case .dosage:
                return .nonTextFieldOrEnd  // Next: Number input
            case .instructions:
                return .nonTextFieldOrEnd  // Last field
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
        !medicationName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !dosage.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        numberOfDays != nil &&
        !buildFrequencyArray().isEmpty
    }
    
    // Focus navigation helpers
    private func focusNextField(after currentField: FormField) {
        if currentField.shouldDismissKeyboard {
            if currentField == .instructions && isFormValid {
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
                    // Medication Information Section
                    VStack(alignment: .leading, spacing: Spacing.xs) {
                        Text("Medication Information")
                            .font(.headline)
                            .foregroundStyle(.secondary)
                            .padding(.horizontal, Spacing.medium)
                        
                        VStack(spacing: Spacing.medium) {
                            TextFieldItem(
                                icon: "pills.fill",
                                title: "Medication Name",
                                text: $medicationName,
                                placeholder: "Enter medication name",
                                iconColor: .healthPrimary,
                                isRequired: true,
                                contentType: .none,
                                submitLabel: FormField.medicationName.appropriateSubmitLabel,
                                onSubmit: {
                                    focusNextField(after: .medicationName)
                                }
                            )
                            .focused($focusedField, equals: .medicationName)
                            
                            TextFieldItem(
                                icon: "cross.case.fill",
                                title: "Dosage",
                                text: $dosage,
                                placeholder: "e.g., 500mg, 1 tablet, 2 capsules",
                                helperText: "Strength and quantity per dose",
                                iconColor: .orange,
                                isRequired: true,
                                contentType: .none,
                                submitLabel: FormField.dosage.appropriateSubmitLabel,
                                onSubmit: {
                                    focusNextField(after: .dosage)
                                }
                            )
                            .focused($focusedField, equals: .dosage)
                            
                            MenuPickerItem(
                                icon: "calendar.day.timeline.left",
                                title: "Duration (Days)",
                                selectedOption: $numberOfDays,
                                options: Array(1...90),
                                placeholder: "Select duration",
                                helperText: "Number of days to take medication",
                                iconColor: .blue,
                                isRequired: true
                            )
                        }
                    }
                    
                    // Frequency Schedule Section
                    VStack(alignment: .leading, spacing: Spacing.xs) {
                        Text("Frequency Schedule")
                            .font(.headline)
                            .foregroundStyle(.secondary)
                            .padding(.horizontal, Spacing.medium)
                        
                        VStack(spacing: Spacing.medium) {
                            // Breakfast Section
                            VStack(alignment: .leading, spacing: Spacing.xs) {
                                Text("Breakfast")
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundStyle(.primary)
                                    .padding(.horizontal, Spacing.medium)
                                
                                VStack(spacing: Spacing.small) {
                                    ToggleItem(
                                        icon: "sunrise",
                                        title: "Before Breakfast",
                                        subtitle: "Take before eating",
                                        isOn: $breakfastBefore,
                                        iconColor: .orange
                                    )
                                    
                                    ToggleItem(
                                        icon: "sunrise.fill",
                                        title: "After Breakfast",
                                        subtitle: "Take after eating",
                                        isOn: $breakfastAfter,
                                        iconColor: .orange
                                    )
                                }
                            }
                            
                            // Lunch Section
                            VStack(alignment: .leading, spacing: Spacing.xs) {
                                Text("Lunch")
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundStyle(.primary)
                                    .padding(.horizontal, Spacing.medium)
                                
                                VStack(spacing: Spacing.small) {
                                    ToggleItem(
                                        icon: "sun.max",
                                        title: "Before Lunch",
                                        subtitle: "Take before eating",
                                        isOn: $lunchBefore,
                                        iconColor: .yellow
                                    )
                                    
                                    ToggleItem(
                                        icon: "sun.max.fill",
                                        title: "After Lunch",
                                        subtitle: "Take after eating",
                                        isOn: $lunchAfter,
                                        iconColor: .yellow
                                    )
                                }
                            }
                            
                            // Dinner Section
                            VStack(alignment: .leading, spacing: Spacing.xs) {
                                Text("Dinner")
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundStyle(.primary)
                                    .padding(.horizontal, Spacing.medium)
                                
                                VStack(spacing: Spacing.small) {
                                    ToggleItem(
                                        icon: "sunset",
                                        title: "Before Dinner",
                                        subtitle: "Take before eating",
                                        isOn: $dinnerBefore,
                                        iconColor: .purple
                                    )
                                    
                                    ToggleItem(
                                        icon: "sunset.fill",
                                        title: "After Dinner",
                                        subtitle: "Take after eating",
                                        isOn: $dinnerAfter,
                                        iconColor: .purple
                                    )
                                }
                            }
                            
                            // Bedtime Section
                            VStack(alignment: .leading, spacing: Spacing.xs) {
                                Text("Bedtime")
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundStyle(.primary)
                                    .padding(.horizontal, Spacing.medium)
                                
                                VStack(spacing: Spacing.small) {
                                    ToggleItem(
                                        icon: "moon",
                                        title: "Before Bed",
                                        subtitle: "Take before sleeping",
                                        isOn: $bedtimeBefore,
                                        iconColor: .indigo
                                    )
                                    
                                    ToggleItem(
                                        icon: "moon.fill",
                                        title: "At Bedtime",
                                        subtitle: "Take when going to bed",
                                        isOn: $bedtimeAfter,
                                        iconColor: .indigo
                                    )
                                }
                            }
                        }
                    }
                    
                    // Additional Information Section
                    VStack(alignment: .leading, spacing: Spacing.xs) {
                        Text("Additional Information")
                            .font(.headline)
                            .foregroundStyle(.secondary)
                            .padding(.horizontal, Spacing.medium)
                        
                        TextFieldItem(
                            icon: "doc.text",
                            title: "Instructions",
                            text: $instructions,
                            placeholder: "Special instructions or notes",
                            helperText: "Any specific instructions for taking this medication",
                            iconColor: .gray,
                            submitLabel: FormField.instructions.appropriateSubmitLabel,
                            onSubmit: {
                                focusNextField(after: .instructions)
                            }
                        )
                        .focused($focusedField, equals: .instructions)
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
                if let medication {
                    loadMedicationData(medication)
                }
            }
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
    }
    
    
    private func loadMedicationData(_ medication: Medication) {
        medicationName = medication.name ?? ""
        dosage = medication.dosage ?? ""
        instructions = medication.instructions ?? ""
        numberOfDays = medication.numberOfDays
        
        // Load frequency data
        for schedule in medication.frequency ?? [] {
            switch schedule.mealTime {
            case .breakfast:
                if schedule.timing == .before {
                    breakfastBefore = true
                } else {
                    breakfastAfter = true
                }
            case .lunch:
                if schedule.timing == .before {
                    lunchBefore = true
                } else {
                    lunchAfter = true
                }
            case .dinner:
                if schedule.timing == .before {
                    dinnerBefore = true
                } else {
                    dinnerAfter = true
                }
            case .bedtime:
                if schedule.timing == .before {
                    bedtimeBefore = true
                } else {
                    bedtimeAfter = true
                }
            }
        }
    }
    
    private func buildFrequencyArray() -> [MedicationSchedule] {
        var frequencies: [MedicationSchedule] = []
        
        if breakfastBefore {
            frequencies.append(MedicationSchedule(mealTime: .breakfast, timing: .before, dosage: nil))
        }
        if breakfastAfter {
            frequencies.append(MedicationSchedule(mealTime: .breakfast, timing: .after, dosage: nil))
        }
        if lunchBefore {
            frequencies.append(MedicationSchedule(mealTime: .lunch, timing: .before, dosage: nil))
        }
        if lunchAfter {
            frequencies.append(MedicationSchedule(mealTime: .lunch, timing: .after, dosage: nil))
        }
        if dinnerBefore {
            frequencies.append(MedicationSchedule(mealTime: .dinner, timing: .before, dosage: nil))
        }
        if dinnerAfter {
            frequencies.append(MedicationSchedule(mealTime: .dinner, timing: .after, dosage: nil))
        }
        if bedtimeBefore {
            frequencies.append(MedicationSchedule(mealTime: .bedtime, timing: .before, dosage: nil))
        }
        if bedtimeAfter {
            frequencies.append(MedicationSchedule(mealTime: .bedtime, timing: .after, dosage: nil))
        }
        
        return frequencies
    }
    
    private func save() {
        let frequencies = buildFrequencyArray()
        guard let daysCount = numberOfDays else { return }
        
        if let medication {
            // Edit existing medication - update properties but don't perform modelContext operations
            medication.name = medicationName.trimmingCharacters(in: .whitespacesAndNewlines)
            medication.dosage = dosage.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : dosage.trimmingCharacters(in: .whitespacesAndNewlines)
            medication.instructions = instructions.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : instructions.trimmingCharacters(in: .whitespacesAndNewlines)
            medication.numberOfDays = daysCount
            medication.frequency = frequencies
            medication.updatedAt = Date()
            
            onSave(medication)
        } else {
            // Create new medication - just pass data to parent, no modelContext operations
            let newMedication = Medication(
                id: UUID(),
                name: medicationName.trimmingCharacters(in: .whitespacesAndNewlines),
                frequency: frequencies,
                numberOfDays: daysCount,
                dosage: dosage.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : dosage.trimmingCharacters(in: .whitespacesAndNewlines),
                instructions: instructions.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : instructions.trimmingCharacters(in: .whitespacesAndNewlines)
            )
            
            onSave(newMedication)
        }
    }
}

// MARK: - Previews

#Preview("Add Medication") {
    MedicationEditor(medication: nil) { _ in }
        .modelContainer(for: Medication.self, inMemory: true)
}

#Preview("Edit Medication") {
    let sampleMedication = Medication(
        id: UUID(),
        name: "Lisinopril",
        frequency: [
            MedicationSchedule(mealTime: .breakfast, timing: .before, dosage: nil),
            MedicationSchedule(mealTime: .dinner, timing: .after, dosage: nil)
        ],
        numberOfDays: 30,
        dosage: "10mg",
        instructions: "Take with water"
    )
    
    MedicationEditor(medication: sampleMedication) { _ in }
        .modelContainer(for: Medication.self, inMemory: true)
}
