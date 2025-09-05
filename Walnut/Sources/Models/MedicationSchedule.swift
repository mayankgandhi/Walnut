//
//  MedicationSchedule.swift
//  Walnut
//
//  Created by Mayank Gandhi on 06/09/25.
//  Copyright © 2025 m. All rights reserved.
//

import Foundation
import SwiftUI

// MARK: - Medication Frequency System

enum MedicationFrequency: Codable, Hashable {
    // Time-based frequencies
    case daily(times: [DateComponents]) // e.g., daily at 8:00 AM and 6:00 PM
    case hourly(interval: Int, startTime: DateComponents? = nil) // e.g., every 4 hours
    case weekly(dayOfWeek: Weekday, time: DateComponents) // e.g., every Monday at 9 AM
    case biweekly(dayOfWeek: Weekday, time: DateComponents) // e.g., every other Monday at 9 AM
    case monthly(dayOfMonth: Int, time: DateComponents) // e.g., 1st of every month at 10 AM
    case mealBased(mealTime: MealTime, timing: MedicationTime?)
    
    var icon: String {
        switch self {
        case .daily:
            return "clock.fill"
        case .hourly:
            return "timer"
        case .weekly, .biweekly:
            return "calendar.badge.clock"
        case .monthly:
            return "calendar.circle.fill"
        case .mealBased(let mealTime, _):
            return mealTime.icon
        }
    }
    
    var displayText: String {
        switch self {
        case .daily(let times):
            if times.count == 1 {
                return "Once daily"
            } else {
                return "\(times.count) times daily"
            }
        case .hourly(let interval, _):
            return "Every \(interval) hour\(interval == 1 ? "" : "s")"
        case .weekly:
            return "Weekly"
        case .biweekly:
            return "Every 2 weeks"
        case .monthly:
            return "Monthly"
        case .mealBased(let mealTime, let timing):
            let mealName = mealTime.displayName
            if let timing = timing {
                return "\(timing.displayName) \(mealName)"
            } else {
                return "With \(mealName)"
            }
        }
    }
    
    var color: Color {
        switch self {
        case .daily:
            return .blue
        case .hourly:
            return .green
        case .weekly, .biweekly:
            return .orange
        case .monthly:
            return .purple
        case .mealBased(let mealTime, _):
            return mealTime.color
        }
    }
}
