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
class Patient: Identifiable, Sendable {
    
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
    
    // Primary color for theming - stored as hex string
    var primaryColorHex: String?
    
    var createdAt: Date
    var updatedAt: Date
    
    @Relationship(deleteRule: .cascade, inverse: \MedicalCase.patient)
    var medicalCases: [MedicalCase]
    
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
        Calendar.current.dateComponents([.year], from: dateOfBirth, to: Date()).year ?? 0
    }
    
    // Computed property for initials
    var initials: String {
        let firstInitial = String(firstName.prefix(1).uppercased())
        let lastInitial = String(lastName.prefix(1).uppercased())
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
}
