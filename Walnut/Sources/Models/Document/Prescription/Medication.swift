//
//  Medication.swift
//  Walnut
//
//  Created by Mayank Gandhi on 11/07/25.
//  Copyright © 2025 m. All rights reserved.
//

import SwiftData
import Foundation
import SwiftUI

@Model
class Medication {
    
    var id: UUID?
    var name: String?
    var frequency: [MedicationSchedule]?
    var duration: MedicationDuration? // Replaces numberOfDays with more flexibility
    var dosage: String?
    var instructions: String?
    
    var createdAt: Date?
    var updatedAt: Date?
    
    var prescription: Prescription?
    
    init(
        id: UUID,
        name: String,
        frequency: [MedicationSchedule],
        duration: MedicationDuration? = nil,
        dosage: String? = nil,
        instructions: String? = nil,
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        prescription: Prescription? = nil
    ) {
        self.id = id
        self.name = name
        self.frequency = frequency
        self.dosage = dosage
        self.instructions = instructions
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.prescription = prescription
    }
    
}

enum Weekday: Int, Codable, CaseIterable {
    case sunday = 1, monday, tuesday, wednesday, thursday, friday, saturday
    
    var displayName: String {
        switch self {
        case .sunday: return "Sunday"
        case .monday: return "Monday"
        case .tuesday: return "Tuesday"
        case .wednesday: return "Wednesday"
        case .thursday: return "Thursday"
        case .friday: return "Friday"
        case .saturday: return "Saturday"
        }
    }
}

enum Month: Int, Codable, CaseIterable {
    case january = 1, february, march, april, may, june
    case july, august, september, october, november, december
    
    var displayName: String {
        switch self {
        case .january: return "January"
        case .february: return "February"
        case .march: return "March"
        case .april: return "April"
        case .may: return "May"
        case .june: return "June"
        case .july: return "July"
        case .august: return "August"
        case .september: return "September"
        case .october: return "October"
        case .november: return "November"
        case .december: return "December"
        }
    }
}

enum MealTime: String, Codable, CaseIterable {
    case breakfast, lunch, dinner, bedtime
    
    var icon: String {
        switch self {
            case .breakfast:
                "sunrise"
            case .lunch:
                "sun.max"
            case .dinner:
                "sunset"
            case .bedtime:
                "moon"
        }
    }
    
    var iconString: String {
        switch self {
            case .breakfast:
                "sunrise"
            case .lunch:
                "sun.max"
            case .dinner:
                "sunset"
            case .bedtime:
                "night"
        }
    }
    
    var color: Color {
        switch self {
            case .breakfast:
                    .orange
            case .lunch:
                    .yellow
            case .dinner:
                    .purple
            case .bedtime:
                    .indigo
        }
    }
    
    var displayName: String {
        switch self {
            case .breakfast:
                "Breakfast"
            case .lunch:
                "Lunch"
            case .dinner:
                "Dinner"
            case .bedtime:
                "Bedtime"
        }
    }
    
}

enum MedicationTime: String, Codable, CaseIterable {
    case before, after
    
    var icon: String {
        switch self {
            case .before:
                ""
            case .after:
                ".fill"
        }
    }
    
    var displayName: String {
        switch self {
        case .before:
            return "Before"
        case .after:
            return "After"
        }
    }
}
