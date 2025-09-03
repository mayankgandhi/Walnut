//
//  HealthCardHeader.swift
//  WalnutDesignSystem
//
//  Created by Mayank Gandhi on 22/08/25.
//  Copyright © 2025 m. All rights reserved.
//

import SwiftUI

public struct HealthCardHeader: View {
    
    // MARK: - Properties
    
    private let icon: String?
    private let iconName: String?
    private let iconColor: Color
    private let iconSize: CGFloat
    private let iconBackgroundSize: CGFloat
    private let title: String
    private let subtitle: String?
    private let actionIcon: String?
    private let actionColor: Color
    private let onActionTap: (() -> Void)?
    
    
    // MARK: - Initialization
    
    public init(
        icon: String? = nil,
        iconName: String? = nil,
        iconColor: Color = .healthPrimary,
        iconSize: CGFloat = 16,
        iconBackgroundSize: CGFloat = 36,
        title: String,
        subtitle: String? = nil,
        actionIcon: String? = nil,
        actionColor: Color = .healthPrimary,
        onActionTap: (() -> Void)? = nil
    ) {
        self.icon = icon
        self.iconName = iconName
        self.iconColor = iconColor
        self.iconSize = iconSize
        self.iconBackgroundSize = iconBackgroundSize
        self.title = title
        self.subtitle = subtitle
        self.actionIcon = actionIcon
        self.actionColor = actionColor
        self.onActionTap = onActionTap
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
            
            // Action button (optional)
            if let actionIcon = actionIcon, let onActionTap = onActionTap {
                actionButton(actionIcon, action: onActionTap)
            }
        }
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
                .font(.title3.weight(.bold))
                .foregroundStyle(.primary)
            
            if let subtitle = subtitle {
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
    
    @ViewBuilder
    private func actionButton(_ iconName: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: iconName)
                .font(.title)
                .foregroundStyle(actionColor)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Convenience Extensions

public extension HealthCardHeader {
    
    /// Standard medical documents header
    static func medicalDocuments(
        count: Int,
    ) -> HealthCardHeader {
        HealthCardHeader(
            iconName: "health-journal",
            title: "Medical Documents",
            subtitle: "\(count) documents",
        )
    }
    
    /// Standard timeline header
    static func timeline(
        title: String = "Timeline",
        icon: String = "clock.arrow.circlepath"
    ) -> HealthCardHeader {
        HealthCardHeader(
            icon: icon,
            title: title
        )
    }
    
    /// Standard clinical notes header
    static func clinicalNotes(
        characterCount: Int? = nil
    ) -> HealthCardHeader {
        let subtitle = characterCount.map { "\($0) characters" }
        
        return HealthCardHeader(
            icon: "note.text",
            iconColor: .healthSuccess,
            title: "Clinical Notes",
            subtitle: subtitle
        )
    }
    /// Custom header with flexible parameters
    static func custom(
        icon: String?,
        iconColor: Color = .healthPrimary,
        title: String,
        subtitle: String? = nil,
        actionIcon: String? = nil,
        actionColor: Color = .healthPrimary,
        onActionTap: (() -> Void)? = nil
    ) -> HealthCardHeader {
        HealthCardHeader(
            icon: icon,
            iconColor: iconColor,
            title: title,
            subtitle: subtitle,
            actionIcon: actionIcon,
            actionColor: actionColor,
            onActionTap: onActionTap
        )
    }
}

// MARK: - Preview

#Preview("Standard Headers") {
    ScrollView {
        VStack(spacing: Spacing.xl) {
            
            // Minimal header (title only)
            HealthCardHeader(
                iconName: "pills",
                title: "Patient Summary"
            )
            
            HealthCardHeader.medicalDocuments(
                count: 12,
            )
            
            // Timeline Header
            HealthCardHeader.timeline()
        }
    }
}


#Preview("Custom Headers") {
    ScrollView {
        VStack(spacing: Spacing.large) {
            HealthCard {
                VStack(spacing: Spacing.large) {
                    // Custom header with all options
                    HealthCardHeader.custom(
                        icon: "heart.text.square.fill",
                        iconColor: .healthError,
                        title: "Vitals Monitoring",
                        subtitle: "3 measurements today",
                        actionIcon: "chart.line.uptrend.xyaxis",
                        actionColor: .healthError,
                        onActionTap: {
                            print("View chart tapped")
                        }
                    )
                    
                    
                    
                   
                    
                    
                    
                    // Header with subtitle but no action
                    HealthCardHeader.custom(
                        icon: "person.text.rectangle",
                        iconColor: .healthSuccess,
                        title: "Patient Information",
                        subtitle: "Last updated 2 hours ago"
                    )
                }
            }
        }
    }
}
