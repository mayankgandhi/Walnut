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
    
    // MARK: - Initialization
    init() {
        // Check permissions at startup to determine initial flow
        checkNotificationPermission()
    }
    
    // MARK: - Dynamic Flow Management
    private var _availableScreens: [OnboardingScreen] = []
    
    var availableScreens: [OnboardingScreen] {
        if _availableScreens.isEmpty {
            _availableScreens = calculateAvailableScreens()
        }
        return _availableScreens
    }
    
    // MARK: - Computed Properties
    var currentScreen: OnboardingScreen {
        guard currentScreenIndex < availableScreens.count else {
            return availableScreens.last ?? .welcome
        }
        return availableScreens[currentScreenIndex]
    }
    
    var canProceedToNext: Bool {
        switch currentScreen {
        case .welcome:
            return true
        case .healthProfile:
            return true
        case .permissions:
            return true // Can proceed regardless of permission choices
        case .patientName:
            return validatePatientName()
        case .patientDateOfBirth:
            return validatePatientDateOfBirth()
        case .vitalsIntroduction:
            return true
        }
    }
    
    var isLastScreen: Bool {
        currentScreenIndex >= availableScreens.count - 1
    }
    
    var progressPercentage: Double {
        Double(currentScreenIndex + 1) / Double(availableScreens.count)
    }
    
    // MARK: - Navigation Actions
    @MainActor
    func nextScreen(modelContext: ModelContext) async throws {
        guard canProceedToNext else { return }
        
        if isLastScreen {
            _ = try createPatient(modelContext: modelContext)
            completeOnboarding()
        } else {
            withAnimation(.easeInOut(duration: 0.3)) {
                currentScreenIndex += 1
                AnalyticsService.shared.track(.app(.featureUsed))
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
        if let index = availableScreens.firstIndex(of: screen) {
            withAnimation(.easeInOut(duration: 0.3)) {
                currentScreenIndex = index
            }
        }
    }
    
    // MARK: - Dynamic Flow Calculation
    private func calculateAvailableScreens() -> [OnboardingScreen] {
        var screens: [OnboardingScreen] = [.welcome, .healthProfile]

        // Only include permissions screen if notifications are not already granted
        if permissions.notifications != .granted {
            screens.append(.permissions)
        }

        // Always include patient name, date of birth, and vitals introduction
        screens.append(contentsOf: [.patientName, .patientDateOfBirth, .vitalsIntroduction])

        return screens
    }
    
    func refreshAvailableScreens() {
        _availableScreens = calculateAvailableScreens()
    }
    
    // MARK: - Health Profile Actions
    func toggleChronicCondition(_ condition: ChronicCondition) {
        if healthProfile.selectedConditions.contains(condition) {
            healthProfile.selectedConditions.remove(condition)
        } else {
            healthProfile.selectedConditions.insert(condition)
            AnalyticsService.shared.track(.app(.featureUsed))
        }
    }
    
    // MARK: - Permission Handling
    @MainActor
    func requestNotificationPermission() async {
        AnalyticsService.shared.track(.app(.featureUsed))
        do {
            let granted = try await UNUserNotificationCenter.current().requestAuthorization(
                options: [.alert, .badge, .sound, .criticalAlert]
            )
            permissions.notifications = granted ? .granted : .denied
            refreshAvailableScreens()
        } catch {
            permissions.notifications = .denied
            refreshAvailableScreens()
            AnalyticsService.shared.track(.app(.errorOccurred))
        }
    }
    
    func checkNotificationPermission() {
        UNUserNotificationCenter.current().getNotificationSettings { [weak self] settings in
            DispatchQueue.main.async {
                let oldStatus = self?.permissions.notifications
                
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
                
                // Refresh available screens if permission status changed
                if oldStatus != self?.permissions.notifications {
                    self?.refreshAvailableScreens()
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
            notes: nil,
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
        AnalyticsService.shared.track(.patient(.created))
        return patient
    }
    
    // MARK: - Completion
    @MainActor
    func completeOnboarding() {
        isCompleted = true

        // Store onboarding completion in UserDefaults
        UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")

        // Track onboarding completion
        AnalyticsService.shared.track(.app(.featureUsed))

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

    func validatePatientName() -> Bool {
        let trimmedName = patientSetupData.name.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedName.isEmpty else { return false }
        guard trimmedName.count >= 2 else { return false }
        guard trimmedName.count <= 100 else { return false }

        // Check for valid characters (letters, spaces, common name characters)
        let validNameCharacters = CharacterSet.letters
            .union(.whitespaces)
            .union(CharacterSet(charactersIn: "'-.,"))

        guard trimmedName.unicodeScalars.allSatisfy(validNameCharacters.contains) else { return false }

        // Check for at least one letter
        guard trimmedName.contains(where: { $0.isLetter }) else { return false }

        return true
    }

    func validatePatientDateOfBirth() -> Bool {
        guard let date = patientSetupData.dateOfBirth else { return false }

        let calendar = Calendar.current
        let now = Date()
        let minimumAge = calendar.date(byAdding: .year, value: -150, to: now) ?? now
        let maximumAge = calendar.date(byAdding: .year, value: -1, to: now) ?? now

        // Check if date is in the future
        guard date <= now else { return false }

        // Check for reasonable age limits
        guard date >= minimumAge else { return false }
        guard date <= maximumAge else { return false }

        return true
    }
}

// MARK: - Notification Names
extension Notification.Name {
    static let onboardingCompleted = Notification.Name("onboardingCompleted")
}
