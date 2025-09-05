//
//  MedicationTracker.swift
//  Walnut
//
//  Created by Mayank Gandhi on 01/08/25.
//  Copyright © 2025 m. All rights reserved.
//

import SwiftUI
import Foundation

@Observable
class MedicationTracker {
    
    // MARK: - Medication Schedule Info
    struct MedicationScheduleInfo: Identifiable {
        var id: String {
            "\(medication.name ?? "").\(schedule.displayText).\(medication.dosage ?? "")"
        }
        
        let medication: Medication
        let schedule: MedicationFrequency
        let timePeriod: MealTime // Used for backward compatibility grouping
        let timeUntilDue: TimeInterval?
    }
    
    // MARK: - Current Time
    private var currentDate = Date()
    
    // MARK: - Public Methods
    func formatTimeUntilDue(_ timeInterval: TimeInterval) -> String {
        let hours = Int(timeInterval / 3600)
        let minutes = Int((timeInterval.truncatingRemainder(dividingBy: 3600)) / 60)
        
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }
    
    private func getHourForMealTime(_ timePeriod: MealTime) -> Int {
        switch timePeriod {
            case .breakfast: return 8   // 8 AM
            case .lunch: return 13 // 1 PM
            case .dinner: return 19   // 7 PM
            case .bedtime: return 22     // 10 PM
        }
    }
    
   
    private func calculateNextDailyDose(times: [DateComponents], calendar: Calendar) -> TimeInterval? {
        guard let nextTime = times.compactMap({ timeComponent in
            calendar.nextDate(after: currentDate, matching: timeComponent, matchingPolicy: .nextTime)
        }).min() else { return nil }
        
        return nextTime.timeIntervalSince(currentDate)
    }
    
    private func calculateNextHourlyDose(interval: Int, startTime: DateComponents?, calendar: Calendar) -> TimeInterval? {
        let currentHour = calendar.component(.hour, from: currentDate)
        let startHour = startTime?.hour ?? 0
        
        let hoursFromStart = currentHour - startHour
        let nextDoseHour = startHour + ((hoursFromStart / interval) + 1) * interval
        
        if let nextDose = calendar.date(bySettingHour: nextDoseHour % 24, minute: startTime?.minute ?? 0, second: 0, of: currentDate) {
            return nextDose > currentDate ? nextDose.timeIntervalSince(currentDate) : nil
        }
        
        return nil
    }
    
    private func calculateNextWeeklyDose(time: DateComponents, calendar: Calendar) -> TimeInterval? {
        guard let nextTime = calendar.nextDate(after: currentDate, matching: time, matchingPolicy: .nextTime) else {
            return nil
        }
        return nextTime.timeIntervalSince(currentDate)
    }
    
    private func calculateNextMonthlyDose(time: DateComponents, calendar: Calendar) -> TimeInterval? {
        guard let nextTime = calendar.nextDate(after: currentDate, matching: time, matchingPolicy: .nextTime) else {
            return nil
        }
        return nextTime.timeIntervalSince(currentDate)
    }
    
    private func calculateMealBasedDose(mealTime: MealTime, timing: MedicationTime?, calendar: Calendar) -> TimeInterval? {
        let scheduleHour = getHourForMealTime(mealTime)
        
        var targetDate = calendar.date(bySettingHour: scheduleHour, minute: 0, second: 0, of: currentDate)!
        
        // Adjust based on timing (before/after meal)
        if let timing = timing {
            switch timing {
            case .before:
                targetDate = calendar.date(byAdding: .minute, value: -15, to: targetDate)!
            case .after:
                targetDate = calendar.date(byAdding: .minute, value: 30, to: targetDate)!
            }
        }
        
        // If the target time has passed today, set it for tomorrow
        if targetDate <= currentDate {
            targetDate = calendar.date(byAdding: .day, value: 1, to: targetDate)!
        }
        
        return targetDate.timeIntervalSince(currentDate)
    }
    
    /// Get display name for frequency type grouping
    private func getFrequencyTypeDisplayName(_ frequency: MedicationFrequency) -> String {
        switch frequency {
        case .daily:
            return "Daily Medications"
        case .hourly:
            return "Hourly Medications"
        case .weekly:
            return "Weekly Medications"
        case .biweekly:
            return "Bi-weekly Medications"
        case .monthly:
            return "Long-term Medications"
        case .mealBased:
            return "Meal-based Medications"
        }
    }
    
    // Legacy method for backward compatibility
    private func calculateTimeUntilDue(currentHour: Int, scheduleHour: Int) -> TimeInterval {
        let calendar = Calendar.current
        let currentMinute = calendar.component(.minute, from: currentDate)
        
        var targetDate = calendar.date(bySettingHour: scheduleHour, minute: 0, second: 0, of: currentDate)!
        
        // If the target time has passed today, set it for tomorrow
        if targetDate <= currentDate {
            targetDate = calendar.date(byAdding: .day, value: 1, to: targetDate)!
        }
        
        let currentDateWithSeconds = calendar.date(bySettingHour: currentHour, minute: currentMinute, second: 0, of: currentDate)!
        
        return targetDate.timeIntervalSince(currentDateWithSeconds)
    }
}
