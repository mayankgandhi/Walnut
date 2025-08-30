//
//  Medication.swift
//  Walnut
//
//  Created by Mayank Gandhi on 11/07/25.
//  Copyright © 2025 m. All rights reserved.
//

import SwiftData
import Foundation

@Model
class Medication {
    
    var id: UUID?
    var name: String?
    var frequency: [MedicationSchedule]?
    var numberOfDays: Int?
    var dosage: String?
    var instructions: String?
    
    var createdAt: Date?
    var updatedAt: Date?
    
    var prescription: Prescription?
    
    init(id: UUID, name: String, frequency: [MedicationSchedule], numberOfDays: Int, dosage: String? = nil, instructions: String? = nil, createdAt: Date = Date(), updatedAt: Date = Date(), prescription: Prescription? = nil) {
        self.id = id
        self.name = name
        self.frequency = frequency
        self.numberOfDays = numberOfDays
        self.dosage = dosage
        self.instructions = instructions
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.prescription = prescription
    }
}

struct MedicationSchedule: Codable {
    
    enum MealTime: String, Codable, CaseIterable {
        case breakfast, lunch, dinner, bedtime
    }
    
    enum MedicationTime: String, Codable, CaseIterable {
        case before, after
    }
    
    let mealTime: MealTime
    let timing: MedicationTime? // before/after
    let dosage: String?
}
