//
//  MedicationNotificationManager.swift
//  Walnut
//
//  Created by Claude Code on 16/09/25.
//  Copyright © 2025 m. All rights reserved.
//

import Foundation
import UserNotifications
import SwiftUI
import Observation
import AlarmKit

@Observable
class MedicationNotificationManager {

    // MARK: - Properties

    var authorizationStatus: UNAuthorizationStatus = .notDetermined
    var pendingNotifications: [UNNotificationRequest] = []
    private let alarmService = MedicationAlarmService()
    private let userDefaults = UserDefaults.standard

    // MARK: - Configuration

    var preferredNotificationType: NotificationType {
        get {
            if let rawValue = userDefaults.string(forKey: "PreferredNotificationType"),
               let type = NotificationType(rawValue: rawValue) {
                return type
            }
            return .pushNotifications
        }
        set {
            userDefaults.set(newValue.rawValue, forKey: "PreferredNotificationType")
        }
    }

    var mealTimings: [MealTime: Date] {
        get {
            var timings: [MealTime: Date] = [:]
            for mealTime in MealTime.allCases {
                if let data = userDefaults.data(forKey: "MealTime_\(mealTime.rawValue)"),
                   let date = try? JSONDecoder().decode(Date.self, from: data) {
                    timings[mealTime] = date
                } else {
                    // Default meal times
                    timings[mealTime] = defaultMealTime(for: mealTime)
                }
            }
            return timings
        }
        set {
            for (mealTime, date) in newValue {
                if let data = try? JSONEncoder().encode(date) {
                    userDefaults.set(data, forKey: "MealTime_\(mealTime.rawValue)")
                }
            }
        }
    }

    // Smart scheduling preferences
    var sleepStartHour: Int {
        get { userDefaults.integer(forKey: "SleepStartHour") == 0 ? 22 : userDefaults.integer(forKey: "SleepStartHour") }
        set { userDefaults.set(newValue, forKey: "SleepStartHour") }
    }

    var sleepEndHour: Int {
        get { userDefaults.integer(forKey: "SleepEndHour") == 0 ? 7 : userDefaults.integer(forKey: "SleepEndHour") }
        set { userDefaults.set(newValue, forKey: "SleepEndHour") }
    }

    var enableSmartScheduling: Bool {
        get { userDefaults.bool(forKey: "EnableSmartScheduling") }
        set { userDefaults.set(newValue, forKey: "EnableSmartScheduling") }
    }

    enum NotificationType: String, CaseIterable {
        case pushNotifications = "Push Notifications"
        case alarms = "Alarms"

        var icon: String {
            switch self {
            case .pushNotifications: return "bell.fill"
            case .alarms: return "alarm.fill"
            }
        }
    }

    // MARK: - Initialization

    init() {
        checkAuthorizationStatus()
        loadPendingNotifications()
    }

    // MARK: - Authorization

    func requestAuthorization() async -> Bool {
        do {
            let granted = try await UNUserNotificationCenter.current().requestAuthorization(
                options: [.alert, .badge, .sound, .criticalAlert]
            )
            await MainActor.run {
                authorizationStatus = granted ? .authorized : .denied
            }
            return granted
        } catch {
            await MainActor.run {
                authorizationStatus = .denied
            }
            return false
        }
    }

    func checkAuthorizationStatus() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                self.authorizationStatus = settings.authorizationStatus
            }
        }
    }

    // MARK: - Medication Notification Scheduling

    func scheduleNotificationsForMedication(_ medication: Medication) async -> Result<[String], Error> {
        // Check authorization first
        guard await ensureAuthorization() else {
            return .failure(NotificationError.authorizationDenied)
        }

        guard let frequencies = medication.frequency, !frequencies.isEmpty else {
            return .failure(NotificationError.invalidFrequency)
        }

        // Cancel any existing notifications for this medication first
        await cancelNotificationsForMedication(medication)

        var scheduledIdentifiers: [String] = []

        for frequency in frequencies {
            let result = await scheduleNotificationForFrequency(
                frequency: frequency,
                medication: medication
            )

            switch result {
            case .success(let identifiers):
                scheduledIdentifiers.append(contentsOf: identifiers)
            case .failure(let error):
                // Cancel any previously scheduled notifications for this medication
                await cancelNotificationsForMedication(medication)
                return .failure(NotificationError.schedulingFailed(error))
            }
        }

        return .success(scheduledIdentifiers)
    }

    private func ensureAuthorization() async -> Bool {
        switch authorizationStatus {
        case .notDetermined:
            return await requestAuthorization()
        case .authorized:
            return true
        case .denied, .provisional, .ephemeral:
            return false
        @unknown default:
            return false
        }
    }

    private func scheduleNotificationForFrequency(
        frequency: MedicationFrequency,
        medication: Medication
    ) async -> Result<[String], Error> {

        switch preferredNotificationType {
        case .pushNotifications:
            return await scheduleUNNotifications(frequency: frequency, medication: medication)
        case .alarms:
            return await scheduleAlarmNotifications(frequency: frequency, medication: medication)
        }
    }

    // MARK: - UNUserNotificationCenter Integration

    private func scheduleUNNotifications(
        frequency: MedicationFrequency,
        medication: Medication
    ) async -> Result<[String], Error> {

        let schedules = generateNotificationSchedules(for: frequency)
        var identifiers: [String] = []

        for schedule in schedules {
            let identifier = "\(medication.id?.uuidString ?? UUID().uuidString)_\(schedule.hashValue)"

            let content = UNMutableNotificationContent()
            content.title = "Medication Reminder"
            content.body = createNotificationBody(for: medication)
            content.sound = .default
            content.badge = NSNumber(value: 1)
            content.categoryIdentifier = "MEDICATION_REMINDER"

            // Add medication details to user info
            content.userInfo = [
                "medicationId": medication.id?.uuidString ?? "",
                "medicationName": medication.name ?? "",
                "dosage": medication.dosage ?? "",
                "instructions": medication.instructions ?? ""
            ]

            let trigger = createNotificationTrigger(for: schedule, frequency: frequency)
            let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)

            do {
                try await UNUserNotificationCenter.current().add(request)
                identifiers.append(identifier)
            } catch {
                return .failure(error)
            }
        }

        return .success(identifiers)
    }

    // MARK: - AlarmKit Integration

    private func scheduleAlarmNotifications(
        frequency: MedicationFrequency,
        medication: Medication
    ) async -> Result<[String], Error> {

        let schedules = generateNotificationSchedules(for: frequency)
        var identifiers: [String] = []

        for schedule in schedules {
            let alarmSchedule = convertToAlarmSchedule(schedule)

            let configuration = MedicationAlarmConfiguration(
                medicationID: medication.id ?? UUID(),
                medicationName: medication.name ?? "Medication",
                dosage: medication.dosage,
                schedule: alarmSchedule,
                enableSnooze: true,
                enableCountdown: false
            )

            let result = await alarmService.createMedicationAlarm(configuration: configuration)

            switch result {
            case .success(let alarmId):
                identifiers.append(alarmId.uuidString)
            case .failure(let error):
                return .failure(error)
            }
        }

        return .success(identifiers)
    }

    // MARK: - Schedule Generation

    private func generateNotificationSchedules(for frequency: MedicationFrequency) -> [NotificationSchedule] {
        switch frequency {
        case .daily(let times):
            return times.compactMap { timeComponent in
                NotificationSchedule.daily(hour: timeComponent.hour ?? 0, minute: timeComponent.minute ?? 0)
            }

        case .hourly(let interval, let startTime):
            return generateHourlySchedules(interval: interval, startTime: startTime)

        case .weekly(let dayOfWeek, let time):
            return [NotificationSchedule.weekly(
                weekday: dayOfWeek.rawValue,
                hour: time.hour ?? 0,
                minute: time.minute ?? 0
            )]

        case .biweekly(let dayOfWeek, let time):
            return [NotificationSchedule.biweekly(
                weekday: dayOfWeek.rawValue,
                hour: time.hour ?? 0,
                minute: time.minute ?? 0
            )]

        case .monthly(let dayOfMonth, let time):
            return [NotificationSchedule.monthly(
                day: dayOfMonth,
                hour: time.hour ?? 0,
                minute: time.minute ?? 0
            )]

        case .mealBased(let mealTime, let timing):
            return generateMealBasedSchedule(mealTime: mealTime, timing: timing)
        }
    }

    private func generateHourlySchedules(interval: Int, startTime: DateComponents?) -> [NotificationSchedule] {
        let start = startTime ?? DateComponents(hour: 8, minute: 0)
        let startHour = start.hour ?? 8
        var schedules: [NotificationSchedule] = []

        // Generate schedules for a 24-hour period with the given interval
        var currentHour = startHour
        repeat {
            let adjustedHour = enableSmartScheduling ? adjustForSleepHours(hour: currentHour % 24) : currentHour % 24
            schedules.append(.daily(hour: adjustedHour, minute: start.minute ?? 0))
            currentHour += interval
        } while currentHour < startHour + 24

        // Remove duplicates and sort
        let uniqueSchedules = Array(Set(schedules)).sorted { schedule1, schedule2 in
            switch (schedule1, schedule2) {
            case (.daily(let h1, let m1), .daily(let h2, let m2)):
                return h1 < h2 || (h1 == h2 && m1 < m2)
            default:
                return false
            }
        }

        return enableSmartScheduling ? distributeEvenlyInAwakeHours(schedules: uniqueSchedules) : uniqueSchedules
    }

    // MARK: - Smart Scheduling Logic

    private func adjustForSleepHours(hour: Int) -> Int {
        // If the hour falls within sleep time, move it to the wake-up hour
        if isInSleepHours(hour: hour) {
            return sleepEndHour
        }
        return hour
    }

    private func isInSleepHours(hour: Int) -> Bool {
        if sleepStartHour < sleepEndHour {
            // Sleep time doesn't cross midnight (e.g., 22:00 to 7:00 next day)
            return false // This case is unusual, but handled
        } else {
            // Sleep time crosses midnight (e.g., 22:00 to 7:00 next day)
            return hour >= sleepStartHour || hour < sleepEndHour
        }
    }

    private func distributeEvenlyInAwakeHours(schedules: [NotificationSchedule]) -> [NotificationSchedule] {
        guard schedules.count > 1 else { return schedules }

        let awakeHours = getAwakeHours()
        guard awakeHours.count >= schedules.count else { return schedules }

        // Calculate optimal distribution
        let interval = awakeHours.count / schedules.count
        var distributedSchedules: [NotificationSchedule] = []

        for (index, schedule) in schedules.enumerated() {
            let targetIndex = min(index * interval, awakeHours.count - 1)
            let targetHour = awakeHours[targetIndex]

            // Preserve original minute
            let minute = extractMinute(from: schedule)
            distributedSchedules.append(.daily(hour: targetHour, minute: minute))
        }

        return distributedSchedules
    }

    private func getAwakeHours() -> [Int] {
        var awakeHours: [Int] = []

        if sleepStartHour < sleepEndHour {
            // Unusual case: sleep time in same day
            for hour in sleepEndHour..<sleepStartHour {
                awakeHours.append(hour)
            }
        } else {
            // Normal case: sleep time crosses midnight
            for hour in sleepEndHour..<sleepStartHour {
                awakeHours.append(hour)
            }
        }

        return awakeHours
    }

    private func extractMinute(from schedule: NotificationSchedule) -> Int {
        switch schedule {
        case .daily(_, let minute):
            return minute
        case .weekly(_, _, let minute):
            return minute
        case .biweekly(_, _, let minute):
            return minute
        case .monthly(_, _, let minute):
            return minute
        }
    }

    private func generateMealBasedSchedule(mealTime: MealTime, timing: MedicationTime?) -> [NotificationSchedule] {
        guard let mealDate = mealTimings[mealTime] else { return [] }

        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: mealDate)
        let hour = components.hour ?? 0
        let minute = components.minute ?? 0

        let adjustedTime = adjustTimeForMealTiming(hour: hour, minute: minute, timing: timing)

        return [NotificationSchedule.daily(hour: adjustedTime.hour, minute: adjustedTime.minute)]
    }

    private func adjustTimeForMealTiming(hour: Int, minute: Int, timing: MedicationTime?) -> (hour: Int, minute: Int) {
        let calendar = Calendar.current
        let mealDate = calendar.date(bySettingHour: hour, minute: minute, second: 0, of: Date()) ?? Date()

        let adjustedDate: Date
        switch timing {
        case .before:
            adjustedDate = mealDate.addingTimeInterval(-15 * 60) // 15 minutes before
        case .after:
            adjustedDate = mealDate.addingTimeInterval(30 * 60) // 30 minutes after
        case .none:
            adjustedDate = mealDate
        }

        let adjustedComponents = calendar.dateComponents([.hour, .minute], from: adjustedDate)
        return (hour: adjustedComponents.hour ?? hour, minute: adjustedComponents.minute ?? minute)
    }

    // MARK: - Notification Management

    func cancelNotificationsForMedication(_ medication: Medication) async {
        guard let medicationId = medication.id?.uuidString else { return }

        // Cancel UNUserNotificationCenter notifications
        let pendingRequests = try? await UNUserNotificationCenter.current().pendingNotificationRequests()
        let medicationNotifications = pendingRequests?.filter { request in
            request.content.userInfo["medicationId"] as? String == medicationId
        } ?? []

        let identifiersToCancel = medicationNotifications.map { $0.identifier }
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: identifiersToCancel)

        // Cancel alarm service notifications
        for (alarmId, _) in alarmService.activeAlarms {
            await alarmService.cancelAlarm(id: alarmId)
        }
    }

    func cancelAllMedicationNotifications() async {
        // Cancel all UNUserNotificationCenter notifications
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()

        // Cancel all alarms
        await alarmService.cancelAllAlarms()

        await loadPendingNotifications()
    }

    func loadPendingNotifications() {
        Task {
            do {
                let requests = try await UNUserNotificationCenter.current().pendingNotificationRequests()
                await MainActor.run {
                    self.pendingNotifications = requests.filter { request in
                        request.content.categoryIdentifier == "MEDICATION_REMINDER"
                    }
                }
            } catch {
                print("Failed to load pending notifications: \(error)")
            }
        }
    }

    // MARK: - Helper Methods

    private func createNotificationBody(for medication: Medication) -> String {
        var body = "Time to take your \(medication.name ?? "medication")"

        if let dosage = medication.dosage {
            body += " (\(dosage))"
        }

        if let instructions = medication.instructions, !instructions.isEmpty {
            body += " - \(instructions)"
        }

        return body
    }

    private func createNotificationTrigger(
        for schedule: NotificationSchedule,
        frequency: MedicationFrequency
    ) -> UNNotificationTrigger {

        switch schedule {
        case .daily(let hour, let minute):
            var components = DateComponents()
            components.hour = hour
            components.minute = minute
            return UNCalendarNotificationTrigger(dateMatching: components, repeats: true)

        case .weekly(let weekday, let hour, let minute):
            var components = DateComponents()
            components.weekday = weekday
            components.hour = hour
            components.minute = minute
            return UNCalendarNotificationTrigger(dateMatching: components, repeats: true)

        case .biweekly(let weekday, let hour, let minute):
            var components = DateComponents()
            components.weekday = weekday
            components.hour = hour
            components.minute = minute
            components.weekOfYear = 2
            return UNCalendarNotificationTrigger(dateMatching: components, repeats: true)

        case .monthly(let day, let hour, let minute):
            var components = DateComponents()
            components.day = day
            components.hour = hour
            components.minute = minute
            return UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        }
    }

    private func convertToAlarmSchedule(_ schedule: NotificationSchedule) -> Alarm.Schedule {
        switch schedule {
        case .daily(let hour, let minute):
            let time = Alarm.Schedule.Relative.Time(hour: hour, minute: minute)
            return .relative(.init(time: time))
        default:
            // For complex schedules, use relative time as fallback
            let time = Alarm.Schedule.Relative.Time(hour: 8, minute: 0)
            return .relative(.init(time: time))
        }
    }

    private func defaultMealTime(for mealTime: MealTime) -> Date {
        let calendar = Calendar.current
        let now = Date()

        switch mealTime {
        case .breakfast:
            return calendar.date(bySettingHour: 8, minute: 0, second: 0, of: now) ?? now
        case .lunch:
            return calendar.date(bySettingHour: 12, minute: 0, second: 0, of: now) ?? now
        case .dinner:
            return calendar.date(bySettingHour: 19, minute: 0, second: 0, of: now) ?? now
        case .bedtime:
            return calendar.date(bySettingHour: 22, minute: 0, second: 0, of: now) ?? now
        }
    }
}

// MARK: - Supporting Types

enum NotificationSchedule: Hashable, Comparable {
    case daily(hour: Int, minute: Int)
    case weekly(weekday: Int, hour: Int, minute: Int)
    case biweekly(weekday: Int, hour: Int, minute: Int)
    case monthly(day: Int, hour: Int, minute: Int)

    static func < (lhs: NotificationSchedule, rhs: NotificationSchedule) -> Bool {
        switch (lhs, rhs) {
        case (.daily(let h1, let m1), .daily(let h2, let m2)):
            return h1 < h2 || (h1 == h2 && m1 < m2)
        case (.weekly(_, let h1, let m1), .weekly(_, let h2, let m2)):
            return h1 < h2 || (h1 == h2 && m1 < m2)
        case (.biweekly(_, let h1, let m1), .biweekly(_, let h2, let m2)):
            return h1 < h2 || (h1 == h2 && m1 < m2)
        case (.monthly(_, let h1, let m1), .monthly(_, let h2, let m2)):
            return h1 < h2 || (h1 == h2 && m1 < m2)
        default:
            return false
        }
    }
}

enum NotificationError: LocalizedError {
    case invalidFrequency
    case authorizationDenied
    case schedulingFailed(Error)

    var errorDescription: String? {
        switch self {
        case .invalidFrequency:
            return "Invalid medication frequency"
        case .authorizationDenied:
            return "Notification authorization denied"
        case .schedulingFailed(let error):
            return "Failed to schedule notification: \(error.localizedDescription)"
        }
    }
}
