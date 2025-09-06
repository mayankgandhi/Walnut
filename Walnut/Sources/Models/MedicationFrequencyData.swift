//
//  MedicationFrequencyData.swift
//  Walnut
//
//  Created by Mayank Gandhi on 06/09/25.
//  Copyright © 2025 m. All rights reserved.
//

import Foundation

// MARK: - MedicationFrequency Struct
struct MedicationFrequencyData: Codable, Hashable {
    let type: FrequencyType
    let times: [DateComponents]?
    let interval: Int?
    let startTime: DateComponents?
    let dayOfWeek: Weekday?
    let dayOfMonth: Int?
    let time: DateComponents?
    let mealTime: MealTime?
    let medicationTime: MedicationTime?
    
    enum FrequencyType: String, Codable, CaseIterable {
        case daily, hourly, weekly, biweekly, monthly, mealBased
    }

    // Convert to enum case
    func toEnum() -> MedicationFrequency? {
        switch type {
        case .daily:
            guard let times = times else {
                return nil
            }
            return .daily(times: times)
            
        case .hourly:
            guard let interval = interval else {
                return nil
            }
            return .hourly(interval: interval, startTime: startTime)
            
        case .weekly:
            guard let dayOfWeek = dayOfWeek, let time = time else {
                return nil
            }
            return .weekly(dayOfWeek: dayOfWeek, time: time)
            
        case .biweekly:
            guard let dayOfWeek = dayOfWeek, let time = time else {
                return nil
            }
            return .biweekly(dayOfWeek: dayOfWeek, time: time)
            
        case .monthly:
            guard let dayOfMonth = dayOfMonth, let time = time else {
                return nil
            }
            return .monthly(dayOfMonth: dayOfMonth, time: time)
            
        case .mealBased:
            guard let mealTime = mealTime else {
                return nil
            }
            return .mealBased(mealTime: mealTime, timing: medicationTime)
        }
    }
}

