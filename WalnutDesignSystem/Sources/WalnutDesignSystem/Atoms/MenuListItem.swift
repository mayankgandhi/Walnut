//
//  MenuListItem.swift
//  WalnutDesignSystem
//
//  Created by Mayank Gandhi on 06/08/25.
//  Copyright © 2025 m. All rights reserved.
//

import SwiftUI

/// Menu list item (matching the right panel design)
public struct MenuListItem: View {
    private let icon: String
    private let title: String
    private let iconColor: Color
    private let hasChevron: Bool
    private let action: () -> Void
    
    public init(
        icon: String,
        title: String,
        iconColor: Color = .healthPrimary,
        hasChevron: Bool = true,
        action: @escaping () -> Void = {}
    ) {
        self.icon = icon
        self.title = title
        self.iconColor = iconColor
        self.hasChevron = hasChevron
        self.action = action
    }
    
    public var body: some View {
        Button(action: action) {
            HStack(spacing: Spacing.medium) {
                // Icon with colored background
                Circle()
                    .fill(iconColor.opacity(0.15))
                    .frame(width: 32, height: 32)
                    .overlay(
                        Image(systemName: icon)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundStyle(iconColor)
                    )
                
                Text(title)
                    .font(.body)
                    .foregroundStyle(.primary)
                
                Spacer()
                
                if hasChevron {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(.tertiary)
                }
            }
            .padding(.vertical, Spacing.small)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

/// Profile header (matching the Jason Bean design)
public struct ProfileHeader: View {
    private let name: String
    private let subtitle: String
    private let imageName: String?
    
    public init(name: String, subtitle: String, imageName: String? = nil) {
        self.name = name
        self.subtitle = subtitle
        self.imageName = imageName
    }
    
    public var body: some View {
        HStack(spacing: Spacing.medium) {
            // Profile image or avatar
            if let imageName = imageName {
                AsyncImage(url: URL(string: imageName)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    PatientAvatar(initials: String(name.prefix(2)))
                }
                .frame(width: Size.avatarLarge, height: Size.avatarLarge)
                .clipShape(Circle())
            } else {
                PatientAvatar(
                    initials: String(name.prefix(2)),
                    size: Size.avatarLarge
                )
            }
            
            VStack(alignment: .leading, spacing: Spacing.xs) {
                Text(name)
                    .font(.title2.weight(.semibold))
                    .foregroundStyle(.primary)
                
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            Button(action: {}) {
                Image(systemName: "bell")
                    .font(.title3)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

/// Knowledge base card (matching the "Got a question?" design)
public struct KnowledgeCard: View {
    private let title: String
    private let subtitle: String
    private let imageName: String
    private let backgroundColor: Color
    
    public init(
        title: String,
        subtitle: String,
        imageName: String = "person.crop.circle.fill.badge.questionmark",
        backgroundColor: Color = .healthPrimary
    ) {
        self.title = title
        self.subtitle = subtitle
        self.imageName = imageName
        self.backgroundColor = backgroundColor
    }
    
    public var body: some View {
        HStack(spacing: Spacing.medium) {
            VStack(alignment: .leading, spacing: Spacing.xs) {
                Text(title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.white)
                
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.8))
            }
            
            Spacer()
            
            Image(systemName: imageName)
                .font(.system(size: 32))
                .foregroundStyle(.white.opacity(0.8))
        }
        .padding(Spacing.medium)
        .background(backgroundColor, in: RoundedRectangle(cornerRadius: 12))
    }
}

/// Water intake widget (matching the water chart design)
public struct WaterIntakeWidget: View {
    private let current: String
    private let unit: String
    private let data: [Double]
    
    public init(current: String, unit: String, data: [Double]) {
        self.current = current
        self.unit = unit
        self.data = data
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: Spacing.medium) {
            HStack {
                Text("Water")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.primary)
                
                Spacer()
            }
            
            // Value
            VStack(alignment: .leading, spacing: Spacing.xs) {
                Text(current)
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundStyle(.primary)
                
                Text(unit)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            // Simple bar chart representation
            HStack(alignment: .bottom, spacing: 4) {
                ForEach(Array(data.enumerated()), id: \.offset) { index, value in
                    RoundedRectangle(cornerRadius: 2)
                        .fill(.cyan.opacity(0.7))
                        .frame(width: 8, height: max(4, value * 40))
                }
            }
            .frame(height: 50)
        }
        .padding(Spacing.medium)
        .background(.cyan.opacity(0.1), in: RoundedRectangle(cornerRadius: 12))
    }
}