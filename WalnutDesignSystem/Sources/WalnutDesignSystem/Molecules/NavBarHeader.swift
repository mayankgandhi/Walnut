//
//  NavBarHeader.swift
//  WalnutDesignSystem
//
//  Created by Mayank Gandhi on 12/09/25.
//  Copyright © 2025 m. All rights reserved.
//

import SwiftUI

public struct NavBarHeader: View {
    
    // MARK: - Properties
    
    private let icon: String?
    private let iconName: String?
    private let iconColor: Color
    private let iconSize: CGFloat
    private let iconBackgroundSize: CGFloat
    private let title: String
    private let subtitle: String?
    
    
    // MARK: - Initialization
    
    public init(
        icon: String? = nil,
        iconName: String? = nil,
        iconColor: Color = .healthPrimary,
        iconSize: CGFloat = 16,
        iconBackgroundSize: CGFloat = 48,
        title: String,
        subtitle: String? = nil,
    ) {
        self.icon = icon
        self.iconName = iconName
        self.iconColor = iconColor
        self.iconSize = iconSize
        self.iconBackgroundSize = iconBackgroundSize
        self.title = title
        self.subtitle = subtitle
    }
    
    // MARK: - Body
    
    public var body: some View {
        HStack(spacing: Spacing.medium) {
            // Dynamic icon with gradient background (optional)
            if let icon = icon {
                iconView(icon)
            }
            
            if let iconName = iconName {
                iconImageView(iconName)
            }
            
            // Title and subtitle content
            contentView
            
            Spacer()
            
        }
        .padding(.horizontal, Spacing.medium)
    }
    
    // MARK: - View Components
    
    @ViewBuilder
    private func iconView(_ iconName: String) -> some View {
        ZStack {
            Circle()
                .fill(
                    LinearGradient(
                        colors: [
                            iconColor.opacity(0.2),
                            iconColor.opacity(0.05)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: iconBackgroundSize, height: iconBackgroundSize)
                .shadow(color: iconColor.opacity(0.2), radius: 4, x: 0, y: 2)
            
            Image(systemName: iconName)
                .font(.system(size: iconSize, weight: .semibold))
                .foregroundStyle(iconColor)
        }
    }
    
    @ViewBuilder
    private func iconImageView(_ iconName: String) -> some View {
        ZStack {
            Circle()
                .fill(
                    LinearGradient(
                        colors: [
                            iconColor.opacity(0.2),
                            iconColor.opacity(0.05)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: iconBackgroundSize, height: iconBackgroundSize)
                .shadow(color: iconColor.opacity(0.2), radius: 4, x: 0, y: 2)
            
            Image(iconName)
                .resizable()
                .scaledToFit()
                .frame(width: iconBackgroundSize, height: iconBackgroundSize)
        }
    }
    
    private var contentView: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .font(.system(.title2, design: .default, weight: .bold))
                .foregroundStyle(.primary)
            
            if let subtitle = subtitle {
                Text(subtitle)
                    .font(.system(.headline, design: .default, weight: .medium))
                    .foregroundStyle(.secondary)
            }
        }
    }
    
}


#Preview("Standard Headers") {
    ScrollView {
        VStack(spacing: Spacing.xl) {
            
            // Minimal header (title only)
            NavBarHeader(
                iconName: "pill-bottle",
                title: "Patient Summary",
                subtitle: "Drugs woohoo"
            )
            
        }
    }
}

