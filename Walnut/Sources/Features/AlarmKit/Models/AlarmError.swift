//
//  AlarmError.swift
//  Walnut
//
//  Created by Claude Code on 10/09/25.
//  Copyright © 2025 m. All rights reserved.
//

import Foundation

/// Errors that can occur when working with AlarmKit
enum AlarmError: LocalizedError {
    case notAuthorized
    case alarmNotFound
    case schedulingFailed
    case invalidConfiguration
    case systemError(Error)
    
    var errorDescription: String? {
        switch self {
        case .notAuthorized:
            return "Permission denied. Please enable alarm permissions in Settings."
        case .alarmNotFound:
            return "The requested alarm was not found."
        case .schedulingFailed:
            return "Failed to schedule the alarm. Please try again."
        case .invalidConfiguration:
            return "Invalid alarm configuration provided."
        case .systemError(let error):
            return "System error: \(error.localizedDescription)"
        }
    }
    
    var recoverySuggestion: String? {
        switch self {
        case .notAuthorized:
            return "Go to Settings > Privacy & Security > Alarms and enable permissions for Walnut."
        case .alarmNotFound:
            return "The alarm may have been deleted. Try refreshing the list."
        case .schedulingFailed:
            return "Check your internet connection and try again."
        case .invalidConfiguration:
            return "Please review the alarm settings and try again."
        case .systemError:
            return "Restart the app and try again. Contact support if the issue persists."
        }
    }
}

/// Result type for alarm operations
typealias AlarmResult<T> = Result<T, AlarmError>