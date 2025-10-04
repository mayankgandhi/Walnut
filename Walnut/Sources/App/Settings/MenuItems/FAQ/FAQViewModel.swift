//
//  FAQViewModel.swift
//  Walnut
//
//  Created by Claude Code on 10/04/25.
//  Copyright © 2025 m. All rights reserved.
//

import SwiftUI
import Observation

@Observable
class FAQViewModel {

    // MARK: - Published Properties
    var showFAQ = false

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
            title: "FAQ",
            subtitle: "Frequently asked questions",
            iconColor: .healthPrimary,
            action: { [weak self] in
                self?.presentFAQ()
            }
        )
    }

    var faqs: [FAQItem] {
        FAQItem.allFAQs
    }

    // MARK: - Actions
    func presentFAQ() {
        showFAQ = true
    }

    func dismissFAQ() {
        showFAQ = false
    }
}
