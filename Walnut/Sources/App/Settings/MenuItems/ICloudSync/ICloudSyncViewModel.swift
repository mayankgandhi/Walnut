//
//  ICloudSyncViewModel.swift
//  Walnut
//
//  Created by Claude Code on 10/09/25.
//  Copyright © 2025 m. All rights reserved.
//

import SwiftUI
import SwiftData
import Observation

@Observable
class ICloudSyncViewModel {
    
    // MARK: - Published Properties
    var showICloudSync = false
    
    // MARK: - Private Properties
    private let patient: Patient
    
    // MARK: - Initializer
    init(patient: Patient) {
        self.patient = patient
    }
    
    // MARK: - Public Properties
    var menuItem: SettingsMenuItem {
        SettingsMenuItem(
            icon: "icloud.fill",
            title: "iCloud Sync",
            subtitle: "Keep data synchronized across devices",
            iconColor: .blue,
            action: { [weak self] in
                self?.presentICloudSync()
            }
        )
    }
    
    // MARK: - Actions
    func presentICloudSync() {
        showICloudSync = true
    }
    
    func dismissICloudSync() {
        showICloudSync = false
    }
}