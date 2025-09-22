//
//  AnalyticsEvents.swift
//  Walnut
//
//  Copyright © 2025 m. All rights reserved.
//

import Foundation

// MARK: - AnalyticsEvent Enum

enum AnalyticsEvent {
    case patient(PatientEvent)
    case medicalCase(MedicalCaseEvent)
    case prescription(PrescriptionEvent)
    case medication(MedicationEvent)
    case document(DocumentEvent)
    case app(AppEvent)
    case userExperience(UserExperienceEvent)

    var eventName: String {
        switch self {
        case .patient(let event):
            return "patient_\(event.rawValue)"
        case .medicalCase(let event):
            return "medical_case_\(event.rawValue)"
        case .prescription(let event):
            return "prescription_\(event.rawValue)"
        case .medication(let event):
            return "medication_\(event.rawValue)"
        case .document(let event):
            return "document_\(event.rawValue)"
        case .app(let event):
            return "app_\(event.rawValue)"
        case .userExperience(let event):
            return "user_experience_\(event.rawValue)"
        }
    }
}

// MARK: - Event Categories

enum PatientEvent: String {
    case created
    case updated
    case deleted
    case viewed
    case editorOpened = "editor_opened"
}

enum MedicalCaseEvent: String {
    case created
    case updated
    case deleted
    case viewed
    case editorOpened = "editor_opened"
}

enum PrescriptionEvent: String {
    case created
    case updated
    case deleted
    case viewed
    case editorOpened = "editor_opened"
}

enum MedicationEvent: String {
    case added
    case updated
    case deleted
    case viewed
    case editorOpened = "editor_opened"
}

enum DocumentEvent: String {
    case uploadStarted = "upload_started"
    case uploadCompleted = "upload_completed"
    case parseSucceeded = "parse_succeeded"
    case parseFailed = "parse_failed"
    case viewed
}

enum AppEvent: String {
    case launched
    case featureUsed = "feature_used"
    case errorOccurred = "error_occurred"
}

enum UserExperienceEvent: String {
    case searchPerformed = "search_performed"
    case filterApplied = "filter_applied"
    case exportInitiated = "export_initiated"
}