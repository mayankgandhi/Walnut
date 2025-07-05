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
    
    init(id: UUID, firstName: String, lastName: String, dateOfBirth: Date, gender: String, bloodType: String, emergencyContactName: String, emergencyContactPhone: String, notes: String, isActive: Bool, createdAt: Date, updatedAt: Date) {
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
    static var sampleData: [Patient] = [
        Patient(
            id: UUID(),
            firstName: "Sarah",
            lastName: "Johnson",
            dateOfBirth: Calendar.current.date(from: DateComponents(year: 1985, month: 3, day: 15))!,
            gender: "Female",
            bloodType: "A+",
            emergencyContactName: "Michael Johnson",
            emergencyContactPhone: "+1-555-0123",
            notes: "Allergic to penicillin. Regular checkups needed.",
            isActive: true,
            createdAt: Date().addingTimeInterval(-86400 * 30), // 30 days ago
            updatedAt: Date().addingTimeInterval(-86400 * 5)   // 5 days ago
        ),
        Patient(
            id: UUID(),
            firstName: "David",
            lastName: "Chen",
            dateOfBirth: Calendar.current.date(from: DateComponents(year: 1992, month: 8, day: 22))!,
            gender: "Male",
            bloodType: "O-",
            emergencyContactName: "Lisa Chen",
            emergencyContactPhone: "+1-555-0456",
            notes: "Diabetic - Type 1. Requires insulin monitoring.",
            isActive: true,
            createdAt: Date().addingTimeInterval(-86400 * 60), // 60 days ago
            updatedAt: Date().addingTimeInterval(-86400 * 2)   // 2 days ago
        ),
        Patient(
            id: UUID(),
            firstName: "Maria",
            lastName: "Rodriguez",
            dateOfBirth: Calendar.current.date(from: DateComponents(year: 1978, month: 12, day: 3))!,
            gender: "Female",
            bloodType: "B+",
            emergencyContactName: "Carlos Rodriguez",
            emergencyContactPhone: "+1-555-0789",
            notes: "History of hypertension. Takes daily medication.",
            isActive: false,
            createdAt: Date().addingTimeInterval(-86400 * 120), // 120 days ago
            updatedAt: Date().addingTimeInterval(-86400 * 45)   // 45 days ago
        ),
        Patient(
            id: UUID(),
            firstName: "James",
            lastName: "Thompson",
            dateOfBirth: Calendar.current.date(from: DateComponents(year: 1965, month: 6, day: 18))!,
            gender: "Male",
            bloodType: "AB+",
            emergencyContactName: "Patricia Thompson",
            emergencyContactPhone: "+1-555-0321",
            notes: "Recovering from knee surgery. Physical therapy ongoing.",
            isActive: true,
            createdAt: Date().addingTimeInterval(-86400 * 90), // 90 days ago
            updatedAt: Date().addingTimeInterval(-86400 * 1)   // 1 day ago
        ),
        Patient(
            id: UUID(),
            firstName: "Emily",
            lastName: "Davis",
            dateOfBirth: Calendar.current.date(from: DateComponents(year: 2001, month: 9, day: 10))!,
            gender: "Female",
            bloodType: "O+",
            emergencyContactName: "Robert Davis",
            emergencyContactPhone: "+1-555-0654",
            notes: "College student. Annual wellness check.",
            isActive: true,
            createdAt: Date().addingTimeInterval(-86400 * 15), // 15 days ago
            updatedAt: Date().addingTimeInterval(-86400 * 3)   // 3 days ago
        )
    ]
    
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
        updatedAt: Date()
    )
}
