//
//  CreatePatientView.swift
//  Walnut
//
//  Created by Mayank Gandhi on 01/08/25.
//  Copyright © 2025 m. All rights reserved.
//

import SwiftUI
import SwiftData

struct CreatePatientView: View {
    
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var dateOfBirth = Date()
    @State private var phoneNumber = ""
    @State private var notes = ""
    @State private var selectedColor = Color(hex: Patient.generateRandomColorHex()) ?? .blue
    
    @State private var showingValidationError = false
    @State private var validationMessage = ""
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    private var isFormValid: Bool {
        !firstName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !lastName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    private var validationErrors: [String] {
        var errors: [String] = []
        
        if firstName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            errors.append("First name is required")
        }
        
        if lastName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            errors.append("Last name is required")
        }
        
        if dateOfBirth > Date() {
            errors.append("Date of birth cannot be in the future")
        }
        
        return errors
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    VStack(alignment: .leading, spacing: 16) {
                        // Name Fields
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Image(systemName: "person.circle.fill")
                                    .foregroundColor(.blue)
                                    .font(.title2)
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    TextField("First Name", text: $firstName)
                                        .textContentType(.givenName)
                                        .autocorrectionDisabled()
                                        .overlay(alignment: .trailing) {
                                            if !firstName.isEmpty && firstName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                                                Image(systemName: "exclamationmark.triangle.fill")
                                                    .foregroundColor(.orange)
                                                    .font(.caption)
                                            }
                                        }
                                    
                                    TextField("Last Name", text: $lastName)
                                        .textContentType(.familyName)
                                        .autocorrectionDisabled()
                                        .overlay(alignment: .trailing) {
                                            if !lastName.isEmpty && lastName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                                                Image(systemName: "exclamationmark.triangle.fill")
                                                    .foregroundColor(.orange)
                                                    .font(.caption)
                                            }
                                        }
                                }
                            }
                        }
                        
                        // Date of Birth
                        HStack {
                            Image(systemName: "calendar")
                                .foregroundColor(.orange)
                                .font(.title2)
                            
                            DatePicker("Date of Birth", 
                                     selection: $dateOfBirth,
                                     in: ...Date(),
                                     displayedComponents: .date)
                        }
                        
                        // Phone Number (Optional)
                        HStack {
                            Image(systemName: "phone.circle.fill")
                                .foregroundColor(.green)
                                .font(.title2)
                            
                            TextField("Phone Number (Optional)", text: $phoneNumber)
                                .textContentType(.telephoneNumber)
                                .keyboardType(.phonePad)
                        }
                        
                        // Notes (Optional)
                        HStack(alignment: .top) {
                            Image(systemName: "note.text")
                                .foregroundColor(.gray)
                                .font(.title2)
                                .padding(.top, 2)
                            
                            TextField("Brief notes (Optional)", text: $notes, axis: .vertical)
                                .lineLimit(2...4)
                        }
                        
                        // Theme Color Selection
                        HStack {
                            Image(systemName: "paintpalette.fill")
                                .foregroundColor(selectedColor)
                                .font(.title2)
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Theme Color")
                                    .font(.subheadline)
                                    .foregroundColor(.primary)
                                
                                HStack {
                                    ColorPicker("", selection: $selectedColor, supportsOpacity: false)
                                        .labelsHidden()
                                        .frame(width: 44, height: 32)
                                    
                                    Text("This color will theme the patient's profile")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    
                                    Spacer()
                                }
                            }
                        }
                    }
                    .padding(.vertical, 4)
                } header: {
                    Text("Essential Information")
                } footer: {
                    if !validationErrors.isEmpty {
                        VStack(alignment: .leading, spacing: 4) {
                            ForEach(validationErrors, id: \.self) { error in
                                HStack {
                                    Image(systemName: "exclamationmark.triangle.fill")
                                        .foregroundColor(.orange)
                                        .font(.caption)
                                    Text(error)
                                        .font(.caption)
                                        .foregroundColor(.orange)
                                }
                            }
                        }
                        .padding(.top, 8)
                    }
                }
            }
            .navigationTitle("New Patient")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        savePatient()
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
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }
    
    private func savePatient() {
        let now = Date()
        
        let newPatient = Patient(
            id: UUID(),
            firstName: firstName.trimmingCharacters(in: .whitespacesAndNewlines),
            lastName: lastName.trimmingCharacters(in: .whitespacesAndNewlines),
            dateOfBirth: dateOfBirth,
            gender: "Not Specified", // Default for minimalist creation
            bloodType: "Unknown", // Default for minimalist creation
            emergencyContactName: "", // Empty for minimalist creation
            emergencyContactPhone: phoneNumber.trimmingCharacters(in: .whitespacesAndNewlines),
            notes: notes.trimmingCharacters(in: .whitespacesAndNewlines),
            isActive: true, // Default active
            primaryColorHex: selectedColor.hexString,
            createdAt: now,
            updatedAt: now,
            medicalCases: []
        )
        
        modelContext.insert(newPatient)
        
        // Save context and dismiss with animation
        withAnimation(.easeInOut(duration: 0.3)) {
            dismiss()
        }
    }
}

#Preview("Create Patient") {
    CreatePatientView()
        .modelContainer(for: Patient.self, inMemory: true)
}
