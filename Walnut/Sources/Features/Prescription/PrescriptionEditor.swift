//
//  PrescriptionEditor.swift
//  Walnut
//
//  Created by Mayank Gandhi on 11/08/25.
//  Copyright © 2025 m. All rights reserved.
//

import SwiftUI
import SwiftData
import WalnutDesignSystem

struct PrescriptionEditor: View {
    
    let prescription: Prescription?
    let medicalCase: MedicalCase
    
    init(prescription: Prescription? = nil, medicalCase: MedicalCase) {
        self.prescription = prescription
        self.medicalCase = medicalCase
    }
    
    private var editorTitle: String {
        prescription == nil ? "Add Prescription" : "Edit Prescription"
    }
    
    @State private var doctorName = ""
    @State private var facilityName = ""
    @State private var dateIssued = Date()
    @State private var followUpDate: Date? = nil
    @State private var hasFollowUp = false
    @State private var followUpTests = ""
    @State private var notes = ""
    @State private var medications: [Medication] = []
    
    // Medication editor sheet states
    @State private var showMedicationEditor = false
    @State private var medicationToEdit: Medication? = nil
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    // Focus management for keyboard navigation
    @FocusState private var focusedField: FormField?
    
    private enum FormField: Hashable, CaseIterable {
        case doctorName
        case facilityName
        case followUpTests
        case notes
        
        private enum NextFieldType {
            case textField(FormField)
            case nonTextFieldOrEnd
        }
        
        private var nextFieldInUI: NextFieldType {
            switch self {
            case .doctorName:
                return .textField(.facilityName)
            case .facilityName:
                return .nonTextFieldOrEnd  // Next: Date picker
            case .followUpTests:
                return .textField(.notes)
            case .notes:
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
        !doctorName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
        !facilityName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    // Focus navigation helpers
    private func focusNextField(after currentField: FormField) {
        if currentField.shouldDismissKeyboard {
            if currentField == .notes && isFormValid {
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
                    // Prescription Information Section
                    VStack(alignment: .leading, spacing: Spacing.small) {
                        
                        Text("Prescription Information")
                            .font(.headline)
                            .foregroundStyle(.secondary)
                            .padding(.horizontal, Spacing.medium)

                        VStack(spacing: Spacing.medium) {
                            TextFieldItem(
                                icon: "person.fill.badge.plus",
                                title: "Doctor Name",
                                text: $doctorName,
                                placeholder: "Enter doctor's name",
                                iconColor: .healthPrimary,
                                contentType: .name,
                                submitLabel: FormField.doctorName.appropriateSubmitLabel,
                                onSubmit: {
                                    focusNextField(after: .doctorName)
                                }
                            )
                            .focused($focusedField, equals: .doctorName)
                            
                            TextFieldItem(
                                icon: "building.2.fill",
                                title: "Medical Facility",
                                text: $facilityName,
                                placeholder: "Enter medical facility name",
                                iconColor: .blue,
                                contentType: .organizationName,
                                submitLabel: FormField.facilityName.appropriateSubmitLabel,
                                onSubmit: {
                                    focusNextField(after: .facilityName)
                                }
                            )
                            .focused($focusedField, equals: .facilityName)
                            
                            DatePickerItem(
                                icon: "calendar",
                                title: "Date Issued",
                                selectedDate: Binding(
                                    get: { dateIssued },
                                    set: { dateIssued = $0 ?? Date() }
                                ),
                                helperText: "When the prescription was issued",
                                iconColor: .green,
                                isRequired: false
                            )
                        }
                    }
                    
                    // Medical Case Information Section
                    
                    VStack(alignment: .leading, spacing: Spacing.small) {
                        Text("Medical Case")
                            .font(.headline)
                            .foregroundStyle(.secondary)
                            .padding(.horizontal, Spacing.medium)
                        HealthCard {
                            HStack(spacing: Spacing.medium) {
                                
                                OptionalView(medicalCase.specialty) { specialty in
                                    Circle()
                                        .fill(specialty.color.opacity(0.15))
                                        .frame(width: Size.avatarLarge, height: Size.avatarLarge)
                                        .overlay {
                                            Image(systemName: specialty.icon)
                                                .font(.system(size: 18, weight: .semibold))
                                                .foregroundStyle(specialty.color)
                                        }
                                }
                                
                                VStack(alignment: .leading, spacing: Spacing.small) {
                                    
                                    OptionalView(medicalCase.title) { title in
                                        Text(title)
                                            .font(.headline.weight(.semibold))
                                            .foregroundStyle(.primary)
                                    }
                                    
                                    OptionalView(medicalCase.specialty) { specialty in
                                        Text(specialty.rawValue)
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }
                                    
                                    OptionalView(medicalCase.isActive) { isActive in
                                        HStack(spacing: Spacing.small) {
                                            HealthStatusIndicator(
                                                status: isActive ? .good : .warning,
                                                showIcon: false
                                            )
                                            
                                            
                                            Text(isActive ? "Active" : "Inactive")
                                                .font(.caption2.weight(.medium))
                                                .foregroundStyle(isActive ? Color.healthSuccess : Color.healthWarning)
                                        }
                                    }
                                    
                                    Spacer()
                                }
                            }
                        }
                    }
                    
                    // Follow-up Information Section
                    VStack(alignment: .leading, spacing: Spacing.small) {
                        Text("Follow-up Information")
                            .font(.headline)
                            .foregroundStyle(.secondary)
                            .padding(.horizontal, Spacing.medium)
                        
                        VStack(spacing: Spacing.medium) {
                            ToggleItem(
                                icon: hasFollowUp ? "calendar.badge.clock" : "calendar.badge.minus",
                                title: "Schedule Follow-up",
                                subtitle: "Set follow-up appointment",
                                isOn: $hasFollowUp,
                                helperText: "Enable to set follow-up date and tests",
                                iconColor: hasFollowUp ? .orange : .secondary
                            )
                            
                            if hasFollowUp {
                                DatePickerItem(
                                    icon: "calendar.badge.plus",
                                    title: "Follow-up Date",
                                    selectedDate: Binding(
                                        get: { followUpDate ?? Date().addingTimeInterval(7 * 24 * 60 * 60) },
                                        set: { followUpDate = $0 }
                                    ),
                                    helperText: "When to schedule the follow-up",
                                    iconColor: .orange,
                                    isRequired: false
                                )
                                
                                TextFieldItem(
                                    icon: "testtube.2",
                                    title: "Follow-up Tests",
                                    text: $followUpTests,
                                    placeholder: "Blood test, X-ray, etc. (comma-separated)",
                                    helperText: "Tests to be performed during follow-up",
                                    iconColor: .purple,
                                    submitLabel: FormField.followUpTests.appropriateSubmitLabel,
                                    onSubmit: {
                                        focusNextField(after: .followUpTests)
                                    }
                                )
                                .focused($focusedField, equals: .followUpTests)
                            }
                        }
                    }
                    
                    // Additional Information Section
                    VStack(alignment: .leading, spacing: Spacing.small) {
                        Text("Additional Information")
                            .font(.headline)
                            .foregroundStyle(.secondary)
                            .padding(.horizontal, Spacing.medium)
                        
                        TextFieldItem(
                            icon: "note.text",
                            title: "Prescription Notes",
                            text: $notes,
                            placeholder: "Additional notes or instructions",
                            helperText: "Any additional prescription details",
                            iconColor: .gray,
                            submitLabel: FormField.notes.appropriateSubmitLabel,
                            onSubmit: {
                                focusNextField(after: .notes)
                            }
                        )
                        .focused($focusedField, equals: .notes)
                    }
                    
                    // Medications Section
                    VStack(alignment: .leading, spacing: Spacing.small) {
                        HStack {
                            Text("Medications")
                                .font(.headline)
                                .foregroundStyle(.secondary)
                            
                            Spacer()
                            
                            Button {
                                medicationToEdit = nil
                                showMedicationEditor = true
                            } label: {
                                HStack(spacing: Spacing.small) {
                                    Image(systemName: "plus.circle.fill")
                                        .font(.system(size: 16, weight: .semibold))
                                    Text("Add")
                                        .font(.system(size: 14, weight: .medium))
                                }
                                .foregroundStyle(Color.healthPrimary)
                            }
                        }
                        .padding(.horizontal, Spacing.medium)
                        
                        if medications.isEmpty {
                            HealthCard {
                                VStack(spacing: Spacing.medium) {
                                    Circle()
                                        .fill(Color.secondary.opacity(0.15))
                                        .frame(width: Size.avatarLarge, height: Size.avatarLarge)
                                        .overlay {
                                            Image(systemName: "pills")
                                                .font(.system(size: 24, weight: .semibold))
                                                .foregroundStyle(.secondary)
                                        }
                                    
                                    VStack(spacing: Spacing.small) {
                                        Text("No Medications Added")
                                            .font(.headline.weight(.semibold))
                                            .foregroundStyle(.primary)
                                        
                                        Text("Tap the Add button to add medications to this prescription")
                                            .font(.body)
                                            .foregroundStyle(.secondary)
                                            .multilineTextAlignment(.center)
                                    }
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, Spacing.medium)
                            }
                        } else {
                            VStack(spacing: Spacing.medium) {
                                ForEach(medications) { medication in
                                    medicationListItem(medication: medication)
                                }
                            }
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
                if let prescription {
                    loadPrescriptionData(prescription)
                }
            }
            .sheet(isPresented: $showMedicationEditor) {
                if let medicationToEdit = medicationToEdit {
                    MedicationEditor(
                        medication: medicationToEdit,
                        onSave: handleMedicationSave
                    )
                } else {
                    MedicationEditor(
                        medication: nil,
                        onSave: handleMedicationSave
                    )
                }
            }
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
    }
    
    
    @ViewBuilder
    private func medicationListItem(medication: Medication) -> some View {
        HealthCard {
            HStack(spacing: Spacing.medium) {
                // Medication icon
                Circle()
                    .fill(Color.healthPrimary.opacity(0.15))
                    .frame(width: Size.avatarMedium, height: Size.avatarMedium)
                    .overlay {
                        Text(String(medication.name?.prefix(1).uppercased() ?? "P"))
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(Color.healthPrimary)
                    }
                
                // Medication details
                VStack(alignment: .leading, spacing: Spacing.small) {
                    OptionalView(medication.name) { name in
                        Text(name)
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.primary)
                    }
                    
                    
                    HStack(spacing: Spacing.small) {
                        if let dosage = medication.dosage {
                            Text(dosage)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        
                        if medication.dosage != nil && medication.numberOfDays > 0 {
                            Text("•")
                                .font(.caption)
                                .foregroundStyle(.tertiary)
                        }
                        
                        if medication.numberOfDays > 0 {
                            Text("\(medication.numberOfDays) days")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    
                    // Frequency display
                    if let frequency = medication.frequency,
                       frequency.isEmpty {
                        HStack(spacing: Spacing.small) {
                            ForEach(frequency.prefix(3), id: \.mealTime) { schedule in
                                frequencyBadge(for: schedule)
                            }
                            
                            if frequency.count > 3 {
                                Text("+\(frequency.count - 3)")
                                    .font(.caption2.weight(.medium))
                                    .foregroundStyle(.secondary)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(Color.secondary.opacity(0.1), in: Capsule())
                            }
                        }
                    }
                }
                
                Spacer()
                
                // Edit button
                Button {
                    medicationToEdit = medication
                    showMedicationEditor = true
                } label: {
                    Image(systemName: "pencil.circle.fill")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundStyle(Color.healthPrimary)
                }
                .buttonStyle(.borderless)
            }
        }
    }
    
    @ViewBuilder
    private func frequencyBadge(for schedule: MedicationSchedule) -> some View {
        HStack(spacing: 2) {
            Image(systemName: schedule.mealTime.icon)
                .font(.caption2)
            
            Text(schedule.mealTime.rawValue.prefix(1).uppercased())
                .font(.caption2.weight(.medium))
        }
        .foregroundStyle(schedule.mealTime.color)
        .padding(.horizontal, 6)
        .padding(.vertical, 2)
        .background(schedule.mealTime.color.opacity(0.1), in: Capsule())
    }
    
    private func handleMedicationSave(_ medication: Medication) {
        if let index = medications.firstIndex(where: { $0.id == medication.id }) {
            // Update existing medication
            medications[index] = medication
        } else {
            // Add new medication
            medications.append(medication)
        }
    }
    
    private func loadPrescriptionData(_ prescription: Prescription) {
        doctorName = prescription.doctorName ?? ""
        facilityName = prescription.facilityName ?? ""
        if let dateIssued = prescription.dateIssued {
            self.dateIssued = dateIssued
        }
        followUpDate = prescription.followUpDate
        hasFollowUp = prescription.followUpDate != nil
        followUpTests = prescription.followUpTests?.joined(separator: ", ") ?? ""
        notes = prescription.notes ?? ""
        medications = prescription.medications ?? []
    }
    
    private func save() {
        let now = Date()
        
        // Parse follow-up tests
        let testsArray = followUpTests
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .isEmpty ? [] : followUpTests
            .components(separatedBy: ",")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        
        if let prescription {
            // Edit existing prescription
            prescription.doctorName = doctorName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : doctorName.trimmingCharacters(in: .whitespacesAndNewlines)
            prescription.facilityName = facilityName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : facilityName.trimmingCharacters(in: .whitespacesAndNewlines)
            prescription.dateIssued = dateIssued
            prescription.followUpDate = hasFollowUp ? followUpDate : nil
            prescription.followUpTests = testsArray.isEmpty ? nil : testsArray
            prescription.notes = notes.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : notes.trimmingCharacters(in: .whitespacesAndNewlines)
            prescription.medications = medications
            prescription.updatedAt = now
        } else {
            // Create new prescription
            let newPrescription = Prescription(
                id: UUID(),
                followUpDate: hasFollowUp ? followUpDate : nil,
                followUpTests: testsArray.isEmpty ? [] : testsArray,
                dateIssued: dateIssued,
                doctorName: doctorName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : doctorName.trimmingCharacters(in: .whitespacesAndNewlines),
                facilityName: facilityName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : facilityName.trimmingCharacters(in: .whitespacesAndNewlines),
                notes: notes.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : notes.trimmingCharacters(in: .whitespacesAndNewlines),
                document: nil,
                medicalCase: medicalCase,
                medications: medications
            )
            modelContext.insert(newPrescription)
        }
    }
}

#Preview("Add Prescription") {
    PrescriptionEditor(prescription: nil, medicalCase: .sampleCase)
        .modelContainer(for: Prescription.self, inMemory: true)
}

#Preview("Edit Prescription") {
    let samplePrescription = Prescription(
        id: UUID(),
        followUpDate: Date().addingTimeInterval(7 * 24 * 60 * 60),
        followUpTests: ["Blood test", "X-ray"],
        dateIssued: Date(),
        doctorName: "Dr. John Smith",
        facilityName: "General Hospital",
        notes: "Take with food",
        document: Document(
            fileName: "Sample_Prescription",
            fileURL: "pas.pasd",
            documentType: .prescription,
            fileSize: 0
        ),
        medicalCase: .sampleCase,
        medications: []
    )
    
    PrescriptionEditor(prescription: samplePrescription, medicalCase: .sampleCase)
        .modelContainer(for: Prescription.self, inMemory: true)
}
