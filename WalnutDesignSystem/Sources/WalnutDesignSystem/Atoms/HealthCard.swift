//
//  HealthCard.swift
//  WalnutDesignSystem
//
//  Created by Mayank Gandhi on 06/08/25.
//  Copyright © 2025 m. All rights reserved.
//

import SwiftUI

/// Simple healthcare card with native materials and glass effect
public struct HealthCard<Content: View>: View {
    private let content: Content
    private let padding: CGFloat
    private let enableGlassEffect: Bool
    
    public init(
        enableGlassEffect: Bool = true,
        @ViewBuilder content: () -> Content
    ) {
        self.content = content()
        self.padding = Spacing.medium
        self.enableGlassEffect = enableGlassEffect
    }
    
    public var body: some View {
        content
            .padding(padding)
            .healthCardStyle(enableGlassEffect: enableGlassEffect)
    }
}


// MARK: - Preview

#Preview("Health Cards") {
    ScrollView {
        VStack(spacing: Spacing.large) {
            // Glass effect enabled (default)
            HealthCard {
                VStack(alignment: .leading, spacing: Spacing.small) {
                    HStack {
                        PatientAvatar(name: "JD")
                        
                        VStack(alignment: .leading) {
                            Text("John Doe")
                                .font(.headline)
                            Text("35 years old")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
        }
    }
}
