//
//  PatientEditor.swift
//  Walnut
//
//  Created by Mayank Gandhi on 03/07/25.
//  Copyright © 2025 m. All rights reserved.
//


import SwiftUI
import SwiftData

struct PatientEditor: View {
    let patient: Patient?
    
    init(patient: Patient? = nil) {
        self.patient = patient
    }
    
    private var editorTitle: String {
        patient == nil ? "Add Patient" : "Edit Patient"
    }
    
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var dateOfBirth = Date()
    @State private var selectedGender = "Not Specified"
    @State private var selectedBloodType = "Unknown"
    @State private var emergencyContactName = ""
    @State private var emergencyContactPhone = ""
    @State private var notes = ""
    @State private var isActive = true
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    private let genderOptions = ["Male", "Female", "Not Specified"]
    private let bloodTypeOptions = ["A+", "A-", "B+", "B-", "AB+", "AB-", "O+", "O-", "Unknown"]
    
    private var isFormValid: Bool {
        !firstName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !lastName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Personal Information") {
                    HStack {
                        Image(systemName: "person.circle.fill")
                            .foregroundColor(.blue)
                            .font(.title2)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            TextField("First Name", text: $firstName)
                                .textContentType(.givenName)
                                .autocorrectionDisabled()
                            
                            TextField("Last Name", text: $lastName)
                                .textContentType(.familyName)
                                .autocorrectionDisabled()
                        }
                    }
                    .padding(.vertical, 4)
                    
                    HStack {
                        Image(systemName: "calendar")
                            .foregroundColor(.orange)
                            .font(.title2)
                        
                        DatePicker("Date of Birth", 
                                 selection: $dateOfBirth,
                                 in: ...Date(),
                                 displayedComponents: .date)
                    }
                    .padding(.vertical, 4)
                    
                    HStack {
                        Image(systemName: "person.2")
                            .foregroundColor(.purple)
                            .font(.title2)
                        
                        Picker("Gender", selection: $selectedGender) {
                            ForEach(genderOptions, id: \.self) { gender in
                                Text(gender).tag(gender)
                            }
                        }
                        .pickerStyle(.menu)
                    }
                    .padding(.vertical, 4)
                    
                    HStack {
                        Image(systemName: "drop.fill")
                            .foregroundColor(.red)
                            .font(.title2)
                        
                        Picker("Blood Type", selection: $selectedBloodType) {
                            ForEach(bloodTypeOptions, id: \.self) { bloodType in
                                Text(bloodType).tag(bloodType)
                            }
                        }
                        .pickerStyle(.menu)
                    }
                    .padding(.vertical, 4)
                }
                
                Section("Emergency Contact") {
                    HStack {
                        Image(systemName: "person.crop.circle.badge.exclamationmark")
                            .foregroundColor(.red)
                            .font(.title2)
                        
                        TextField("Emergency Contact Name", text: $emergencyContactName)
                            .textContentType(.name)
                            .autocorrectionDisabled()
                    }
                    .padding(.vertical, 4)
                    
                    HStack {
                        Image(systemName: "phone.circle.fill")
                            .foregroundColor(.green)
                            .font(.title2)
                        
                        TextField("Emergency Contact Phone", text: $emergencyContactPhone)
                            .textContentType(.telephoneNumber)
                            .keyboardType(.phonePad)
                    }
                    .padding(.vertical, 4)
                }
                
                Section("Additional Information") {
                    HStack {
                        Image(systemName: "note.text")
                            .foregroundColor(.gray)
                            .font(.title2)
                        
                        TextField("Notes", text: $notes, axis: .vertical)
                            .lineLimit(3...6)
                    }
                    .padding(.vertical, 4)
                    
                    HStack {
                        Image(systemName: isActive ? "checkmark.circle.fill" : "xmark.circle.fill")
                            .foregroundColor(isActive ? .green : .red)
                            .font(.title2)
                        
                        Toggle("Active Patient", isOn: $isActive)
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
                if let patient {
                    loadPatientData(patient)
                }
            }
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
    }
    
    private func loadPatientData(_ patient: Patient) {
        firstName = patient.firstName
        lastName = patient.lastName
        dateOfBirth = patient.dateOfBirth
        selectedGender = patient.gender
        selectedBloodType = patient.bloodType
        emergencyContactName = patient.emergencyContactName
        emergencyContactPhone = patient.emergencyContactPhone
        notes = patient.notes
        isActive = patient.isActive
    }
    
    private func save() {
        let now = Date()
        
        if let patient {
            // Edit existing patient
            patient.firstName = firstName.trimmingCharacters(in: .whitespacesAndNewlines)
            patient.lastName = lastName.trimmingCharacters(in: .whitespacesAndNewlines)
            patient.dateOfBirth = dateOfBirth
            patient.gender = selectedGender
            patient.bloodType = selectedBloodType
            patient.emergencyContactName = emergencyContactName.trimmingCharacters(in: .whitespacesAndNewlines)
            patient.emergencyContactPhone = emergencyContactPhone.trimmingCharacters(in: .whitespacesAndNewlines)
            patient.notes = notes.trimmingCharacters(in: .whitespacesAndNewlines)
            patient.isActive = isActive
            patient.updatedAt = now
        } else {
            // Create new patient
            let newPatient = Patient(
                id: UUID(),
                firstName: firstName.trimmingCharacters(in: .whitespacesAndNewlines),
                lastName: lastName.trimmingCharacters(in: .whitespacesAndNewlines),
                dateOfBirth: dateOfBirth,
                gender: selectedGender,
                bloodType: selectedBloodType,
                emergencyContactName: emergencyContactName.trimmingCharacters(in: .whitespacesAndNewlines),
                emergencyContactPhone: emergencyContactPhone.trimmingCharacters(in: .whitespacesAndNewlines),
                notes: notes.trimmingCharacters(in: .whitespacesAndNewlines),
                isActive: isActive,
                createdAt: now,
                updatedAt: now,
                medicalCases: []
            )
            modelContext.insert(newPatient)
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
