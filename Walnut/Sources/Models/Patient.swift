//
//  Patient.swift
//  Walnut-Playground
//
//  Created by Mayank Gandhi on 29/06/25.
//  Copyright © 2025 m. All rights reserved.
//

import Foundation
import SwiftData
import SwiftUI

@Model
class Patient: Identifiable, Sendable, Hashable {
    
    var id: UUID?
    
    var firstName: String?
    var lastName: String?
    var dateOfBirth: Date?
    var gender: String?
    var bloodType: String?
    
    var emergencyContactName: String?
    var emergencyContactPhone: String?
    
    var notes: String?
    var isActive: Bool?
    
    // Primary color for theming - stored as hex string
    var primaryColorHex: String?
    
    var createdAt: Date?
    var updatedAt: Date?
    
    @Relationship(deleteRule: .cascade, inverse: \MedicalCase.patient)
    var medicalCases: [MedicalCase]?
    
    init(id: UUID, firstName: String, lastName: String, dateOfBirth: Date, gender: String, bloodType: String, emergencyContactName: String, emergencyContactPhone: String, notes: String, isActive: Bool, primaryColorHex: String? = nil, createdAt: Date, updatedAt: Date, medicalCases: [MedicalCase]) {
        self.id = id
        self.firstName = firstName
        self.lastName = lastName
        self.dateOfBirth = dateOfBirth
        self.gender = gender
        self.bloodType = bloodType
        self.emergencyContactName = emergencyContactName
        self.emergencyContactPhone = emergencyContactPhone
        self.notes = notes
        self.isActive = isActive
        self.primaryColorHex = primaryColorHex ?? Self.generateRandomColorHex()
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.medicalCases = medicalCases
    }
    
    // Computed property for full name
    var fullName: String {
        "\(firstName) \(lastName)"
    }
    
    // Computed property for age
    var age: Int {
        guard let dateOfBirth else { return 0 }
        return Calendar.current.dateComponents([.year], from: dateOfBirth, to: Date()).year ?? 0
    }
    
    // Computed property for initials
    var initials: String {
        let firstInitial = firstName?.prefix(1).uppercased() ?? ""
        let lastInitial = lastName?.prefix(1).uppercased() ?? ""
        return "\(firstInitial)\(lastInitial)"
    }
    
    // Computed property for primary color
    var primaryColor: Color {
        Color(hex: primaryColorHex ?? Patient.generateRandomColorHex()) ?? .blue
    }
    
    // Static method to generate random color hex
    static func generateRandomColorHex() -> String {
        let colors = [
            "#FF6B6B", "#4ECDC4", "#45B7D1", "#96CEB4", "#FFEAA7",
            "#DDA0DD", "#98D8C8", "#F7DC6F", "#BB8FCE", "#85C1E9",
            "#F8C471", "#82E0AA", "#F1948A", "#85C1CC", "#D2B4DE",
            "#AED6F1", "#A3E4D7", "#F9E79F", "#FADBD8", "#D5DBDB"
        ]
        return colors.randomElement() ?? "#4ECDC4"
    }
    
    // Method to update primary color
    func updatePrimaryColor(_ colorHex: String) {
        self.primaryColorHex = colorHex
        self.updatedAt = Date()
    }
    
    // MARK: - Hashable Conformance
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: Patient, rhs: Patient) -> Bool {
        lhs.id == rhs.id
    }
}


// MARK: - Sample Data
extension Patient {
    static let samplePatient = Patient(
        id: UUID(),
        firstName: "John",
        lastName: "Doe",
        dateOfBirth: Calendar.current.date(byAdding: .year, value: -35, to: Date()) ?? Date(),
        gender: "Male",
        bloodType: "A+",
        emergencyContactName: "Jane Doe",
        emergencyContactPhone: "(555) 123-4567",
        notes: "Patient has mild allergies to penicillin.",
        isActive: true,
        primaryColorHex: "#4ECDC4",
        createdAt: Date(),
        updatedAt: Date(),
        medicalCases: []
    )
    
    @MainActor
    static let samplePatientWithMedications: Patient = {
        let patient = Patient(
            id: UUID(),
            firstName: "Sarah",
            lastName: "Wilson",
            dateOfBirth: Calendar.current.date(byAdding: .year, value: -42, to: Date()) ?? Date(),
            gender: "Female",
            bloodType: "O+",
            emergencyContactName: "Robert Wilson",
            emergencyContactPhone: "(555) 987-6543",
            notes: "Patient with diabetes and hypertension. Regular monitoring required.",
            isActive: true,
            primaryColorHex: "#FF6B6B",
            createdAt: Date(),
            updatedAt: Date(),
            medicalCases: []
        )
        
        // Create medical case for diabetes management
        let diabetesCase = MedicalCase(
            id: UUID(),
            title: "Type 2 Diabetes Management",
            notes: "Patient diagnosed with Type 2 diabetes 3 years ago. Good control with medication and lifestyle changes.",
            type: .treatment,
            specialty: .endocrinologist,
            isActive: true,
            createdAt: Date().addingTimeInterval(-86400 * 30),
            updatedAt: Date(),
            patient: patient
        )
        
        // Create medical case for hypertension
        let hypertensionCase = MedicalCase(
            id: UUID(),
            title: "Essential Hypertension",
            notes: "Well-controlled hypertension with ACE inhibitor therapy.",
            type: .treatment,
            specialty: .cardiologist,
            isActive: true,
            createdAt: Date().addingTimeInterval(-86400 * 60),
            updatedAt: Date(),
            patient: patient
        )
        
        // Create prescriptions with medications
        let diabetesPrescription = Prescription(
            id: UUID(),
            followUpDate: Date().addingTimeInterval(86400 * 90),
            followUpTests: ["HbA1c", "Kidney function"],
            dateIssued: Date().addingTimeInterval(-86400 * 7),
            doctorName: "Dr. Emily Chen",
            facilityName: "Diabetes Care Center",
            notes: "Continue current medications. Monitor blood sugar daily.",
            document: nil,
            medicalCase: diabetesCase,
            medications: [
                Medication(
                    id: UUID(),
                    name: "Metformin",
                    frequency: [
                        MedicationSchedule(mealTime: .breakfast, timing: .after, dosage: "500mg"),
                        MedicationSchedule(mealTime: .dinner, timing: .after, dosage: "500mg")
                    ],
                    numberOfDays: 90,
                    dosage: "500mg",
                    instructions: "Take with meals to control blood sugar"
                ),
                Medication(
                    id: UUID(),
                    name: "Insulin Glargine",
                    frequency: [
                        MedicationSchedule(mealTime: .bedtime, timing: .before, dosage: "20 units")
                    ],
                    numberOfDays: 90,
                    dosage: "20 units",
                    instructions: "Inject subcutaneously at bedtime"
                )
            ]
        )
        
        let hypertensionPrescription = Prescription(
            id: UUID(),
            followUpDate: Date().addingTimeInterval(86400 * 60),
            followUpTests: ["Blood pressure monitoring"],
            dateIssued: Date().addingTimeInterval(-86400 * 14),
            doctorName: "Dr. James Rodriguez",
            facilityName: "Heart Care Clinic",
            notes: "Blood pressure well controlled. Continue current therapy.",
            document: nil,
            medicalCase: hypertensionCase,
            medications: [
                Medication(
                    id: UUID(),
                    name: "Lisinopril",
                    frequency: [
                        MedicationSchedule(mealTime: .breakfast, timing: .before, dosage: "10mg")
                    ],
                    numberOfDays: 90,
                    dosage: "10mg",
                    instructions: "Take at the same time each morning"
                ),
                Medication(
                    id: UUID(),
                    name: "Amlodipine",
                    frequency: [
                        MedicationSchedule(mealTime: .breakfast, timing: .after, dosage: "5mg")
                    ],
                    numberOfDays: 90,
                    dosage: "5mg",
                    instructions: "Take once daily with breakfast"
                )
            ]
        )
        
        // Add prescriptions to medical cases
        diabetesCase.prescriptions = [diabetesPrescription]
        hypertensionCase.prescriptions = [hypertensionPrescription]
        
        // Add medical cases to patient
        patient.medicalCases = [diabetesCase, hypertensionCase]
        
        return patient
    }()
}
