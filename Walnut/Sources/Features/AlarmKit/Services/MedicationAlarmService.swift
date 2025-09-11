//
//  MedicationAlarmService.swift
//  Walnut
//
//  Created by Claude Code on 10/09/25.
//  Copyright © 2025 m. All rights reserved.
//

import Foundation
import AlarmKit
import AppIntents
import SwiftUI
import Observation

/// Service for managing medication-related alarms using AlarmKit
@Observable
class MedicationAlarmService {
    
    // MARK: - Properties
    
    typealias AlarmConfiguration = AlarmManager.AlarmConfiguration<MedicationAlarmData>
    typealias AlarmsMap = [UUID: (Alarm, String)]
    
    var activeAlarms = AlarmsMap()
    private let alarmManager = AlarmManager.shared
    
    // MARK: - Computed Properties
    
    var hasActiveAlarms: Bool {
        !activeAlarms.isEmpty
    }
    
    var alarmCount: Int {
        activeAlarms.count
    }
    
    var authorizationState: AlarmManager.AuthorizationState {
        alarmManager.authorizationState
    }
    
    var isAuthorized: Bool {
        authorizationState == .authorized
    }
    
    // MARK: - Initialization
    
    init() {
        observeAlarms()
        fetchActiveAlarms()
    }
    
    // MARK: - Authorization
    
    func requestAuthorization() async -> AlarmResult<Bool> {
        switch alarmManager.authorizationState {
        case .notDetermined:
            do {
                let state = try await alarmManager.requestAuthorization()
                return .success(state == .authorized)
            } catch {
                return .failure(.systemError(error))
            }
        case .denied:
            return .failure(.notAuthorized)
        case .authorized:
            return .success(true)
        @unknown default:
            return .failure(.systemError(NSError(domain: "AlarmKit", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unknown authorization state"])))
        }
    }
    
    // MARK: - CRUD Operations
    
    /// Create a new medication alarm
    func createMedicationAlarm(configuration: MedicationAlarmConfiguration) async -> AlarmResult<UUID> {
        let authResult = await requestAuthorization()
        guard case .success(true) = authResult else {
            if case .failure(let error) = authResult {
                return .failure(error)
            }
            return .failure(.notAuthorized)
        }
        
        let alarmID = UUID()
        let metadata = MedicationAlarmData(
            medicationID: configuration.medicationID,
            medicationName: configuration.medicationName,
            dosage: configuration.dosage,
            type: .medication
        )
        
        let presentation = createAlarmPresentation(for: configuration)
        let attributes = AlarmAttributes(
            presentation: presentation,
            metadata: metadata,
            tintColor: .healthPrimary
        )
        
        let alarmConfiguration = AlarmConfiguration(
            countdownDuration: configuration.countdownDuration,
            schedule: configuration.schedule,
            attributes: attributes,
            stopIntent: MedicationStopIntent(alarmID: alarmID.uuidString),
            secondaryIntent: configuration.enableSnooze ? MedicationSnoozeIntent(alarmID: alarmID.uuidString) : nil
        )
        
        do {
            let alarm = try await alarmManager.schedule(id: alarmID, configuration: alarmConfiguration)
            await MainActor.run {
                activeAlarms[alarmID] = (alarm, configuration.medicationName)
            }
            return .success(alarmID)
        } catch {
            return .failure(.systemError(error))
        }
    }
    
    /// Read/fetch all active alarms
    func fetchActiveAlarms() {
        do {
            let alarms = try alarmManager.alarms
            updateAlarmState(with: alarms)
        } catch {
            print("Failed to fetch alarms: \(error)")
        }
    }
    
    /// Update an existing alarm
    func updateAlarm(id: UUID, configuration: MedicationAlarmConfiguration) async -> AlarmResult<Void> {
        // First, cancel the existing alarm
        let cancelResult = await cancelAlarm(id: id)
        guard case .success = cancelResult else {
            if case .failure(let error) = cancelResult {
                return .failure(error)
            }
            return .failure(.alarmNotFound)
        }
        
        // Then create a new one with the same ID
        let createResult = await createMedicationAlarm(configuration: configuration)
        switch createResult {
        case .success:
            return .success(())
        case .failure(let error):
            return .failure(error)
        }
    }
    
    /// Delete/cancel an alarm
    func cancelAlarm(id: UUID) async -> AlarmResult<Void> {
        do {
            try alarmManager.cancel(id: id)
            await MainActor.run {
                activeAlarms[id] = nil
            }
            return .success(())
        } catch {
            return .failure(.systemError(error))
        }
    }
    
    /// Cancel all active alarms
    func cancelAllAlarms() async -> AlarmResult<Void> {
        let alarmIDs = await MainActor.run { Array(activeAlarms.keys) }
        
        for id in alarmIDs {
            let result = await cancelAlarm(id: id)
            if case .failure = result {
                // Continue cancelling other alarms even if one fails
                continue
            }
        }
        
        return .success(())
    }
    
    // MARK: - Convenience Methods
    
    /// Create a simple medication reminder
    func createMedicationReminder(medicationID: UUID, medicationName: String, dosage: String?, time: Date) async -> AlarmResult<UUID> {
        let schedule = createScheduleFromDate(time)
        let configuration = MedicationAlarmConfiguration(
            medicationID: medicationID,
            medicationName: medicationName,
            dosage: dosage,
            schedule: schedule,
            enableSnooze: true,
            enableCountdown: false
        )
        
        return await createMedicationAlarm(configuration: configuration)
    }
    
    /// Create recurring medication alarms
    func createRecurringMedicationAlarms(medicationID: UUID, medicationName: String, dosage: String?, times: [Date]) async -> AlarmResult<[UUID]> {
        var createdAlarmIDs: [UUID] = []
        
        for time in times {
            let result = await createMedicationReminder(
                medicationID: medicationID,
                medicationName: medicationName,
                dosage: dosage,
                time: time
            )
            
            switch result {
            case .success(let alarmID):
                createdAlarmIDs.append(alarmID)
            case .failure(let error):
                // Cancel previously created alarms if one fails
                for id in createdAlarmIDs {
                    await cancelAlarm(id: id)
                }
                return .failure(error)
            }
        }
        
        return .success(createdAlarmIDs)
    }
    
    // MARK: - Private Methods
    
    private func createAlarmPresentation(for configuration: MedicationAlarmConfiguration) -> AlarmPresentation {
        let dosageText = configuration.dosage.map { " (\($0))" } ?? ""
        let title = configuration.medicationName + dosageText
        
        let secondaryButton: AlarmButton? = configuration.enableSnooze ? .snoozeButton : nil
        let secondaryBehavior: AlarmPresentation.Alert.SecondaryButtonBehavior? = configuration.enableSnooze ? .custom : nil
        
        let alertContent = AlarmPresentation.Alert(
            title: LocalizedStringResource(stringLiteral: title),
            stopButton: .medicationTakenButton,
            secondaryButton: secondaryButton,
            secondaryButtonBehavior: secondaryBehavior
        )
        
        if configuration.enableCountdown, let countdownDuration = configuration.countdownDuration {
            let countdownContent = AlarmPresentation.Countdown(
                title: LocalizedStringResource(stringLiteral: "Medication Time"),
                pauseButton: .pauseButton
            )
            
            let pausedContent = AlarmPresentation.Paused(
                title: LocalizedStringResource(stringLiteral: "Reminder Paused"),
                resumeButton: .resumeButton
            )
            
            return AlarmPresentation(alert: alertContent, countdown: countdownContent, paused: pausedContent)
        } else {
            return AlarmPresentation(alert: alertContent)
        }
    }
    
    private func createScheduleFromDate(_ date: Date) -> Alarm.Schedule {
        let components = Calendar.current.dateComponents([.hour, .minute], from: date)
        let time = Alarm.Schedule.Relative.Time(
            hour: components.hour ?? 0,
            minute: components.minute ?? 0
        )
        return .relative(.init(time: time))
    }
    
    private func observeAlarms() {
        Task {
            for await incomingAlarms in alarmManager.alarmUpdates {
                updateAlarmState(with: incomingAlarms)
            }
        }
    }
    
    private func updateAlarmState(with remoteAlarms: [Alarm]) {
        Task { @MainActor in
            // Update existing alarm states
            remoteAlarms.forEach { updated in
                if let existing = activeAlarms[updated.id] {
                    activeAlarms[updated.id] = (updated, existing.1)
                }
            }
            
            let knownAlarmIDs = Set(activeAlarms.keys)
            let incomingAlarmIDs = Set(remoteAlarms.map(\.id))
            
            // Clean-up removed alarms
            let removedAlarmIDs = knownAlarmIDs.subtracting(incomingAlarmIDs)
            removedAlarmIDs.forEach {
                activeAlarms[$0] = nil
            }
        }
    }
}

// MARK: - AlarmButton Extensions

extension AlarmButton {
    static var medicationTakenButton: Self {
        AlarmButton(text: "Taken", textColor: .white, systemImageName: "checkmark.circle.fill")
    }
    
    static var snoozeButton: Self {
        AlarmButton(text: "Snooze", textColor: .black, systemImageName: "clock.fill")
    }
    
    static var pauseButton: Self {
        AlarmButton(text: "Pause", textColor: .black, systemImageName: "pause.fill")
    }
    
    static var resumeButton: Self {
        AlarmButton(text: "Resume", textColor: .black, systemImageName: "play.fill")
    }
}
