//
//  AlarmSettingsViewModel.swift
//  Walnut
//
//  Created by Claude Code on 10/09/25.
//  Copyright © 2025 m. All rights reserved.
//

import SwiftUI
import SwiftData
import Observation
import AlarmKit

@Observable
class AlarmSettingsViewModel {
    
    // MARK: - Published Properties
    var showAlarmSettings = false
    var showPermissionAlert = false
    var isLoading = false
    var errorMessage: String?
    var showErrorAlert = false
    
    // MARK: - Private Properties
    private let patient: Patient
    private let alarmService = MedicationAlarmService()
    
    // MARK: - Initializer
    init(patient: Patient) {
        self.patient = patient
    }
    
    // MARK: - Public Properties
    var menuItem: SettingsMenuItem {
        SettingsMenuItem(
            icon: "alarm.fill",
            title: "Medication Alarms",
            subtitle: subtitleText,
            iconColor: isAuthorized ? .orange : .secondary,
            action: { [weak self] in
                self?.presentAlarmSettings()
            }
        )
    }
    
    // MARK: - Computed Properties
    
    var isAuthorized: Bool {
        alarmService.isAuthorized
    }
    
    var authorizationState: AlarmManager.AuthorizationState {
        alarmService.authorizationState
    }
    
    var activeAlarmCount: Int {
        alarmService.alarmCount
    }
    
    private var subtitleText: String {
        switch authorizationState {
        case .authorized:
            let count = activeAlarmCount
            return count == 0 ? "No active alarms" : "\(count) active alarm\(count == 1 ? "" : "s")"
        case .denied:
            return "Permission required"
        case .notDetermined:
            return "Tap to enable alarms"
        @unknown default:
            return "Check settings"
        }
    }
    
    // MARK: - Actions
    func presentAlarmSettings() {
        if isAuthorized {
            showAlarmSettings = true
        } else {
            requestPermission()
        }
    }
    
    func dismissAlarmSettings() {
        showAlarmSettings = false
    }
    
    func requestPermission() {
        isLoading = true
        
        Task {
            let result = await alarmService.requestAuthorization()
            
            await MainActor.run {
                isLoading = false
                
                switch result {
                case .success(let granted):
                    if granted {
                        showAlarmSettings = true
                    } else {
                        showPermissionAlert = true
                    }
                case .failure(let error):
                    errorMessage = error.localizedDescription
                    showErrorAlert = true
                }
            }
        }
    }
    
    func dismissPermissionAlert() {
        showPermissionAlert = false
    }
    
    func dismissError() {
        errorMessage = nil
        showErrorAlert = false
    }
    
    func openSystemSettings() {
        if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(settingsURL)
        }
    }
    
    // MARK: - Medication Alarm Management
    
    func createAlarmForMedication(medication: Medication, times: [Date]) async {
        guard let medicationName = medication.name,
              let medicationID = medication.id else { return }
        
        isLoading = true
        
        let result = await alarmService.createRecurringMedicationAlarms(
            medicationID: medicationID,
            medicationName: medicationName,
            dosage: medication.dosage,
            times: times
        )
        
        await MainActor.run {
            isLoading = false
            
            switch result {
            case .success:
                // Success - alarms created
                break
            case .failure(let error):
                errorMessage = error.localizedDescription
                showErrorAlert = true
            }
        }
    }
    
    func cancelAllAlarms() async {
        isLoading = true
        
        let result = await alarmService.cancelAllAlarms()
        
        await MainActor.run {
            isLoading = false
            
            switch result {
            case .success:
                // Success - all alarms cancelled
                break
            case .failure(let error):
                errorMessage = error.localizedDescription
                showErrorAlert = true
            }
        }
    }
}
