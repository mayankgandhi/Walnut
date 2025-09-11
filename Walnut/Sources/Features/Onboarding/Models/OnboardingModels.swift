//
//  OnboardingModels.swift
//  Walnut
//
//  Created by Claude on 11/09/25.
//  Copyright © 2025 m. All rights reserved.
//

import Foundation

/// Represents different onboarding flow screens
enum OnboardingScreen: Int, CaseIterable {
    case welcome = 0
    case healthProfile
    case permissions
    case patientSetup
    case vitalsIntroduction
    
    var title: String {
        switch self {
            case .welcome:
                return "Welcome to HealthStack"
            case .healthProfile:
                return "Health Profile"
            case .permissions:
                return "Permissions"
            case .patientSetup:
                return "Patient Information"
            case .vitalsIntroduction:
                return "Vitals Tracking"
                
        }
    }
    
    var subtitle: String {
        switch self {
            case .welcome:
                return "Your comprehensive health management companion"
            case .healthProfile:
                return "Tell us about your health conditions and emergency contacts"
            case .permissions:
                return "Enable features to get the most out of your health tracking"
            case .patientSetup:
                return "Let's set up your patient profile"
            case .vitalsIntroduction:
                return "Track your vital signs and health metrics"
                
        }
    }
}

/// Common chronic conditions for health profile setup
enum ChronicCondition: String, CaseIterable {

    case diabetes = "Diabetes"
    case hypertension = "High Blood Pressure"
    case heartDisease = "Heart Disease"
    case asthma = "Asthma"
    case arthritis = "Arthritis"
    case copd = "COPD"
    case osteoporosis = "Osteoporosis"
    case thyroidDisorder = "Thyroid Disorder"
    
    var icon: String {
        switch self {
            case .diabetes:
                return "drop.circle"
            case .hypertension:
                return "heart.circle"
            case .heartDisease:
                return "heart.fill"
            case .asthma:
                return "lungs.fill"
            case .arthritis:
                return "figure.walk.circle"
            case .copd:
                return "lungs"
            case .osteoporosis:
                return "figure.stand"
            case .thyroidDisorder:
                return "pills.circle"
        }
    }
    
    var color: String {
        switch self {
            case .diabetes:
                return "orange"
            case .hypertension, .heartDisease:
                return "red"
            case .asthma, .copd:
                return "blue"
            case .arthritis:
                return "purple"
            case .osteoporosis:
                return "brown"
            case .thyroidDisorder:
                return "green"
        }
    }
}

/// Health profile data collected during onboarding
struct HealthProfile {
    var selectedConditions: Set<ChronicCondition> = []
}

/// Patient setup data
struct PatientSetupData {
    var name: String = ""
    var dateOfBirth: Date?
    var gender: String = ""
    var bloodType: String = ""
    var notes: String = ""
}

/// Permission states
enum PermissionStatus {
    case notDetermined
    case granted
    case denied
}

/// App permissions needed for full functionality
struct AppPermissions {
    var notifications: PermissionStatus = .notDetermined
    var healthKit: PermissionStatus = .notDetermined
}
