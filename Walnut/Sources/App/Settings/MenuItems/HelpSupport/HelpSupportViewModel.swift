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
import MessageUI

@Observable
class HelpSupportViewModel {

    // MARK: - Published Properties
    var showMailCompose = false

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
        if MFMailComposeViewController.canSendMail() {
            showMailCompose = true
        } else {
            // Fallback to mailto URL if mail is not configured
            if let url = URL(string: "mailto:healthstack@mayankgandhi.com") {
                UIApplication.shared.open(url)
            }
        }
    }

    func dismissMailCompose() {
        showMailCompose = false
    }
}