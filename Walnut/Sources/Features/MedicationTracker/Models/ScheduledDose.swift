//
//  ScheduledDose.swift
//  Walnut
//
//  Created by Mayank Gandhi on 10/09/25.
//  Copyright © 2025 m. All rights reserved.
//

import Foundation

// MARK: - Timeline Data Models

/// Represents a scheduled dose with timing and status information
struct ScheduledDose: Identifiable, Hashable {
    let id = UUID()
    let medication: Medication
    let scheduledTime: Date
    let timeSlot: TimeSlot
    let mealRelation: MealRelation?
    
    var displayTime: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: scheduledTime)
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
        return displayTime
    }
}
