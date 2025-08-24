//
//  HealthCard.swift
//  WalnutDesignSystem
//
//  Created by Mayank Gandhi on 06/08/25.
//  Copyright © 2025 m. All rights reserved.
//

import SwiftUI

/// Simple healthcare card with native materials
public struct HealthCard<Content: View>: View {
    private let content: Content
    private let padding: CGFloat
    
    public init(
        @ViewBuilder content: () -> Content
    ) {
        self.content = content()
        self.padding = Spacing.medium
    }
    
    public var body: some View {
        content
            .padding(padding)
            .subtleCardStyle()
    }
}

/// Patient avatar component
public struct PatientAvatar: View {
    private let initials: String
    private let color: Color
    private let size: CGFloat
    
    public init(
        initials: String,
        color: Color = .healthPrimary,
        size: CGFloat = Size.avatarMedium
    ) {
        self.initials = initials
        self.color = color
        self.size = size
    }
    
    public var body: some View {
        Circle()
            .fill(color.opacity(0.2))
            .overlay(
                Text(initials)
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(color)
            )
            .frame(width: size, height: size)
    }
}

// MARK: - Preview

#Preview("Health Cards") {
    ScrollView {
        VStack(spacing: Spacing.large) {
            HealthCard {
                VStack(alignment: .leading, spacing: Spacing.small) {
                    HStack {
                        PatientAvatar(initials: "JD")
                        
                        VStack(alignment: .leading) {
                            Text("John Doe")
                                .font(.headline)
                            Text("35 years old")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        
                        Spacer()
                        
                        StatusIndicator(status: .good)
                    }
                    
                    Divider()
                    
                    HealthMetric(
                        value: "120/80",
                        unit: "mmHg",
                        label: "Blood Pressure"
                    )
                }
            }
            
            
        }
        .padding(Spacing.large)
    }
}
