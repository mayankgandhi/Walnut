//
//  PrivacySecurityViewModel.swift
//  Walnut
//
//  Created by Claude Code on 10/09/25.
//  Copyright © 2025 m. All rights reserved.
//

import SwiftUI
import SwiftData
import Observation

@Observable
class PrivacySecurityViewModel {
    
    // MARK: - Published Properties
    var showPrivacySettings = false
    
    // MARK: - Private Properties
    private let patient: Patient
    
    // MARK: - Initializer
    init(patient: Patient) {
        self.patient = patient
    }
    
    // MARK: - Public Properties
    var menuItem: SettingsMenuItem {
        SettingsMenuItem(
            icon: "shield.fill",
            title: "Privacy & Security",
            subtitle: "Data protection settings",
            iconColor: .green,
            action: { [weak self] in
                self?.presentPrivacySettings()
            }
        )
    }
    
    // MARK: - Actions
    func presentPrivacySettings() {
        showPrivacySettings = true
        // TODO: Implement privacy settings navigation
    }
    
    func dismissPrivacySettings() {
        showPrivacySettings = false
    }
}