//
//  MedicationAlarmIntents.swift
//  Walnut
//
//  Created by Claude Code on 10/09/25.
//  Copyright © 2025 m. All rights reserved.
//

import AlarmKit
import AppIntents
import Foundation

/// Intent to stop a medication alarm and mark as taken
struct MedicationStopIntent: LiveActivityIntent {
    static var title: LocalizedStringResource = "Mark as Taken"
    static var description = IntentDescription("Mark medication as taken and stop the alarm")
    static var openAppWhenRun = false
    
    @Parameter(title: "Alarm ID")
    var alarmID: String
    
    init(alarmID: String) {
        self.alarmID = alarmID
    }
    
    init() {
        self.alarmID = ""
    }
    
    func perform() throws -> some IntentResult {
        guard let id = UUID(uuidString: alarmID) else {
            throw AlarmError.invalidConfiguration
        }
        
        try AlarmManager.shared.stop(id: id)
        
        // TODO: Mark medication as taken in the app's database
        // This could be done through a notification or app state management
        NotificationCenter.default.post(
            name: .medicationTaken,
            object: nil,
            userInfo: ["medicationAlarmID": id]
        )
        
        return .result()
    }
}

/// Intent to snooze a medication alarm
struct MedicationSnoozeIntent: LiveActivityIntent {
    static var title: LocalizedStringResource = "Snooze"
    static var description = IntentDescription("Snooze the medication reminder for 5 minutes")
    static var openAppWhenRun = false
    
    @Parameter(title: "Alarm ID")
    var alarmID: String
    
    init(alarmID: String) {
        self.alarmID = alarmID
    }
    
    init() {
        self.alarmID = ""
    }
    
    func perform() async throws -> some IntentResult {
        guard let id = UUID(uuidString: alarmID) else {
            throw AlarmError.invalidConfiguration
        }
        
        // Stop current alarm
        try AlarmManager.shared.stop(id: id)
        
        // Schedule new alarm in 5 minutes
        let snoozeTime = Date().addingTimeInterval(5 * 60) // 5 minutes
        let components = Calendar.current.dateComponents([.hour, .minute], from: snoozeTime)
        let time = Alarm.Schedule.Relative.Time(
            hour: components.hour ?? 0,
            minute: components.minute ?? 0
        )
        let schedule = Alarm.Schedule.relative(.init(time: time))
        
        // Create snoozed alarm configuration
        let metadata = MedicationAlarmData(
            medicationID: UUID(), // This should be retrieved from the original alarm
            medicationName: "Medication Reminder (Snoozed)",
            type: .reminder
        )
        
        let alertContent = AlarmPresentation.Alert(
            title: "Medication Reminder (Snoozed)",
            stopButton: .medicationTakenButton,
            secondaryButton: .snoozeButton,
            secondaryButtonBehavior: .custom
        )
        
        let attributes = AlarmAttributes(
            presentation: AlarmPresentation(alert: alertContent),
            metadata: metadata,
            tintColor: .orange
        )
        
        let configuration = AlarmManager.AlarmConfiguration<MedicationAlarmData>(
            schedule: schedule,
            attributes: attributes,
            stopIntent: MedicationStopIntent(alarmID: id.uuidString),
            secondaryIntent: MedicationSnoozeIntent(alarmID: id.uuidString)
        )
        
        _ = try await AlarmManager.shared
            .schedule(id: UUID(), configuration: configuration)
        
        return .result()
    }
}

/// Intent to pause a medication countdown
struct MedicationPauseIntent: LiveActivityIntent {
    static var title: LocalizedStringResource = "Pause"
    static var description = IntentDescription("Pause the medication countdown")
    
    @Parameter(title: "Alarm ID")
    var alarmID: String
    
    init(alarmID: String) {
        self.alarmID = alarmID
    }
    
    init() {
        self.alarmID = ""
    }
    
    func perform() throws -> some IntentResult {
        guard let id = UUID(uuidString: alarmID) else {
            throw AlarmError.notAuthorized
        }
        
        try AlarmManager.shared.pause(id: id)
        return .result()
    }
}

/// Intent to resume a paused medication countdown
struct MedicationResumeIntent: LiveActivityIntent {
    static var title: LocalizedStringResource = "Resume"
    static var description = IntentDescription("Resume the medication countdown")
    
    @Parameter(title: "Alarm ID")
    var alarmID: String
    
    init(alarmID: String) {
        self.alarmID = alarmID
    }
    
    init() {
        self.alarmID = ""
    }
    
    func perform() throws -> some IntentResult {
        guard let id = UUID(uuidString: alarmID) else {
            throw AlarmError.invalidConfiguration
        }
        
        try AlarmManager.shared.resume(id: id)
        return .result()
    }
}

/// Intent to open the app when medication alarm is triggered
struct MedicationOpenAppIntent: LiveActivityIntent {
    static var title: LocalizedStringResource = "Open App"
    static var description = IntentDescription("Open Walnut app for medication management")
    static var openAppWhenRun = true
    
    @Parameter(title: "Alarm ID")
    var alarmID: String
    
    init(alarmID: String) {
        self.alarmID = alarmID
    }
    
    init() {
        self.alarmID = ""
    }
    
    func perform() throws -> some IntentResult {
        guard let id = UUID(uuidString: alarmID) else {
            throw AlarmError.invalidConfiguration
        }
        
        // Stop the alarm when opening the app
        try AlarmManager.shared.stop(id: id)
        
        // The app will open automatically due to openAppWhenRun = true
        return .result()
    }
}

// MARK: - Notification Names

extension Notification.Name {
    static let medicationTaken = Notification.Name("medicationTaken")
    static let medicationSnoozed = Notification.Name("medicationSnoozed")
}
