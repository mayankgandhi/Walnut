//
//  AppearanceViewModel.swift
//  Walnut
//
//  Created by Claude Code on 10/09/25.
//  Copyright © 2025 m. All rights reserved.
//

import SwiftUI
import SwiftData
import Observation

@Observable
class AppearanceViewModel {
    
    // MARK: - Published Properties
    var showAppearanceSettings = false
    
    // MARK: - Private Properties
    private let patient: Patient
    
    // MARK: - Initializer
    init(patient: Patient) {
        self.patient = patient
    }
    
    // MARK: - Public Properties
    var menuItem: SettingsMenuItem {
        SettingsMenuItem(
            icon: "paintbrush.fill",
            title: "Appearance",
            subtitle: "Theme and display options",
            iconColor: .purple,
            action: { [weak self] in
                self?.presentAppearanceSettings()
            }
        )
    }
    
    // MARK: - Actions
    func presentAppearanceSettings() {
        showAppearanceSettings = true
        // TODO: Implement appearance settings navigation
    }
    
    func dismissAppearanceSettings() {
        showAppearanceSettings = false
    }
}