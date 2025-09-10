//
//  MedicationScheduleError.swift
//  Walnut
//
//  Created by Mayank Gandhi on 10/09/25.
//  Copyright © 2025 m. All rights reserved.
//

import Foundation

/// Errors that can occur in the medication scheduling system
enum MedicationScheduleError: LocalizedError {
    case invalidMedication
    case invalidFrequency
    case schedulingFailed
    case doseUpdateFailed
    case dataCorruption
    case persistenceError(Error)
    
    var errorDescription: String? {
        switch self {
        case .invalidMedication:
            return "Invalid medication data"
        case .invalidFrequency:
            return "Invalid medication frequency configuration"
        case .schedulingFailed:
            return "Failed to generate medication schedule"
        case .doseUpdateFailed:
            return "Failed to update dose status"
        case .dataCorruption:
            return "Medication data appears to be corrupted"
        case .persistenceError(let error):
            return "Database error: \(error.localizedDescription)"
        }
    }
    
    var recoverySuggestion: String? {
        switch self {
        case .invalidMedication, .invalidFrequency:
            return "Please check the medication configuration and try again."
        case .schedulingFailed:
            return "Please try refreshing the schedule or restart the app."
        case .doseUpdateFailed:
            return "Please try updating the dose status again."
        case .dataCorruption:
            return "Please try reloading the medication data."
        case .persistenceError:
            return "Please try again or restart the app if the problem persists."
        }
    }
}

/// Result type for medication schedule operations
typealias MedicationScheduleResult<T> = Result<T, MedicationScheduleError>