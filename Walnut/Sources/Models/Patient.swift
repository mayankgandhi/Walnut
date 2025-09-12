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
    
    var name: String?
    var dateOfBirth: Date?
    var gender: String?
    var bloodType: String?
    
    var emergencyContactName: String?
    var emergencyContactPhone: String?
    
    var notes: String?
    
    var createdAt: Date?
    var updatedAt: Date?
    
    @Relationship(deleteRule: .cascade, inverse: \MedicalCase.patient)
    var medicalCases: [MedicalCase]?
    
    init(id: UUID, name: String, dateOfBirth: Date, gender: String, bloodType: String, emergencyContactName: String?, emergencyContactPhone: String?, notes: String, createdAt: Date, updatedAt: Date, medicalCases: [MedicalCase]) {
        self.id = id
        self.name = name
        self.dateOfBirth = dateOfBirth
        self.gender = gender
        self.bloodType = bloodType
        self.emergencyContactName = emergencyContactName
        self.emergencyContactPhone = emergencyContactPhone
        self.notes = notes
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.medicalCases = medicalCases
    }
    
    // Computed property for age
    var age: Int {
        guard let dateOfBirth else { return 0 }
        return Calendar.current.dateComponents([.year], from: dateOfBirth, to: Date()).year ?? 0
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
        name: "John Doe",
        dateOfBirth: Calendar.current.date(byAdding: .year, value: -35, to: Date()) ?? Date(),
        gender: "Male",
        bloodType: "A+",
        emergencyContactName: "Jane Doe",
        emergencyContactPhone: "(555) 123-4567",
        notes: "Patient has mild allergies to penicillin.",
        createdAt: Date(),
        updatedAt: Date(),
        medicalCases: []
    )
    
    @MainActor
    static let samplePatientWithMedications: Patient = {
        let patient = Patient(
            id: UUID(),
            name: "Sarah Wilson",
            dateOfBirth: Calendar.current.date(byAdding: .year, value: -42, to: Date()) ?? Date(),
            gender: "Female",
            bloodType: "O+",
            emergencyContactName: "Robert Wilson",
            emergencyContactPhone: "(555) 987-6543",
            notes: "Patient with diabetes and hypertension. Regular monitoring required.",
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
                    frequency: [],
                    duration: .days(90),
                    dosage: "500mg",
                    instructions: "Take with meals to control blood sugar"
                ),
                Medication(
                    id: UUID(),
                    name: "Insulin Glargine",
                    frequency: [],
                    duration: .days(90),
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
                    frequency: [],
                    duration: .days(90),
                    dosage: "10mg",
                    instructions: "Take at the same time each morning"
                ),
                Medication(
                    id: UUID(),
                    name: "Amlodipine",
                    frequency: [],
                    duration: .days(90),
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
    
    @MainActor
    static let samplePatientWithComplexMedications: Patient = {
        let patient = Patient(
            id: UUID(),
            name: "Michael Chen",
            dateOfBirth: Calendar.current.date(byAdding: .year, value: -55, to: Date()) ?? Date(),
            gender: "Male",
            bloodType: "A+",
            emergencyContactName: "Lisa Chen",
            emergencyContactPhone: "(555) 456-7890",
            notes: "Complex medication regimen including injections, drops, and as-needed medications.",
            createdAt: Date(),
            updatedAt: Date(),
            medicalCases: []
        )
        
        // Create medical case for rheumatoid arthritis
        let arthritisCase = MedicalCase(
            id: UUID(),
            title: "Rheumatoid Arthritis Treatment",
            notes: "Patient requires bi-weekly methotrexate injections and daily medications.",
            type: .treatment,
            specialty: .rheumatologist,
            isActive: true,
            createdAt: Date().addingTimeInterval(-86400 * 60),
            updatedAt: Date(),
            patient: patient
        )
        
        // Create medical case for glaucoma
        let glaucomaCase = MedicalCase(
            id: UUID(),
            title: "Glaucoma Management",
            notes: "Requires regular eye drops every 12 hours.",
            type: .treatment,
            specialty: .ophthalmologist,
            isActive: true,
            createdAt: Date().addingTimeInterval(-86400 * 30),
            updatedAt: Date(),
            patient: patient
        )
        
        // Prescription with complex frequencies
        let arthritisPrescription = Prescription(
            id: UUID(),
            followUpDate: Date().addingTimeInterval(86400 * 14),
            followUpTests: ["ESR", "CRP", "Liver function"],
            dateIssued: Date().addingTimeInterval(-86400 * 3),
            doctorName: "Dr. Sarah Kim",
            facilityName: "Rheumatology Center",
            notes: "Monitor liver function tests bi-weekly. Injectable methotrexate self-administered.",
            document: nil,
            medicalCase: arthritisCase,
            medications: [ ]
        )
        
        let glaucomaPrescription = Prescription(
            id: UUID(),
            followUpDate: Date().addingTimeInterval(86400 * 30),
            followUpTests: ["IOP measurement", "Visual field test"],
            dateIssued: Date().addingTimeInterval(-86400 * 5),
            doctorName: "Dr. Robert Martinez",
            facilityName: "Eye Care Specialists",
            notes: "Continue current eye drop regimen. Check IOP in 4 weeks.",
            document: nil,
            medicalCase: glaucomaCase,
            medications: [ ]
        )
        
        // Add prescriptions to medical cases
        arthritisCase.prescriptions = [arthritisPrescription]
        glaucomaCase.prescriptions = [glaucomaPrescription]
        
        // Add medical cases to patient
        patient.medicalCases = [arthritisCase, glaucomaCase]
        
        return patient
    }()
}
