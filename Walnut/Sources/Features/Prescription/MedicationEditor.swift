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
    
    // Removed durationOptions array - now using MedicationDurationPickerItem
    // static let durationOptions: [MedicationDuration] = [
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
    @State private var selectedFrequencies: [MedicationFrequency] = []
    
    @Environment(\.dismiss) private var dismiss
    
    // Focus management for keyboard navigation
    
    private var isFormValid: Bool {
        !medicationName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !dosage.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        duration != nil
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
                               
                            )
                            
                            TextFieldItem(
                                icon: "cross.case.fill",
                                title: "Dosage",
                                text: $dosage,
                                placeholder: "e.g., 500mg, 1 tablet, 2 capsules",
                                helperText: "Strength and quantity per dose",
                                iconColor: .orange,
                                isRequired: true,
                                contentType: .none,
                                
                            )
                            
                            MedicationDurationPickerItem(
                                icon: "calendar.day.timeline.left",
                                title: "Duration",
                                selectedDuration: $duration,
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
        frequency: [],
        duration: .days(30),
        dosage: "10mg",
        instructions: "Take with water"
    )
    
    MedicationEditor(medication: sampleMedication) { _ in }
        .modelContainer(for: Medication.self, inMemory: true)
}
