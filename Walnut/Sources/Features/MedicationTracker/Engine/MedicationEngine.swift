//
//  MedicationEngine.swift
//  Walnut
//
//  Created by Mayank Gandhi on 20/09/25.
//  Copyright © 2025 m. All rights reserved.
//

import Foundation

/// Engine responsible for converting medications into daily scheduled doses
/// organized by time slots for the MedicationTimelineView
class MedicationEngine {

    // MARK: - Public Interface

    /// Main function: Convert medications into scheduled doses for today
    /// - Parameter medications: Array of medications to schedule
    /// - Returns: Dictionary mapping time slots to scheduled doses
    static func generateDailySchedule(
        from medications: [Medication],
        for date: Date = Date()
    ) -> [TimeSlot: [ScheduledDose]] {

        let engine = MedicationEngine()
        return engine.processMedications(medications, for: date)
    }

    // MARK: - Private Implementation

    private func processMedications(
        _ medications: [Medication],
        for date: Date
    ) -> [TimeSlot: [ScheduledDose]] {

        var schedule: [TimeSlot: [ScheduledDose]] = [:]

        for medication in medications {
            // Check if medication is active for the given date
            guard isMedicationActive(medication, on: date) else { continue }

            // Process each frequency for this medication
            let frequencies = medication.frequency ?? []
            for frequency in frequencies {
                let doses = generateDoses(
                    for: medication,
                    frequency: frequency,
                    on: date
                )

                // Add doses to the appropriate time slots
                for dose in doses {
                    if schedule[dose.timeSlot] == nil {
                        schedule[dose.timeSlot] = []
                    }
                    schedule[dose.timeSlot]?.append(dose)
                }
            }
        }

        // Sort doses within each time slot by scheduled time
        for timeSlot in schedule.keys {
            schedule[timeSlot]?.sort { $0.scheduledTime < $1.scheduledTime }
        }

        return schedule
    }

    // MARK: - Medication Activity Check

    private func isMedicationActive(_ medication: Medication, on date: Date) -> Bool {
        guard let duration = medication.duration else { return true }

        // Get start date from prescription if available, otherwise default to active
        let startDate: Date
        if let prescriptionDate = medication.prescription?.dateIssued {
            startDate = prescriptionDate
        } else if let createdAt = medication.createdAt {
            startDate = createdAt
        } else {
            return true
        }

        let calendar = Calendar.current

        switch duration {
            case .asNeeded, .ongoing:
                return true

            case .days(let days):
                guard let endDate = calendar.date(byAdding: .day, value: days, to: startDate) else { return true }
                return date >= startDate && date <= endDate

            case .weeks(let weeks):
                guard let endDate = calendar.date(byAdding: .weekOfYear, value: weeks, to: startDate) else { return true }
                return date >= startDate && date <= endDate

            case .months(let months):
                guard let endDate = calendar.date(byAdding: .month, value: months, to: startDate) else { return true }
                return date >= startDate && date <= endDate

            case .untilFollowUp(let endDate):
                return date >= startDate && date <= endDate
        }
    }

    // MARK: - Dose Generation

    private func generateDoses(
        for medication: Medication,
        frequency: MedicationFrequency,
        on date: Date
    ) -> [ScheduledDose] {

        switch frequency {
        case .daily(let times):
            return generateDailyDoses(medication: medication, times: times, date: date)

        case .hourly(let interval, let startTime):
            return generateHourlyDoses(medication: medication, interval: interval, startTime: startTime, date: date)

        case .weekly(let dayOfWeek, let time):
            return generateWeeklyDoses(medication: medication, dayOfWeek: dayOfWeek, time: time, date: date)

        case .biweekly(let dayOfWeek, let time):
            return generateBiweeklyDoses(medication: medication, dayOfWeek: dayOfWeek, time: time, date: date)

        case .monthly(let dayOfMonth, let time):
            return generateMonthlyDoses(medication: medication, dayOfMonth: dayOfMonth, time: time, date: date)

        case .mealBased(let mealTime, let timing):
            return generateMealBasedDoses(medication: medication, mealTime: mealTime, timing: timing, date: date)
        }
    }

    // MARK: - Daily Doses

    private func generateDailyDoses(
        medication: Medication,
        times: [DateComponents],
        date: Date
    ) -> [ScheduledDose] {

        let calendar = Calendar.current
        var doses: [ScheduledDose] = []

        for timeComponent in times {
            guard let hour = timeComponent.hour,
                  let minute = timeComponent.minute else { continue }

            guard let scheduledTime = calendar.date(
                bySettingHour: hour,
                minute: minute,
                second: 0,
                of: date
            ) else { continue }

            let timeSlot = determineTimeSlot(for: scheduledTime)

            let dose = ScheduledDose(
                medication: medication,
                scheduledTime: scheduledTime,
                timeSlot: timeSlot,
                mealRelation: nil
            )

            doses.append(dose)
        }

        return doses
    }

    // MARK: - Hourly Doses

    private func generateHourlyDoses(
        medication: Medication,
        interval: Int,
        startTime: DateComponents?,
        date: Date
    ) -> [ScheduledDose] {

        let calendar = Calendar.current
        var doses: [ScheduledDose] = []

        // Determine start time for the day
        let dayStartTime: Date
        if let startTime = startTime,
           let hour = startTime.hour,
           let minute = startTime.minute {
            dayStartTime = calendar.date(bySettingHour: hour, minute: minute, second: 0, of: date) ?? date
        } else {
            dayStartTime = calendar.startOfDay(for: date)
        }

        // Generate doses throughout the day
        var currentTime = dayStartTime
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: calendar.startOfDay(for: date)) ?? date

        while currentTime < endOfDay {
            let timeSlot = determineTimeSlot(for: currentTime)

            let dose = ScheduledDose(
                medication: medication,
                scheduledTime: currentTime,
                timeSlot: timeSlot,
                mealRelation: nil
            )

            doses.append(dose)

            // Add interval
            currentTime = calendar.date(byAdding: .hour, value: interval, to: currentTime) ?? endOfDay
        }

        return doses
    }

    // MARK: - Weekly Doses

    private func generateWeeklyDoses(
        medication: Medication,
        dayOfWeek: Weekday,
        time: DateComponents,
        date: Date
    ) -> [ScheduledDose] {

        let calendar = Calendar.current
        let currentWeekday = calendar.component(.weekday, from: date)

        // Check if today matches the required day of week
        if currentWeekday == dayOfWeek.rawValue {
            guard let hour = time.hour,
                  let minute = time.minute,
                  let scheduledTime = calendar.date(
                    bySettingHour: hour,
                    minute: minute,
                    second: 0,
                    of: date
                  ) else { return [] }

            let timeSlot = determineTimeSlot(for: scheduledTime)

            return [ScheduledDose(
                medication: medication,
                scheduledTime: scheduledTime,
                timeSlot: timeSlot,
                mealRelation: nil
            )]
        }

        return []
    }

    // MARK: - Biweekly Doses

    private func generateBiweeklyDoses(
        medication: Medication,
        dayOfWeek: Weekday,
        time: DateComponents,
        date: Date
    ) -> [ScheduledDose] {

        // For biweekly, we'd need to track when the medication started
        // For now, treat it like weekly (simplified)
        // This would need enhancement with medication start date tracking
        return generateWeeklyDoses(medication: medication, dayOfWeek: dayOfWeek, time: time, date: date)
    }

    // MARK: - Monthly Doses

    private func generateMonthlyDoses(
        medication: Medication,
        dayOfMonth: Int,
        time: DateComponents,
        date: Date
    ) -> [ScheduledDose] {

        let calendar = Calendar.current
        let currentDayOfMonth = calendar.component(.day, from: date)

        // Check if today matches the required day of month
        if currentDayOfMonth == dayOfMonth {
            guard let hour = time.hour,
                  let minute = time.minute,
                  let scheduledTime = calendar.date(
                    bySettingHour: hour,
                    minute: minute,
                    second: 0,
                    of: date
                  ) else { return [] }

            let timeSlot = determineTimeSlot(for: scheduledTime)

            return [ScheduledDose(
                medication: medication,
                scheduledTime: scheduledTime,
                timeSlot: timeSlot,
                mealRelation: nil
            )]
        }

        return []
    }

    // MARK: - Meal-Based Doses

    private func generateMealBasedDoses(
        medication: Medication,
        mealTime: MealTime,
        timing: MedicationTime?,
        date: Date
    ) -> [ScheduledDose] {

        // Calculate offset minutes based on timing
        let offsetMinutes: Int
        switch timing {
        case .before:
            offsetMinutes = -15 // 15 minutes before meal
        case .after:
            offsetMinutes = 30  // 30 minutes after meal
        case .none:
            offsetMinutes = 0   // With meal
        }

        let mealRelation = MealRelation(
            mealTime: mealTime,
            timing: timing,
            offsetMinutes: offsetMinutes
        )

        let scheduledTime = mealRelation.calculateActualTime(for: date)
        let timeSlot = determineTimeSlot(for: scheduledTime)

        return [ScheduledDose(
            medication: medication,
            scheduledTime: scheduledTime,
            timeSlot: timeSlot,
            mealRelation: mealRelation
        )]
    }

    // MARK: - Time Slot Determination

    private func determineTimeSlot(for date: Date) -> TimeSlot {
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: date)

        switch hour {
        case 6..<11:   return .morning
        case 11..<14:  return .midday
        case 14..<17:  return .afternoon
        case 17..<21:  return .evening
        default:       return .night
        }
    }
}

// MARK: - Engine Extensions

extension MedicationEngine {

    /// Generate schedule for multiple days (future enhancement)
    static func generateMultiDaySchedule(
        from medications: [Medication],
        startDate: Date,
        numberOfDays: Int
    ) -> [Date: [TimeSlot: [ScheduledDose]]] {

        var multiDaySchedule: [Date: [TimeSlot: [ScheduledDose]]] = [:]
        let calendar = Calendar.current

        for dayOffset in 0..<numberOfDays {
            guard let targetDate = calendar.date(byAdding: .day, value: dayOffset, to: startDate) else { continue }

            let dailySchedule = generateDailySchedule(from: medications, for: targetDate)
            multiDaySchedule[targetDate] = dailySchedule
        }

        return multiDaySchedule
    }

    /// Get next upcoming dose across all medications
    static func getNextUpcomingDose(
        from medications: [Medication],
        after currentTime: Date = Date()
    ) -> ScheduledDose? {

        let todaySchedule = generateDailySchedule(from: medications, for: currentTime)
        let allDoses = todaySchedule.values.flatMap { $0 }

        return allDoses
            .filter { $0.scheduledTime > currentTime }
            .min { $0.scheduledTime < $1.scheduledTime }
    }
}
