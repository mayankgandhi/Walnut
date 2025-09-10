//
//  MedicationScheduleModels.swift
//  Walnut
//
//  Created by Mayank Gandhi on 10/09/25.
//  Copyright © 2025 m. All rights reserved.
//

import SwiftUI
import Foundation

/// Configuration for meal times - centralized and configurable
struct MealTimeConfiguration {
    static let shared = MealTimeConfiguration()
    
    private let mealTimes: [MealTime: DateComponents] = [
        .breakfast: DateComponents(hour: 8, minute: 0),   // 8:00 AM
        .lunch: DateComponents(hour: 13, minute: 0),      // 1:00 PM  
        .dinner: DateComponents(hour: 19, minute: 0),     // 7:00 PM
        .bedtime: DateComponents(hour: 22, minute: 0)     // 10:00 PM
    ]
    
    func dateComponents(for mealTime: MealTime) -> DateComponents {
        return mealTimes[mealTime] ?? DateComponents(hour: 8, minute: 0)
    }
    
    func scheduledTime(for mealTime: MealTime, date: Date = Date()) -> Date {
        let calendar = Calendar.current
        let components = dateComponents(for: mealTime)
        return calendar.date(bySettingHour: components.hour!, minute: components.minute!, second: 0, of: date) ?? date
    }
}

/// Enhanced dose status with additional metadata
extension DoseStatus {
    /// Whether this status represents a completed action
    var isCompleted: Bool {
        switch self {
        case .taken, .skipped:
            return true
        case .scheduled, .missed:
            return false
        }
    }
    
    /// Whether this status requires user attention
    var requiresAttention: Bool {
        switch self {
        case .missed:
            return true
        case .taken, .scheduled, .skipped:
            return false
        }
    }
}

/// Enhanced scheduled dose with computed properties
extension ScheduledDose {
    /// Time until this dose is due (negative if overdue)
    var timeUntilDue: TimeInterval {
        scheduledTime.timeIntervalSinceNow
    }
    
    /// Whether this dose is due soon (within 30 minutes)
    var isDueSoon: Bool {
        let timeUntil = timeUntilDue
        return timeUntil > 0 && timeUntil <= 30 * 60 // 30 minutes in seconds
    }
    
    /// Human-readable time description
    var timeDescription: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        
        if status == .taken, let takenTime = actualTakenTime {
            return "Taken \(formatter.localizedString(for: takenTime, relativeTo: Date()))"
        } else if isOverdue {
            return "Overdue by \(formatter.localizedString(for: scheduledTime, relativeTo: Date()))"
        } else if isDueSoon {
            return "Due in \(formatter.localizedString(for: scheduledTime, relativeTo: Date()))"
        } else {
            return displayTime
        }
    }
}

/// Enhanced meal relation with utility methods
extension MealRelation {
    /// Calculate the actual time based on meal time and offset
    func calculateActualTime(for date: Date) -> Date {
        let mealTime = MealTimeConfiguration.shared.scheduledTime(for: self.mealTime, date: date)
        let calendar = Calendar.current
        return calendar.date(byAdding: .minute, value: offsetMinutes, to: mealTime) ?? mealTime
    }
    
    /// Short display text for compact UI
    var shortDisplayText: String {
        let prefix = offsetMinutes < 0 ? "Before" : (offsetMinutes > 0 ? "After" : "With")
        return "\(prefix) \(mealTime.displayName)"
    }
}
