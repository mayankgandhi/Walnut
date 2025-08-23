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
    private let iconColor: Color
    private let iconSize: CGFloat
    private let iconBackgroundSize: CGFloat
    private let title: String
    private let subtitle: String?
    private let actionIcon: String?
    private let actionColor: Color
    private let onActionTap: (() -> Void)?
    private let isActionPressed: Bool
    
    // MARK: - Initialization
    
    public init(
        icon: String? = nil,
        iconColor: Color = .healthPrimary,
        iconSize: CGFloat = 18,
        iconBackgroundSize: CGFloat = 48,
        title: String,
        subtitle: String? = nil,
        actionIcon: String? = nil,
        actionColor: Color = .healthPrimary,
        isActionPressed: Bool = false,
        onActionTap: (() -> Void)? = nil
    ) {
        self.icon = icon
        self.iconColor = iconColor
        self.iconSize = iconSize
        self.iconBackgroundSize = iconBackgroundSize
        self.title = title
        self.subtitle = subtitle
        self.actionIcon = actionIcon
        self.actionColor = actionColor
        self.isActionPressed = isActionPressed
        self.onActionTap = onActionTap
    }
    
    // MARK: - Body
    
    public var body: some View {
        HStack(spacing: Spacing.medium) {
            // Dynamic icon with gradient background (optional)
            if let icon = icon {
                iconView(icon)
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
        Image(systemName: iconName)
            .font(.system(size: iconSize, weight: .semibold))
            .foregroundStyle(iconColor)
            .background {
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
            }
    }
    
    private var contentView: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .font(.headline.weight(.bold))
                .foregroundStyle(.primary)
            
            if let subtitle = subtitle {
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
    }
    
    @ViewBuilder
    private func actionButton(_ iconName: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: iconName)
                .font(.title2)
                .foregroundStyle(actionColor)
                .scaleEffect(isActionPressed ? 0.9 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Convenience Extensions

public extension HealthCardHeader {
    
    /// Standard medical documents header
    static func medicalDocuments(
        count: Int,
        isAddPressed: Bool = false,
        onAddTap: @escaping () -> Void
    ) -> HealthCardHeader {
        HealthCardHeader(
            icon: "folder.fill.badge.plus",
            title: "Medical Documents",
            subtitle: "\(count) documents",
            actionIcon: "plus.circle.fill",
            isActionPressed: isAddPressed,
            onActionTap: onAddTap
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
    
    /// Standard prescriptions header
    static func prescriptions(
        count: Int,
        abnormalCount: Int? = nil,
        isAddPressed: Bool = false,
        onAddTap: @escaping () -> Void
    ) -> HealthCardHeader {
        var subtitle = "\(count) documents"
        
        if let abnormalCount = abnormalCount, abnormalCount > 0 {
            subtitle += " • \(abnormalCount) need attention"
        }
        
        return HealthCardHeader(
            icon: "doc.text.fill",
            title: "Prescriptions",
            subtitle: subtitle,
            actionIcon: "plus.circle.fill",
            isActionPressed: isAddPressed,
            onActionTap: onAddTap
        )
    }
    
    /// Standard blood reports header
    static func bloodReports(
        count: Int,
        abnormalCount: Int? = nil,
        isAddPressed: Bool = false,
        onAddTap: @escaping () -> Void
    ) -> HealthCardHeader {
        var subtitle = "\(count) reports"
        
        if let abnormalCount = abnormalCount, abnormalCount > 0 {
            subtitle += " • \(abnormalCount) abnormal"
        }
        
        return HealthCardHeader(
            icon: "testtube.2",
            iconColor: .healthError,
            title: "Blood Reports",
            subtitle: subtitle,
            actionIcon: "plus.circle.fill",
            actionColor: .healthError,
            isActionPressed: isAddPressed,
            onActionTap: onAddTap
        )
    }
    
    /// Standard failed documents header
    static func failedDocuments(
        count: Int,
        onAddTap: (() -> Void)? = nil
    ) -> HealthCardHeader {
        HealthCardHeader(
            icon: "exclamationmark.triangle.fill",
            iconColor: .orange,
            title: "Failed Documents",
            subtitle: "\(count) documents need attention",
            actionIcon: onAddTap != nil ? "plus.circle.fill" : nil,
            actionColor: .orange,
            onActionTap: onAddTap
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
        isActionPressed: Bool = false,
        onActionTap: (() -> Void)? = nil
    ) -> HealthCardHeader {
        HealthCardHeader(
            icon: icon,
            iconColor: iconColor,
            title: title,
            subtitle: subtitle,
            actionIcon: actionIcon,
            actionColor: actionColor,
            isActionPressed: isActionPressed,
            onActionTap: onActionTap
        )
    }
}

// MARK: - Preview

#Preview("Standard Headers") {
    ScrollView {
        VStack(spacing: Spacing.large) {
            HealthCard {
                VStack(spacing: Spacing.large) {
                    // Medical Documents Header
                    HealthCardHeader.medicalDocuments(
                        count: 12,
                        onAddTap: {
                            print("Add document tapped")
                        }
                    )
                    
                    Divider()
                    
                    // Timeline Header
                    HealthCardHeader.timeline()
                    
                    Divider()
                    
                    // Clinical Notes Header
                    HealthCardHeader.clinicalNotes(characterCount: 245)
                    
                    Divider()
                    
                    // Prescriptions Header
                    HealthCardHeader.prescriptions(
                        count: 8,
                        onAddTap: {
                            print("Add prescription tapped")
                        }
                    )
                    
                    Divider()
                    
                    // Blood Reports Header
                    HealthCardHeader.bloodReports(
                        count: 5,
                        abnormalCount: 2,
                        onAddTap: {
                            print("Add blood report tapped")
                        }
                    )
                    
                    Divider()
                    
                    // Failed Documents Header
                    HealthCardHeader.failedDocuments(count: 3)
                }
            }
        }
        .padding()
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
                    
                    Divider()
                    
                    // Minimal header (title only)
                    HealthCardHeader.custom(
                        icon: nil,
                        title: "Patient Summary"
                    )
                    
                    Divider()
                    
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
        .padding()
    }
}

#Preview("Interactive States") {
    struct InteractivePreview: View {
        @State private var isPressed = false
        
        var body: some View {
            HealthCard {
                HealthCardHeader.medicalDocuments(
                    count: 5,
                    isAddPressed: isPressed,
                    onAddTap: {
                        withAnimation(.easeInOut(duration: 0.1)) {
                            isPressed = true
                        }
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            withAnimation(.easeInOut(duration: 0.1)) {
                                isPressed = false
                            }
                        }
                    }
                )
            }
            .padding()
        }
    }
    
    return InteractivePreview()
}