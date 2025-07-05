//
//  Patient.swift
//  Walnut-Playground
//
//  Created by Mayank Gandhi on 29/06/25.
//  Copyright © 2025 m. All rights reserved.
//

import Foundation
import SwiftData

@Model
class Patient: Identifiable {
    
    @Attribute(.unique)
    var id: UUID
    
    var firstName: String
    var lastName: String
    var dateOfBirth: Date
    var gender: String
    var bloodType: String
    
    var emergencyContactName: String
    var emergencyContactPhone: String
    
    var notes: String
    var isActive: Bool
    
    var createdAt: Date
    var updatedAt: Date
    
    @Relationship(deleteRule: .cascade, inverse: \MedicalCase.patient)
    var medicalCases: [MedicalCase]
    
    init(id: UUID, firstName: String, lastName: String, dateOfBirth: Date, gender: String, bloodType: String, emergencyContactName: String, emergencyContactPhone: String, notes: String, isActive: Bool, createdAt: Date, updatedAt: Date, medicalCases: [MedicalCase]) {
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
        Calendar.current.dateComponents([.year], from: dateOfBirth, to: Date()).year ?? 0
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
        createdAt: Date(),
        updatedAt: Date(),
        medicalCases: []
    )
}
