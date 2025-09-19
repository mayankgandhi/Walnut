//
//  MealRelation.swift
//  Walnut
//
//  Created by Mayank Gandhi on 10/09/25.
//  Copyright © 2025 m. All rights reserved.
//

import Foundation

/// Tracks relationship to meals for medication timing
struct MealRelation: Equatable, Hashable {
    let mealTime: MealTime
    let timing: MedicationTime?
    let offsetMinutes: Int // Minutes before(-) or after(+) meal
    
    var displayText: String {
        if let timing = timing {
            return "\(timing.displayName) \(mealTime.displayName)"
        } else {
            return "With \(mealTime.displayName)"
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
