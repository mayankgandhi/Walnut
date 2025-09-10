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


