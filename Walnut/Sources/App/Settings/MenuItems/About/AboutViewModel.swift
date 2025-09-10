//
//  AboutViewModel.swift
//  Walnut
//
//  Created by Claude Code on 10/09/25.
//  Copyright © 2025 m. All rights reserved.
//

import SwiftUI
import SwiftData
import Observation

@Observable
class AboutViewModel {
    
    // MARK: - Published Properties
    var showAboutSheet = false
    
    // MARK: - Private Properties
    private let patient: Patient
    
    // MARK: - Initializer
    init(patient: Patient) {
        self.patient = patient
    }
    
    // MARK: - Public Properties
    var menuItem: SettingsMenuItem {
        SettingsMenuItem(
            icon: "info.circle.fill",
            title: "About",
            subtitle: "App version and info",
            iconColor: .gray,
            action: { [weak self] in
                self?.presentAboutSheet()
            }
        )
    }
    
    // MARK: - Actions
    func presentAboutSheet() {
        showAboutSheet = true
    }
    
    func dismissAboutSheet() {
        showAboutSheet = false
    }
}