//
//  MedicationScheduleService 2.swift
//  Walnut
//
//  Created by Mayank Gandhi on 10/09/25.
//  Copyright © 2025 m. All rights reserved.
//

import Foundation
import Combine

// MARK: - Medication Schedule Service

/// Observable service managing medication scheduling and timeline organization
@Observable
class MedicationScheduleService {
    
    // MARK: - Properties
    
    /// Current scheduled doses organized by time slot
    private(set) var timelineDoses: [TimeSlot: [ScheduledDose]] = [:]
    
    /// All scheduled doses for the current day
    private(set) var todaysDoses: [ScheduledDose] = []
    
    /// Current date for scheduling calculations
    var currentDate = Date() {
        didSet {
            _ = generateSchedule(for: currentDate)
        }
    }
    
    /// Current medications to schedule
    private var medications: [Medication] = []

    // MARK: - Public Methods
    
    /// Update medications and regenerate schedule
    func updateMedications(_ medications: [Medication]) {
        self.medications = medications
        let result = generateSchedule(for: currentDate)
        return result
    }
    
    private func getTimeSlot(for date: Date) -> TimeSlot {
        let hour = Calendar.current.component(.hour, from: date)
        
        for timeSlot in TimeSlot.allCases {
            let range = timeSlot.timeRange
            
            // Handle night time slot that spans midnight
            if timeSlot == .night {
                if hour >= range.start || hour < range.end {
                    return timeSlot
                }
            } else {
                if hour >= range.start && hour < range.end {
                    return timeSlot
                }
            }
        }
        
        return .morning // Default fallback
    }
    
    /// Generate schedule from real medication data
    private func generateSchedule(for date: Date) {
        // Reset current schedule
        timelineDoses = [:]
        todaysDoses = []
        
        let calendar = Calendar.current
        var allDoses: [ScheduledDose] = []
        
        // Process each medication's frequency patterns
        for medication in medications {
            guard let frequencies = medication.frequency else {
                return
            }
            
            for frequency in frequencies {
                let doses = generateDosesForFrequency(frequency, medication: medication, date: date, calendar: calendar)
                allDoses.append(contentsOf: doses)
                
            }
        }
        
        // Group and sort doses
        groupAndSortDoses(allDoses)
    }
    
    /// Generate scheduled doses for a specific medication frequency
    private func generateDosesForFrequency(
        _ frequency: MedicationFrequency,
        medication: Medication,
        date: Date,
        calendar: Calendar
    ) -> [ScheduledDose] {
        var doses: [ScheduledDose] = []
        
        switch frequency {
            case .daily(let times):
                for timeComponent in times {
                    if let scheduledTime = calendar.date(bySettingHour: timeComponent.hour ?? 0, minute: timeComponent.minute ?? 0, second: 0, of: date) {
                        let timeSlot = getTimeSlot(for: scheduledTime)
                        let dose = ScheduledDose(
                            medication: medication,
                            scheduledTime: scheduledTime,
                            timeSlot: timeSlot,
                            mealRelation: nil,
                        )
                        doses.append(dose)
                    }
                }
                
            case .mealBased(let mealTime, let timing):
                let mealScheduledTime = MealTimeConfiguration.shared.scheduledTime(for: mealTime, date: date)
                let adjustedTime = adjustTimeForMealTiming(mealScheduledTime, timing: timing, calendar: calendar)
                let timeSlot = getTimeSlot(for: adjustedTime)
                
                let mealRelation = MealRelation(
                    mealTime: mealTime,
                    timing: timing,
                    offsetMinutes: timing == .before ? -15 : (timing == .after ? 30 : 0)
                )
                
                let dose = ScheduledDose(
                    medication: medication,
                    scheduledTime: adjustedTime,
                    timeSlot: timeSlot,
                    mealRelation: mealRelation,
                )
                doses.append(dose)
                
            case .hourly(let interval, let startTime):
                // For hourly medications, create multiple doses throughout the day
                let startHour = startTime?.hour ?? 8
                let startMinute = startTime?.minute ?? 0
                
                var currentTime = calendar.date(bySettingHour: startHour, minute: startMinute, second: 0, of: date) ?? date
                let endOfDay = calendar.date(bySettingHour: 22, minute: 0, second: 0, of: date) ?? date
                
                while currentTime <= endOfDay {
                    let timeSlot = getTimeSlot(for: currentTime)
                    let dose = ScheduledDose(
                        medication: medication,
                        scheduledTime: currentTime,
                        timeSlot: timeSlot,
                        mealRelation: nil,
                    )
                    doses.append(dose)
                    
                    currentTime = calendar.date(byAdding: .hour, value: interval, to: currentTime) ?? currentTime
                }
                
            case .weekly(let dayOfWeek, let time), .biweekly(let dayOfWeek, let time):
                // Check if the current date matches the scheduled day of week
                let currentWeekday = calendar.component(.weekday, from: date)
                if currentWeekday == dayOfWeek.rawValue {
                    if let scheduledTime = calendar.date(bySettingHour: time.hour ?? 0, minute: time.minute ?? 0, second: 0, of: date) {
                        let timeSlot = getTimeSlot(for: scheduledTime)
                        let dose = ScheduledDose(
                            medication: medication,
                            scheduledTime: scheduledTime,
                            timeSlot: timeSlot,
                            mealRelation: nil,
                        )
                        doses.append(dose)
                    }
                }
                
            case .monthly(let dayOfMonth, let time):
                // Check if the current date matches the scheduled day of month
                let currentDay = calendar.component(.day, from: date)
                if currentDay == dayOfMonth {
                    if let scheduledTime = calendar.date(bySettingHour: time.hour ?? 0, minute: time.minute ?? 0, second: 0, of: date) {
                        let timeSlot = getTimeSlot(for: scheduledTime)
                        let dose = ScheduledDose(
                            medication: medication,
                            scheduledTime: scheduledTime,
                            timeSlot: timeSlot,
                            mealRelation: nil,
                        )
                        doses.append(dose)
                    }
                }
        }
        
        return doses
    }
    
    /// Adjust time based on meal timing (before/after)
    private func adjustTimeForMealTiming(
        _ mealTime: Date,
        timing: MedicationTime?,
        calendar: Calendar
    ) -> Date {
        guard let timing = timing else { return mealTime }
        
        switch timing {
            case .before:
                return calendar.date(byAdding: .minute, value: -15, to: mealTime) ?? mealTime
            case .after:
                return calendar.date(byAdding: .minute, value: 30, to: mealTime) ?? mealTime
        }
    }
    
    /// Group doses by time slot and sort them
    private func groupAndSortDoses(_ allDoses: [ScheduledDose]) {
        var groupedDoses: [TimeSlot: [ScheduledDose]] = [:]
        
        for dose in allDoses {
            if groupedDoses[dose.timeSlot] == nil {
                groupedDoses[dose.timeSlot] = []
            }
            groupedDoses[dose.timeSlot]?.append(dose)
        }
        
        // Sort doses within each time slot
        for timeSlot in TimeSlot.allCases {
            groupedDoses[timeSlot]?.sort { $0.scheduledTime < $1.scheduledTime }
        }
        
        self.timelineDoses = groupedDoses
        self.todaysDoses = allDoses.sorted { $0.scheduledTime < $1.scheduledTime }
    }
    
}
