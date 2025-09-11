//
//  OnboardingHeader.swift
//  Walnut
//
//  Created by Mayank Gandhi on 11/09/25.
//  Copyright © 2025 m. All rights reserved.
//

import SwiftUI
import WalnutDesignSystem

struct OnboardingHeader: View {

    let icon: String
    let title: String
    let subtitle: String
    
    var body: some View {
        // Header
        HStack(alignment: .center, spacing: Spacing.medium) {
        
            Image(systemName: icon)
                .font(.system(size: 50))
                .foregroundStyle(Color.healthPrimary)
                
            VStack(alignment: .leading, spacing: Spacing.small) {
                
                Text(title)
                    .font(.system(.title3, design: .rounded, weight: .medium))
                
                Text(subtitle)
                    .font(.system(.headline, design: .rounded, weight: .medium))
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.leading)
            }
        }
    }
}

#Preview {
    OnboardingHeader(icon: "heart.circle.fill", title: "Health Profile", subtitle: "Tell us about your health conditions and emergency contacts")
}
