//
//  PaywallData.swift
//  Walnut
//
//  Created by Mayank Gandhi on 19/09/25.
//  Copyright © 2025 m. All rights reserved.
//

import RevenueCat
import Foundation

struct PaywallData {
    let offering: Offering
    let localization: Localization

    struct Localization {
        let title: String
        let subtitle: String
        let callToAction: String
    }
}

struct PaywallConfiguration {
    let title: String
    let subtitle: String
    let features: [PaywallFeature]
    let packages: [Package]
    let termsURL: URL?
    let privacyURL: URL?
}

struct PaywallFeature {
    let title: String
    let description: String
    let icon: String
}
