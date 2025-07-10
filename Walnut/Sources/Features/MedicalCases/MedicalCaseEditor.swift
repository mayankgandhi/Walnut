//
//  MedicalCaseEditor.swift
//  Walnut
//
//  Created by Mayank Gandhi on 05/07/25.
//  Copyright © 2025 m. All rights reserved.
//

import SwiftUI
import SwiftData

struct MedicalCaseEditor: View {
    let medicalCase: MedicalCase?
    let patient: Patient
    
    init(medicalCase: MedicalCase? = nil, patient: Patient) {
        self.medicalCase = medicalCase
        self.patient = patient
    }
    
    private var editorTitle: String {
        medicalCase == nil ? "Add Medical Case" : "Edit Medical Case"
    }
    
    @State private var title = ""
    @State private var notes = ""
    @State private var treatmentPlan = ""
    @State private var selectedType: MedicalCaseType = .consultation
    @State private var selectedSpecialty: MedicalSpecialty = .generalPractitioner
    @State private var isActive = true
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    private var isFormValid: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !treatmentPlan.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Case Information") {
                    HStack {
                        Image(systemName: "doc.text.fill")
                            .foregroundColor(.blue)
                            .font(.title2)
                        
                        TextField("Case Title", text: $title)
                            .autocorrectionDisabled()
                    }
                    
                    HStack {
                        Image(systemName: "medical.thermometer")
                            .foregroundColor(.green)
                            .font(.title2)
                        
                        Picker("Case Type", selection: $selectedType) {
                            ForEach(MedicalCaseType.allCases, id: \.self) { type in
                                Text(type.displayName)
                                    .tag(type)
                            }
                        }
                        .pickerStyle(.menu)
                    }
                    
                    HStack {
                        Image(systemName: "stethoscope")
                            .foregroundColor(.purple)
                            .font(.title2)
                        
                        Picker("Specialty", selection: $selectedSpecialty) {
                            ForEach(MedicalSpecialty.allCases, id: \.self) { specialty in
                                Text(specialty.rawValue)
                                    .tag(specialty)
                            }
                        }
                        .pickerStyle(.menu)
                    }
                }
                
                Section("Patient Information") {
                    HStack {
                        Image(systemName: "person.circle.fill")
                            .foregroundColor(.blue)
                            .font(.title2)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("\(patient.firstName) \(patient.lastName)")
                                .font(.system(size: 16, weight: .medium))
                            Text("Patient")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                    }
                }
                
                Section("Clinical Details") {
                    HStack {
                        Image(systemName: "note.text")
                            .foregroundColor(.orange)
                            .font(.title2)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Notes")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            TextField("Clinical notes and observations", text: $notes, axis: .vertical)
                                .lineLimit(3...6)
                        }
                    }
                    .padding(.vertical, 4)
                    
                    HStack {
                        Image(systemName: "cross.case.fill")
                            .foregroundColor(.red)
                            .font(.title2)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Treatment Plan")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            TextField("Treatment plan and recommendations", text: $treatmentPlan, axis: .vertical)
                                .lineLimit(3...6)
                        }
                    }
                    .padding(.vertical, 4)
                }
                
                Section("Status") {
                    HStack {
                        Image(systemName: isActive ? "checkmark.circle.fill" : "xmark.circle.fill")
                            .foregroundColor(isActive ? .green : .red)
                            .font(.title2)
                        
                        Toggle("Active Case", isOn: $isActive)
                    }
                    .padding(.vertical, 4)
                }
            }
            .navigationTitle(editorTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            save()
                            dismiss()
                        }
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
        title = medicalCase.title
        notes = medicalCase.notes
        treatmentPlan = medicalCase.treatmentPlan
        selectedType = medicalCase.type
        selectedSpecialty = medicalCase.specialty
        isActive = medicalCase.isActive
    }
    
    private func save() {
        let now = Date()
        
        if let medicalCase {
            // Edit existing medical case
            medicalCase.title = title.trimmingCharacters(in: .whitespacesAndNewlines)
            medicalCase.notes = notes.trimmingCharacters(in: .whitespacesAndNewlines)
            medicalCase.treatmentPlan = treatmentPlan.trimmingCharacters(in: .whitespacesAndNewlines)
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
                treatmentPlan: treatmentPlan.trimmingCharacters(in: .whitespacesAndNewlines),
                type: selectedType,
                specialty: selectedSpecialty,
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
