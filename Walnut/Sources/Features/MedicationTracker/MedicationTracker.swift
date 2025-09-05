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
    struct MedicationScheduleInfo {
        let medication: Medication
        let schedule: MedicationSchedule
        let timePeriod: MealTime
        let isUpcoming: Bool
        let timeUntilDue: TimeInterval?
        
        var displayTime: String {
            let mealTime = schedule.mealTime.rawValue.capitalized
            if let timing = schedule.timing {
                return "\(timing.rawValue.capitalized) \(mealTime)"
            }
            return mealTime
        }
        
        var dosageText: String {
            if let scheduleDosage = schedule.dosage, !scheduleDosage.isEmpty {
                return scheduleDosage
            }
            return medication.dosage ?? "As prescribed"
        }
    }
    
    // MARK: - Current Time
    private var currentDate = Date()
    
    // MARK: - Public Methods
    func groupMedicationsByMealTime(_ medications: [Medication]) -> [MealTime: [MedicationScheduleInfo]] {
        var grouped: [MealTime: [MedicationScheduleInfo]] = [:]
        
        for medication in medications {
            for schedule in medication.frequency ?? [] {
                let timePeriod = schedule.mealTime
                let info = MedicationScheduleInfo(
                    medication: medication,
                    schedule: schedule,
                    timePeriod: timePeriod,
                    isUpcoming: false,
                    timeUntilDue: nil
                )
                
                if grouped[timePeriod] == nil {
                    grouped[timePeriod] = []
                }
                grouped[timePeriod]?.append(info)
            }
        }
        
        return grouped
    }
    
    func getUpcomingMedications(_ medications: [Medication], withinHours hours: Int = 4) -> [MedicationScheduleInfo] {
        let calendar = Calendar.current
        let currentHour = calendar.component(.hour, from: currentDate)
        let targetHour = (currentHour + hours) % 24
        
        var upcomingMedications: [MedicationScheduleInfo] = []
        
        for medication in medications {
            for schedule in medication.frequency ?? [] {
                let timePeriod = schedule.mealTime
                let scheduleHour = getHourForMealTime(timePeriod)
                
                // Check if medication is due within the next few hours
                let isUpcoming = isTimeWithinRange(currentHour: currentHour, 
                                                 targetHour: targetHour, 
                                                 scheduleHour: scheduleHour)
                
                if isUpcoming {
                    let timeUntilDue = calculateTimeUntilDue(currentHour: currentHour, 
                                                           scheduleHour: scheduleHour)
                    
                    let info = MedicationScheduleInfo(
                        medication: medication,
                        schedule: schedule,
                        timePeriod: timePeriod,
                        isUpcoming: true,
                        timeUntilDue: timeUntilDue
                    )
                    upcomingMedications.append(info)
                }
            }
        }
        
        // Sort by time until due
        return upcomingMedications.sorted { med1, med2 in
            guard let time1 = med1.timeUntilDue, let time2 = med2.timeUntilDue else {
                return false
            }
            return time1 < time2
        }
    }
    
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
    
    private func isTimeWithinRange(currentHour: Int, targetHour: Int, scheduleHour: Int) -> Bool {
        if targetHour > currentHour {
            // Same day range
            return scheduleHour >= currentHour && scheduleHour <= targetHour
        } else {
            // Cross midnight range
            return scheduleHour >= currentHour || scheduleHour <= targetHour
        }
    }
    
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
