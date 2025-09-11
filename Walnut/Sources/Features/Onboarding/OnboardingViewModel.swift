//
//  OnboardingViewModel.swift
//  Walnut
//
//  Created by Claude on 11/09/25.
//  Copyright © 2025 m. All rights reserved.
//

import Foundation
import SwiftData
import UserNotifications
import SwiftUI

@Observable
final class OnboardingViewModel {
    
    // MARK: - Flow State
    var currentScreenIndex: Int = 0
    var isCompleted: Bool = false
    var isLoading: Bool = false
    
    // MARK: - Data Collection
    var healthProfile = HealthProfile()
    var patientSetupData = PatientSetupData()
    var permissions = AppPermissions()
    
    // MARK: - Computed Properties
    var currentScreen: OnboardingScreen {
        OnboardingScreen(rawValue: currentScreenIndex) ?? .welcome
    }
    
    var canProceedToNext: Bool {
        switch currentScreen {
        case .welcome:
            return true
        case .healthProfile:
            return true
        case .permissions:
            return true // Can proceed regardless of permission choices
        case .patientSetup:
            return true
        case .vitalsIntroduction:
            return true
        }
    }
    
    var isLastScreen: Bool {
        currentScreenIndex >= OnboardingScreen.allCases.count - 1
    }
    
    var progressPercentage: Double {
        Double(currentScreenIndex + 1) / Double(OnboardingScreen.allCases.count)
    }
    
    // MARK: - Navigation Actions
    @MainActor
    func nextScreen() {
        guard canProceedToNext else { return }
        
        withAnimation(.easeInOut(duration: 0.3)) {
            if isLastScreen {
                completeOnboarding()
            } else {
                currentScreenIndex += 1
            }
        }
    }
    
    func previousScreen() {
        guard currentScreenIndex > 0 else { return }
        
        withAnimation(.easeInOut(duration: 0.3)) {
            currentScreenIndex -= 1
        }
    }
    
    func goToScreen(_ screen: OnboardingScreen) {
        withAnimation(.easeInOut(duration: 0.3)) {
            currentScreenIndex = screen.rawValue
        }
    }
    
    // MARK: - Health Profile Actions
    func toggleChronicCondition(_ condition: ChronicCondition) {
        if healthProfile.selectedConditions.contains(condition) {
            healthProfile.selectedConditions.remove(condition)
        } else {
            healthProfile.selectedConditions.insert(condition)
        }
    }
    
    // MARK: - Permission Handling
    @MainActor
    func requestNotificationPermission() async {
        do {
            let granted = try await UNUserNotificationCenter.current().requestAuthorization(
                options: [.alert, .badge, .sound]
            )
            permissions.notifications = granted ? .granted : .denied
        } catch {
            permissions.notifications = .denied
        }
    }
    
    func checkNotificationPermission() {
        UNUserNotificationCenter.current().getNotificationSettings { [weak self] settings in
            DispatchQueue.main.async {
                switch settings.authorizationStatus {
                case .authorized, .provisional:
                    self?.permissions.notifications = .granted
                case .denied:
                    self?.permissions.notifications = .denied
                case .notDetermined:
                    self?.permissions.notifications = .notDetermined
                @unknown default:
                    self?.permissions.notifications = .notDetermined
                }
            }
        }
    }
    
    // MARK: - Patient Creation
    @MainActor
    func createPatient(modelContext: ModelContext) throws -> Patient {
        let patient = Patient(
            id: UUID(),
            name: patientSetupData.name,
            dateOfBirth: patientSetupData.dateOfBirth ?? Date(),
            gender: patientSetupData.gender,
            bloodType: patientSetupData.bloodType,
            emergencyContactName: nil,
            emergencyContactPhone: nil,
            notes: patientSetupData.notes,
            createdAt: Date(),
            updatedAt: Date(),
            medicalCases: []
        )
        
       
        modelContext.insert(patient)
        
        healthProfile.selectedConditions.forEach { condition in
            let medicalCase = MedicalCase(
                chronicCondition: condition,
                patient: patient
            )
            patient.medicalCases?.append(medicalCase)
        }
        
        try modelContext.save()
        return patient
    }
    
    // MARK: - Completion
    @MainActor
    func completeOnboarding() {
        isCompleted = true
        
        // Store onboarding completion in UserDefaults
        UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
        
        // Post notification that onboarding is complete
        NotificationCenter.default.post(name: .onboardingCompleted, object: nil)
    }
    
    // MARK: - Validation
    func validatePatientSetup() -> [String] {
        var errors: [String] = []
        
        if patientSetupData.name.isEmpty {
            errors.append("Name is required")
        }
        
        if patientSetupData.dateOfBirth == nil {
            errors.append("Date of birth is required")
        }
        
        return errors
    }
}

// MARK: - Notification Names
extension Notification.Name {
    static let onboardingCompleted = Notification.Name("onboardingCompleted")
}
