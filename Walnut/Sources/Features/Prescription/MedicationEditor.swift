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
    @State private var duration: MedicationDuration? = .days(7)
    @State private var selectedFrequencies: [MedicationFrequency] = []
    @State private var showFrequencyBottomSheet = false
    
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
                        }
                    }
                    
                    // Frequency Schedule Section
                    VStack(alignment: .leading, spacing: Spacing.xs) {
                        Text("Frequency Schedule")
                            .font(.headline)
                            .foregroundStyle(.secondary)
                            .padding(.horizontal, Spacing.medium)
                        
                        VStack(spacing: Spacing.medium) {
                            // Frequency selector button
                            Button {
                                showFrequencyBottomSheet = true
                            } label: {
                                HStack(spacing: Spacing.medium) {
                                    // Icon section
                                    Circle()
                                        .fill(Color.green.opacity(0.15))
                                        .frame(width: 36, height: 36)
                                        .overlay {
                                            Image(systemName: "clock.badge.checkmark")
                                                .font(.system(size: 16, weight: .semibold))
                                                .foregroundStyle(.green)
                                        }
                                    
                                    // Content section
                                    VStack(alignment: .leading, spacing: 2) {
                                        HStack(spacing: 4) {
                                            Text("Frequency")
                                                .font(.system(.subheadline, design: .rounded, weight: .medium))
                                                .foregroundStyle(.secondary)
                                            
                                            Spacer()
                                        }
                                        
                                        HStack {
                                            Text(selectedFrequencies.isEmpty ? "Add frequency schedule" : "\(selectedFrequencies.count) schedule\(selectedFrequencies.count == 1 ? "" : "s")")
                                                .font(.system(.body, design: .rounded))
                                                .foregroundStyle(selectedFrequencies.isEmpty ? .secondary : .primary)
                                            
                                            Spacer()
                                            
                                            Image(systemName: "plus.circle")
                                                .font(.caption)
                                                .foregroundStyle(.green)
                                        }
                                    }
                                }
                                .padding(.horizontal, Spacing.medium)
                                .padding(.vertical, Spacing.small + 4)
                                .background(Color(.systemBackground))
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
                            }
                            .buttonStyle(PlainButtonStyle())
                            
                            // Display selected frequencies
                            if !selectedFrequencies.isEmpty {
                                LazyVStack(spacing: Spacing.xs) {
                                    ForEach(Array(selectedFrequencies.enumerated()), id: \.offset) { index, frequency in
                                        FrequencyChip(frequency: frequency) {
                                            selectedFrequencies.remove(at: index)
                                        }
                                    }
                                }
                                .padding(.horizontal, Spacing.medium)
                            }
                            
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
        .sheet(isPresented: $showFrequencyBottomSheet) {
            MedicationFrequencyBottomSheet(selectedFrequencies: $selectedFrequencies)
        }
    }
    
    
    private func loadMedicationData(_ medication: Medication) {
        medicationName = medication.name ?? ""
        dosage = medication.dosage ?? ""
        instructions = medication.instructions ?? ""
        duration = medication.duration
        selectedFrequencies = medication.frequency ?? []
    }
    
    
    private func save() {
        guard let medicationDuration = duration else { return }
        
        if let medication {
            // Edit existing medication - update properties but don't perform modelContext operations
            medication.name = medicationName.trimmingCharacters(in: .whitespacesAndNewlines)
            medication.dosage = dosage.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : dosage.trimmingCharacters(in: .whitespacesAndNewlines)
            medication.instructions = instructions.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : instructions.trimmingCharacters(in: .whitespacesAndNewlines)
            medication.duration = medicationDuration
            medication.frequency = selectedFrequencies.isEmpty ? nil : selectedFrequencies
            medication.updatedAt = Date()
            
            onSave(medication)
        } else {
            // Create new medication - just pass data to parent, no modelContext operations
            let newMedication = Medication(
                id: UUID(),
                name: medicationName.trimmingCharacters(in: .whitespacesAndNewlines),
                frequency: selectedFrequencies.isEmpty ? nil : selectedFrequencies,
                duration: medicationDuration,
                dosage: dosage.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : dosage.trimmingCharacters(in: .whitespacesAndNewlines),
                instructions: instructions.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : instructions.trimmingCharacters(in: .whitespacesAndNewlines)
            )
            
            onSave(newMedication)
        }
    }
}

// MARK: - Frequency Chip Component

struct FrequencyChip: View {
    let frequency: MedicationFrequency
    let onRemove: () -> Void
    
    var body: some View {
        HStack(spacing: Spacing.small) {
            Image(systemName: frequency.icon)
                .font(.caption2)
                .foregroundStyle(frequency.color)
            
            Text(frequency.displayText)
                .font(.system(.caption, design: .rounded, weight: .medium))
                .foregroundStyle(.primary)
                .lineLimit(1)
            
            Button {
                onRemove()
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(.horizontal, Spacing.small)
        .padding(.vertical, 4)
        .background(frequency.color.opacity(0.1))
        .clipShape(Capsule())
        .overlay(
            Capsule()
                .stroke(frequency.color.opacity(0.3), lineWidth: 1)
        )
    }
}

// MARK: - Medication Frequency Bottom Sheet


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
