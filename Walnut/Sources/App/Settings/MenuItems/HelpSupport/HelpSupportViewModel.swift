//
//  HelpSupportViewModel.swift
//  Walnut
//
//  Created by Claude Code on 10/09/25.
//  Copyright © 2025 m. All rights reserved.
//

import SwiftUI
import SwiftData
import Observation

@Observable
class HelpSupportViewModel {
    
    // MARK: - Published Properties
    var showHelpSupport = false
    
    // MARK: - Private Properties
    private let patient: Patient
    
    // MARK: - Initializer
    init(patient: Patient) {
        self.patient = patient
    }
    
    // MARK: - Public Properties
    var menuItem: SettingsMenuItem {
        SettingsMenuItem(
            icon: "questionmark.circle.fill",
            title: "Help & Support",
            subtitle: "Get help and contact support",
            iconColor: .healthPrimary,
            action: { [weak self] in
                self?.presentHelpSupport()
            }
        )
    }
    
    // MARK: - Actions
    func presentHelpSupport() {
        showHelpSupport = true
        // TODO: Implement help and support navigation
    }
    
    func dismissHelpSupport() {
        showHelpSupport = false
    }
}