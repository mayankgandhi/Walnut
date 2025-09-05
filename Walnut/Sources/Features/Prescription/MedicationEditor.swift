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
    
    // Common duration options for easy selection
    static let durationOptions: [MedicationDuration] = [
        .days(1), .days(3), .days(5), .days(7), .days(10), .days(14),
        .days(21), .days(30), .days(45), .days(60), .days(90),
        .weeks(1), .weeks(2), .weeks(4), .weeks(8), .weeks(12),
        .months(1), .months(2), .months(3), .months(6), .months(12),
        .ongoing, .asNeeded
    ]
    
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
    @State private var duration: MedicationDuration? = .days(7)
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
        duration != nil
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
                                title: "Duration",
                                selectedOption: $duration,
                                options: Self.durationOptions,
                                placeholder: "Select duration",
                                helperText: "How long to take this medication",
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
        duration = medication.duration
        
        // Load frequency data (only handle meal-based frequencies in this editor)
        for schedule in medication.frequency ?? [] {
            // Only process meal-based schedules in this editor
            if case .mealBased(let mealTime, let timing) = schedule.frequency {
                switch mealTime {
                case .breakfast:
                    if timing == .before {
                        breakfastBefore = true
                    } else {
                        breakfastAfter = true
                    }
                case .lunch:
                    if timing == .before {
                        lunchBefore = true
                    } else {
                        lunchAfter = true
                    }
                case .dinner:
                    if timing == .before {
                        dinnerBefore = true
                    } else {
                        dinnerAfter = true
                    }
                case .bedtime:
                    if timing == .before {
                        bedtimeBefore = true
                    } else {
                        bedtimeAfter = true
                    }
                }
            }
        }
    }
    
    
    private func save() {
        guard let medicationDuration = duration else { return }
        
        if let medication {
            // Edit existing medication - update properties but don't perform modelContext operations
            medication.name = medicationName.trimmingCharacters(in: .whitespacesAndNewlines)
            medication.dosage = dosage.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : dosage.trimmingCharacters(in: .whitespacesAndNewlines)
            medication.instructions = instructions.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : instructions.trimmingCharacters(in: .whitespacesAndNewlines)
            medication.duration = medicationDuration
            medication.frequency = nil
            medication.updatedAt = Date()
            
            onSave(medication)
        } else {
            // Create new medication - just pass data to parent, no modelContext operations
            let newMedication = Medication(
                id: UUID(),
                name: medicationName.trimmingCharacters(in: .whitespacesAndNewlines),
                frequency: [],
                duration: medicationDuration,
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
            .init(frequency: .daily(times: [.init()]), dosage: "1000mg")
        ],
        duration: .days(30),
        dosage: "10mg",
        instructions: "Take with water"
    )
    
    MedicationEditor(medication: sampleMedication) { _ in }
        .modelContainer(for: Medication.self, inMemory: true)
}
