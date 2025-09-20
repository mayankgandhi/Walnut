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
    /// Human-readable time description
    var timeDescription: String {
        return displayTime
    }
}
