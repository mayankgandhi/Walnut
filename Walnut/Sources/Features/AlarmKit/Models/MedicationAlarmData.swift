//
//  MedicationAlarmData.swift
//  Walnut
//
//  Created by Claude Code on 10/09/25.
//  Copyright © 2025 m. All rights reserved.
//

import Foundation
import AlarmKit

/// Metadata for medication-specific alarms
struct MedicationAlarmData: AlarmMetadata, Codable, Sendable {
    let medicationID: UUID
    let medicationName: String
    let dosage: String?
    let instructions: String?
    let type: AlarmType
    
    enum AlarmType: String, Codable, CaseIterable {
        case medication = "pills.fill"
        case reminder = "bell.fill"
        case followUp = "calendar.badge.clock"
        
        var displayName: String {
            switch self {
            case .medication: return "Medication"
            case .reminder: return "Reminder"
            case .followUp: return "Follow-up"
            }
        }
        
        var icon: String {
            return self.rawValue
        }
    }
    
    init(medicationID: UUID, medicationName: String, dosage: String? = nil, instructions: String? = nil, type: AlarmType = .medication) {
        self.medicationID = medicationID
        self.medicationName = medicationName
        self.dosage = dosage
        self.instructions = instructions
        self.type = type
    }
}

/// Configuration for medication alarm scheduling
struct MedicationAlarmConfiguration {
    let medicationID: UUID
    let medicationName: String
    let dosage: String?
    let schedule: Alarm.Schedule
    let countdownDuration: Alarm.CountdownDuration?
    let enableSnooze: Bool
    let enableCountdown: Bool
    
    init(medicationID: UUID, medicationName: String, dosage: String? = nil, schedule: Alarm.Schedule, countdownDuration: Alarm.CountdownDuration? = nil, enableSnooze: Bool = true, enableCountdown: Bool = false) {
        self.medicationID = medicationID
        self.medicationName = medicationName
        self.dosage = dosage
        self.schedule = schedule
        self.countdownDuration = countdownDuration
        self.enableSnooze = enableSnooze
        self.enableCountdown = enableCountdown
    }
}
