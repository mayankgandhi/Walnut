//
//  MedicationScheduleService.swift
//  Walnut
//
//  Created by Mayank Gandhi on 10/09/25.
//  Copyright © 2025 m. All rights reserved.
//

import SwiftUI
import Foundation
import Combine

// MARK: - Timeline Data Models

/// Represents a scheduled dose with timing and status information
struct ScheduledDose: Identifiable, Hashable {
    let id = UUID()
    let medication: Medication
    let scheduledTime: Date
    let timeSlot: TimeSlot
    let mealRelation: MealRelation?
    var status: DoseStatus
    var actualTakenTime: Date?
    
    var isOverdue: Bool {
        status == .scheduled && scheduledTime < Date()
    }
    
    var displayTime: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: scheduledTime)
    }
}

/// Time slots for organizing medications throughout the day
enum TimeSlot: String, CaseIterable, Identifiable {
    case morning = "morning"
    case midday = "midday" 
    case afternoon = "afternoon"
    case evening = "evening"
    case night = "night"
    
    var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .morning: return "Morning"
        case .midday: return "Midday"
        case .afternoon: return "Afternoon"
        case .evening: return "Evening"
        case .night: return "Night"
        }
    }
    
    var icon: String {
        switch self {
        case .morning: return "sunrise.fill"
        case .midday: return "sun.max.fill"
        case .afternoon: return "sun.haze.fill"
        case .evening: return "sunset.fill"
        case .night: return "moon.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .morning: return .orange
        case .midday: return .yellow
        case .afternoon: return .blue
        case .evening: return .purple
        case .night: return .indigo
        }
    }
    
    var timeRange: (start: Int, end: Int) {
        switch self {
        case .morning: return (6, 11)   // 6 AM - 11 AM
        case .midday: return (11, 14)   // 11 AM - 2 PM
        case .afternoon: return (14, 17) // 2 PM - 5 PM
        case .evening: return (17, 21)   // 5 PM - 9 PM
        case .night: return (21, 6)      // 9 PM - 6 AM (next day)
        }
    }
}

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

/// Status of a scheduled medication dose
enum DoseStatus: String, CaseIterable {
    case scheduled = "scheduled"
    case taken = "taken"
    case missed = "missed"
    case skipped = "skipped"
    
    var displayName: String {
        switch self {
        case .scheduled: return "Scheduled"
        case .taken: return "Taken"
        case .missed: return "Missed"
        case .skipped: return "Skipped"
        }
    }
    
    var color: Color {
        switch self {
        case .scheduled: return .blue
        case .taken: return .green
        case .missed: return .red
        case .skipped: return .orange
        }
    }
    
    var icon: String {
        switch self {
        case .scheduled: return "clock.fill"
        case .taken: return "checkmark.circle.fill"
        case .missed: return "exclamationmark.triangle.fill"
        case .skipped: return "minus.circle.fill"
        }
    }
}


// MARK: - Medication Schedule Service

/// Observable service managing medication scheduling and timeline organization
@Observable
class MedicationScheduleService: MedicationScheduleServiceProtocol {
    
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
    
    /// Publisher for schedule updates
    private let scheduleUpdateSubject = PassthroughSubject<Void, Never>()
    var scheduleUpdatePublisher: AnyPublisher<Void, Never> {
        scheduleUpdateSubject.eraseToAnyPublisher()
    }
    
    // MARK: - Public Methods
    
    /// Update medications and regenerate schedule
    func updateMedications(_ medications: [Medication]) -> MedicationScheduleResult<Void> {
        // Validate medications first
        for medication in medications {
            if case .failure(let error) = validateMedication(medication) {
                return .failure(error)
            }
        }
        
        self.medications = medications
        let result = generateSchedule(for: currentDate)
        
        if case .success = result {
            scheduleUpdateSubject.send()
        }
        
        return result
    }
    
    /// Generate medication schedule for a specific date
    func generateSchedule(for date: Date) -> MedicationScheduleResult<Void> {
        do {
            if medications.isEmpty {
                // Use placeholder data for demonstration when no real medications exist
                generatePlaceholderSchedule(for: date)
            } else {
                // Generate real schedule from medication frequencies
                try generateRealSchedule(for: date)
            }
            return .success(())
        } catch {
            if let scheduleError = error as? MedicationScheduleError {
                return .failure(scheduleError)
            } else {
                return .failure(.schedulingFailed)
            }
        }
    }
    
    /// Update dose status with error handling
    func updateDoseStatus(_ dose: ScheduledDose, to status: DoseStatus, takenTime: Date?) -> MedicationScheduleResult<ScheduledDose> {
        guard let updatedDose = performDoseStatusUpdate(dose, to: status, takenTime: takenTime) else {
            return .failure(.doseUpdateFailed)
        }
        
        scheduleUpdateSubject.send()
        return .success(updatedDose)
    }
    
    /// Get doses for a specific time slot
    func doses(for timeSlot: TimeSlot) -> [ScheduledDose] {
        return timelineDoses[timeSlot] ?? []
    }
    
    /// Get overdue doses
    func getOverdueDoses() -> [ScheduledDose] {
        return todaysDoses.filter { $0.isOverdue }
    }
    
    /// Get upcoming doses in the next few hours
    func getUpcomingDoses(within hours: Int = 2) -> [ScheduledDose] {
        let cutoffTime = Calendar.current.date(byAdding: .hour, value: hours, to: Date()) ?? Date()
        return todaysDoses.filter { 
            $0.status == .scheduled && $0.scheduledTime <= cutoffTime && $0.scheduledTime >= Date()
        }
    }
    
    /// Calculate schedule metrics
    func calculateMetrics() -> ScheduleMetrics {
        let totalDoses = todaysDoses.count
        let takenDoses = todaysDoses.filter { $0.status == .taken }.count
        let overdueDoses = getOverdueDoses().count
        let upcomingDoses = getUpcomingDoses().count
        
        return ScheduleMetrics(
            totalDoses: totalDoses,
            takenDoses: takenDoses,
            overdueDoses: overdueDoses,
            upcomingDoses: upcomingDoses
        )
    }
    
    /// Validate medication data
    func validateMedication(_ medication: Medication) -> MedicationScheduleResult<Void> {
        guard let name = medication.name, !name.isEmpty else {
            return .failure(.invalidMedication)
        }
        
        guard let frequencies = medication.frequency, !frequencies.isEmpty else {
            return .failure(.invalidFrequency)
        }
        
        return .success(())
    }
    
    // MARK: - Private Methods
    
    private func performDoseStatusUpdate(_ dose: ScheduledDose, to status: DoseStatus, takenTime: Date? = nil) -> ScheduledDose? {
        // Find and update the dose
        for (timeSlot, doses) in timelineDoses {
            if let index = doses.firstIndex(where: { $0.id == dose.id }) {
                var updatedDose = doses[index]
                updatedDose.status = status
                updatedDose.actualTakenTime = takenTime
                
                // Update in timeline
                timelineDoses[timeSlot]?[index] = updatedDose
                
                // Update in today's doses
                if let todayIndex = todaysDoses.firstIndex(where: { $0.id == dose.id }) {
                    todaysDoses[todayIndex] = updatedDose
                }
                
                return updatedDose
            }
        }
        
        return nil
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
    private func generateRealSchedule(for date: Date) throws {
        // Reset current schedule
        timelineDoses = [:]
        todaysDoses = []
        
        let calendar = Calendar.current
        var allDoses: [ScheduledDose] = []
        
        // Process each medication's frequency patterns
        for medication in medications {
            guard let frequencies = medication.frequency else { 
                throw MedicationScheduleError.invalidFrequency
            }
            
            for frequency in frequencies {
                do {
                    let doses = try generateDosesForFrequency(frequency, medication: medication, date: date, calendar: calendar)
                    allDoses.append(contentsOf: doses)
                } catch {
                    throw MedicationScheduleError.schedulingFailed
                }
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
    ) throws -> [ScheduledDose] {
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
                        status: .scheduled
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
                status: .scheduled
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
                    status: .scheduled
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
                        status: .scheduled
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
                        status: .scheduled
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
    
    /// Placeholder implementation to demonstrate architecture when no real medications exist
    private func generatePlaceholderSchedule(for date: Date) {
        // Reset current schedule
        timelineDoses = [:]
        todaysDoses = []
        
        let calendar = Calendar.current
        var allDoses: [ScheduledDose] = []
        
        // Example: Create sample doses for demonstration
        let sampleDoses = [
            (Medication.sampleMedication, 8, TimeSlot.morning, MealRelation(mealTime: .breakfast, timing: .before, offsetMinutes: -15)),
            (Medication.complexMedication, 13, TimeSlot.midday, nil),
            (Medication.hourlyMedication, 18, TimeSlot.evening, MealRelation(mealTime: .dinner, timing: .after, offsetMinutes: 30)),
            (Medication.weeklyMedication, 22, TimeSlot.night, nil)
        ]
        
        for (medication, hour, timeSlot, mealRelation) in sampleDoses {
            if let scheduledTime = calendar.date(bySettingHour: hour, minute: 0, second: 0, of: date) {
                let dose = ScheduledDose(
                    medication: medication,
                    scheduledTime: scheduledTime,
                    timeSlot: timeSlot,
                    mealRelation: mealRelation,
                    status: .scheduled
                )
                allDoses.append(dose)
            }
        }
        
        groupAndSortDoses(allDoses)
    }
}

// MARK: - Extensions

extension MedicationScheduleService {
    
    /// Calculate next dose time for a medication frequency
    func calculateNextDoseTime(
        for frequency: MedicationFrequency, 
        from currentTime: Date = Date()
    ) -> Date? {
        let calendar = Calendar.current
        
        switch frequency {
        case .daily(let times):
            return calculateNextDailyDose(times: times, from: currentTime, calendar: calendar)
            
        case .hourly(let interval, let startTime):
            return calculateNextHourlyDose(interval: interval, startTime: startTime, from: currentTime, calendar: calendar)
            
        case .weekly(let dayOfWeek, let time):
            return calculateNextWeeklyDose(dayOfWeek: dayOfWeek, time: time, from: currentTime, calendar: calendar)
            
        case .biweekly(let dayOfWeek, let time):
            // Similar to weekly but every other week
            return calculateNextBiweeklyDose(dayOfWeek: dayOfWeek, time: time, from: currentTime, calendar: calendar)
            
        case .monthly(let dayOfMonth, let time):
            return calculateNextMonthlyDose(dayOfMonth: dayOfMonth, time: time, from: currentTime, calendar: calendar)
            
        case .mealBased(let mealTime, let timing):
            return calculateMealBasedDose(mealTime: mealTime, timing: timing, from: currentTime, calendar: calendar)
        }
    }
    
    // MARK: - Dose Calculation Methods (Placeholder implementations)
    
    private func calculateNextDailyDose(times: [DateComponents], from currentTime: Date, calendar: Calendar) -> Date? {
        // Implementation placeholder - will calculate next daily dose based on time components
        return calendar.date(byAdding: .day, value: 1, to: currentTime)
    }
    
    private func calculateNextHourlyDose(interval: Int, startTime: DateComponents?, from currentTime: Date, calendar: Calendar) -> Date? {
        // Implementation placeholder - will calculate next hourly dose
        return calendar.date(byAdding: .hour, value: interval, to: currentTime)
    }
    
    private func calculateNextWeeklyDose(dayOfWeek: Weekday, time: DateComponents, from currentTime: Date, calendar: Calendar) -> Date? {
        // Implementation placeholder - will calculate next weekly dose
        return calendar.date(byAdding: .weekOfYear, value: 1, to: currentTime)
    }
    
    private func calculateNextBiweeklyDose(dayOfWeek: Weekday, time: DateComponents, from currentTime: Date, calendar: Calendar) -> Date? {
        // Implementation placeholder - will calculate next biweekly dose
        return calendar.date(byAdding: .weekOfYear, value: 2, to: currentTime)
    }
    
    private func calculateNextMonthlyDose(dayOfMonth: Int, time: DateComponents, from currentTime: Date, calendar: Calendar) -> Date? {
        // Implementation placeholder - will calculate next monthly dose
        return calendar.date(byAdding: .month, value: 1, to: currentTime)
    }
    
    private func calculateMealBasedDose(mealTime: MealTime, timing: MedicationTime?, from currentTime: Date, calendar: Calendar) -> Date? {
        // Use configured meal times
        var mealDate = MealTimeConfiguration.shared.scheduledTime(for: mealTime, date: currentTime)
        
        // Adjust for timing (before/after meal)
        if let timing = timing {
            switch timing {
            case .before:
                mealDate = calendar.date(byAdding: .minute, value: -15, to: mealDate) ?? mealDate
            case .after:
                mealDate = calendar.date(byAdding: .minute, value: 30, to: mealDate) ?? mealDate
            }
        }
        
        // If time has passed today, schedule for tomorrow
        if mealDate <= currentTime {
            mealDate = calendar.date(byAdding: .day, value: 1, to: mealDate) ?? mealDate
        }
        
        return mealDate
    }
}
