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
    
    @Environment(\.modelContext) var modelContext
    @Environment(\.notificationErrorHandler) private var errorHandler
    
    let patient: Patient
    let medication: Medication?
    let targetPrescription: Prescription?
    let onSave: (Medication) -> Void
    
    @State private var notificationManager = MedicationNotificationManager()
    
    // MARK: - Initializers
    
    /// Initialize for editing existing medication
    init(patient: Patient, medication: Medication, onSave: @escaping (Medication) -> Void) {
        self.patient = patient
        self.medication = medication
        self.targetPrescription = nil
        self.onSave = onSave
    }
    
    /// Initialize for adding new medication to prescription
    init(patient: Patient, prescription: Prescription, onSave: @escaping (Medication) -> Void) {
        self.patient = patient
        self.medication = nil
        self.targetPrescription = prescription
        self.onSave = onSave
    }
    
    /// Initialize for adding new medication to patient
    init(patient: Patient, onSave: @escaping (Medication) -> Void) {
        self.patient = patient
        self.medication = nil
        self.targetPrescription = nil
        self.onSave = onSave
    }
    
    private var isEditingMode: Bool {
        medication != nil
    }
    
    private var editorTitle: String {
        isEditingMode ? "Edit Medication" : "Add Medication"
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
        duration != nil
    }
    
    private func submitForm() {
        withAnimation(.easeInOut(duration: 0.3)) {
            do {
                try save()
                dismiss()
            } catch {
                print(error)
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Spacing.large) {
                    // Context indicator for adding to prescription
                    if !isEditingMode, let prescription = targetPrescription {
                        contextIndicator(for: prescription)
                    }
                    
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
                                isRequired: false,
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
                if let medication = medication {
                    loadMedicationData(medication)
                }
            }
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
        .sheet(isPresented: $showFrequencyBottomSheet) {
            MedicationFrequencyBottomSheet(selectedFrequencies: $selectedFrequencies)
        }
        .notificationErrorHandling()
    }
    
    
    private func loadMedicationData(_ medication: Medication) {
        medicationName = medication.name ?? ""
        dosage = medication.dosage ?? ""
        instructions = medication.instructions ?? ""
        duration = medication.duration
        selectedFrequencies = medication.frequency ?? []
    }
    
    
    private func save() throws {
        guard let medicationDuration = duration else { return }
        
        let medicationToSave: Medication
        
        if isEditingMode {
            // Edit existing medication - update properties
            medicationToSave = medication!
            medicationToSave.updatedAt = Date()
        } else {
            // Create new medication
            medicationToSave = Medication(
                id: UUID(),
                name: "",
                frequency: nil,
                duration: medicationDuration,
                dosage: nil,
                instructions: nil,
                createdAt: Date(),
                updatedAt: Date(),
                patient: patient,
                prescription: targetPrescription,
            )
        }
        
        // Update medication properties
        medicationToSave.name = medicationName.trimmingCharacters(in: .whitespacesAndNewlines)
        medicationToSave.dosage = dosage.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : dosage.trimmingCharacters(in: .whitespacesAndNewlines)
        medicationToSave.instructions = instructions.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : instructions.trimmingCharacters(in: .whitespacesAndNewlines)
        medicationToSave.duration = medicationDuration
        medicationToSave.frequency = selectedFrequencies.isEmpty ? nil : selectedFrequencies
        
        if self.medication == nil {
            if self.targetPrescription == nil {
                // Adding standalone medication to patient
                if self.patient.medications == nil {
                    patient.medications = []
                }
                patient.medications!.append(medicationToSave)
                modelContext.insert(medicationToSave)
                try modelContext.save()
            } else {
                // Adding medication to prescription
                modelContext.insert(medicationToSave)
                if self.targetPrescription!.medications == nil {
                    targetPrescription!.medications = []
                }
                targetPrescription!.medications!.append(medicationToSave)
                try modelContext.save()
            }
        } else {
            // Updating existing medication
            try modelContext.save()
        }
        
        // Schedule notifications for the medication
        scheduleNotifications(for: medicationToSave)
        onSave(medicationToSave)
    }
    
    private func scheduleNotifications(for medication: Medication) {
        Task {
            // Reschedule all medications to enable grouping
            let result = await notificationManager.rescheduleAllMedicationNotifications(from: modelContext)
            switch result {
            case .success(let identifiers):
                print("Rescheduled \(identifiers.count) grouped notifications after adding/editing \(medication.name ?? "medication")")
            case .failure(let error):
                await MainActor.run {
                    errorHandler.handleError(error)
                }
            }
        }
    }
    
    // MARK: - Context Indicator
    
    @ViewBuilder
    private func contextIndicator(for prescription: Prescription) -> some View {
        VStack(spacing: Spacing.small) {
            HealthCard {
                HStack(spacing: Spacing.medium) {
                    // Prescription icon
                    Circle()
                        .fill(Color.blue.opacity(0.15))
                        .frame(width: 40, height: 40)
                        .overlay {
                            Image(systemName: "doc.text.fill")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundStyle(.blue)
                        }
                    
                    // Prescription details
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Adding medication to prescription")
                            .font(.system(.subheadline, design: .rounded, weight: .semibold))
                            .foregroundStyle(.primary)
                        
                        if let doctorName = prescription.doctorName {
                            Text("Dr. \(doctorName)")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        
                        if let dateIssued = prescription.dateIssued {
                            Text("Issued \(dateIssued.formatted(date: .abbreviated, time: .omitted))")
                                .font(.caption2)
                                .foregroundStyle(.tertiary)
                        }
                    }
                    
                    Spacer()
                }
            }
        }
        .padding(.horizontal, Spacing.medium)
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
