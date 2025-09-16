//
//  NotificationErrorHandler.swift
//  Walnut
//
//  Created by Claude Code on 16/09/25.
//  Copyright © 2025 m. All rights reserved.
//

import Foundation
import SwiftUI

@Observable
class NotificationErrorHandler {

    var currentError: NotificationError?
    var showError = false

    func handleError(_ error: Error) {
        DispatchQueue.main.async {
            if let notificationError = error as? NotificationError {
                self.currentError = notificationError
            } else {
                self.currentError = .schedulingFailed(error)
            }
            self.showError = true
        }
    }

    func clearError() {
        currentError = nil
        showError = false
    }

    var errorTitle: String {
        guard let error = currentError else { return "Error" }

        switch error {
        case .invalidFrequency:
            return "Invalid Medication Schedule"
        case .authorizationDenied:
            return "Notification Permission Required"
        case .schedulingFailed:
            return "Scheduling Failed"
        }
    }

    var errorMessage: String {
        guard let error = currentError else { return "An unknown error occurred." }

        switch error {
        case .invalidFrequency:
            return "Please set a valid frequency schedule for this medication."
        case .authorizationDenied:
            return "Notification permission is required to schedule medication reminders. Please enable notifications in Settings."
        case .schedulingFailed(let underlyingError):
            return "Failed to schedule medication reminder: \(underlyingError.localizedDescription)"
        }
    }

    var errorIcon: String {
        guard let error = currentError else { return "exclamationmark.triangle" }

        switch error {
        case .invalidFrequency:
            return "calendar.badge.exclamationmark"
        case .authorizationDenied:
            return "bell.slash"
        case .schedulingFailed:
            return "exclamationmark.triangle"
        }
    }

    var primaryAction: (title: String, action: () -> Void)? {
        guard let error = currentError else { return nil }

        switch error {
        case .authorizationDenied:
            return ("Open Settings", {
                if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(settingsURL)
                }
            })
        default:
            return nil
        }
    }
}

// MARK: - SwiftUI View Modifier

struct NotificationErrorAlert: ViewModifier {
    @State private var errorHandler = NotificationErrorHandler()

    func body(content: Content) -> some View {
        content
            .environment(errorHandler)
            .alert(
                errorHandler.errorTitle,
                isPresented: $errorHandler.showError,
                presenting: errorHandler.currentError
            ) { error in
                if let primaryAction = errorHandler.primaryAction {
                    Button(primaryAction.title) {
                        primaryAction.action()
                        errorHandler.clearError()
                    }
                }

                Button("OK") {
                    errorHandler.clearError()
                }
            } message: { error in
                Text(errorHandler.errorMessage)
            }
    }
}

extension View {
    func notificationErrorHandling() -> some View {
        modifier(NotificationErrorAlert())
    }
}

// MARK: - Environment Key

private struct NotificationErrorHandlerKey: EnvironmentKey {
    static let defaultValue = NotificationErrorHandler()
}

extension EnvironmentValues {
    var notificationErrorHandler: NotificationErrorHandler {
        get { self[NotificationErrorHandlerKey.self] }
        set { self[NotificationErrorHandlerKey.self] = newValue }
    }
}