//
//  MealTimeConfiguration.swift
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

