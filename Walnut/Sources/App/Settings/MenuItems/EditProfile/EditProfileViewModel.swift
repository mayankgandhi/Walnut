//
//  EditProfileViewModel.swift
//  Walnut
//
//  Created by Claude Code on 10/09/25.
//  Copyright © 2025 m. All rights reserved.
//

import SwiftUI
import SwiftData
import Observation

@Observable
class EditProfileViewModel {
    
    // MARK: - Published Properties
    var showEditPatient = false
    
    // MARK: - Private Properties
    private let patient: Patient
    
    // MARK: - Initializer
    init(patient: Patient) {
        self.patient = patient
    }
    
    // MARK: - Public Properties
    var menuItem: SettingsMenuItem {
        SettingsMenuItem(
            icon: "pencil.circle.fill",
            title: "Edit Profile",
            subtitle: "Update patient information",
            iconColor: .healthPrimary,
            action: { [weak self] in
                self?.presentEditSheet()
            }
        )
    }
    
    // MARK: - Actions
    func presentEditSheet() {
        showEditPatient = true
    }
    
    func dismissEditSheet() {
        showEditPatient = false
    }
}