//
//  MenuListItem.swift
//  WalnutDesignSystem
//
//  Created by Mayank Gandhi on 06/08/25.
//  Copyright © 2025 m. All rights reserved.
//

import SwiftUI

/// Rich, modern menu list item with enhanced visual design
public struct MenuListItem: View {
    private let icon: String
    private let title: String
    private let subtitle: String?
    private let iconColor: Color
    private let hasChevron: Bool
    private let badge: Int?
    private let action: () -> Void
    
    @State private var isPressed = false
    
    public init(
        icon: String,
        title: String,
        subtitle: String? = nil,
        iconColor: Color = .healthPrimary,
        hasChevron: Bool = true,
        badge: Int? = nil,
        action: @escaping () -> Void = {}
    ) {
        self.icon = icon
        self.title = title
        self.subtitle = subtitle
        self.iconColor = iconColor
        self.hasChevron = hasChevron
        self.badge = badge
        self.action = action
    }
    
    public var body: some View {
        Button(action: action) {
            HStack(spacing: Spacing.medium) {
                // Enhanced icon with gradient background
                iconView
                
                // Content section
                VStack(alignment: .leading, spacing: 2) {
                    HStack(alignment: .center, spacing: Spacing.xs) {
                        Text(title)
                            .font(.system(.body, design: .rounded, weight: .medium))
                            .foregroundStyle(.primary)
                        
                        if let badge = badge {
                            badgeView(count: badge)
                        }
                        
                        Spacer()
                    }
                    
                    if let subtitle = subtitle {
                        Text(subtitle)
                            .font(.system(.caption, design: .rounded))
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                    }
                }
                
                // Chevron with enhanced styling
                if hasChevron {
                    chevronView
                }
            }
            .padding(.horizontal, Spacing.medium)
            .padding(.vertical, Spacing.small + 2)
            .background(backgroundView)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.clear, lineWidth: 1)
            )
            .scaleEffect(isPressed ? 0.98 : 1.0)
            .contentShape(.rect)
            .animation(.easeInOut(duration: 0.1), value: isPressed)
            .shadow(
                color:  Color.black.opacity(0.05),
                radius:  2,
                x: 0,
                y:  1
            )
        }
        .buttonStyle(.plain)
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, perform: {}, onPressingChanged: { pressing in
            isPressed = pressing
        })
    }
    
    private var iconView: some View {
        ZStack {
            // Gradient background
            Circle()
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            iconColor.opacity(0.1),
                            iconColor.opacity(0.2)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 44, height: 44)
            
            // Subtle ring
            Circle()
                .stroke(iconColor.opacity(0.15), lineWidth: 1)
                .frame(width: 44, height: 44)
            
            // Icon
            Image(systemName: icon)
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            iconColor,
                            iconColor.opacity(0.8)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        }
    }
    
    private var backgroundView: some View {
        Group {
           
                RoundedRectangle(cornerRadius: 12)
                    .fill(isPressed ? Color(.systemGray6) : .clear)
        }
    }
    
    private var chevronView: some View {
        Image(systemName: "chevron.right")
            .font(.system(size: 12, weight: .semibold))
            .foregroundStyle(.tertiary)
            .scaleEffect(isPressed ? 1.1 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: isPressed)
    }
    
    private func badgeView(count: Int) -> some View {
        Text("\(count)")
            .font(.system(.caption2, design: .rounded, weight: .bold))
            .foregroundStyle(.white)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(
                Capsule()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [.red, .red.opacity(0.8)]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            )
            .shadow(color: .red.opacity(0.3), radius: 2, x: 0, y: 1)
    }
}


#Preview("Standard Menu Items") {
    ScrollView {
        VStack(spacing: Spacing.xs) {
            MenuListItem(
                icon: "book.fill",
                title: "Diary",
                subtitle: "Track your daily health entries",
                iconColor: .healthPrimary,
                badge: 3
            )
            
            MenuListItem(
                icon: "leaf.fill",
                title: "Nutrition",
                subtitle: "Manage your meal plans",
                iconColor: .green
            )
            
            MenuListItem(
                icon: "chart.line.uptrend.xyaxis",
                title: "Monitoring",
                subtitle: "View health trends and analytics",
                iconColor: .blue
            )
            
            MenuListItem(
                icon: "questionmark.circle.fill",
                title: "Knowledge Base",
                subtitle: "Get answers to health questions",
                iconColor: .healthPrimary
            )
            
            MenuListItem(
                icon: "bell.fill",
                title: "Alarms & Reminders",
                subtitle: "Medication and appointment alerts",
                iconColor: .orange,
                badge: 12
            )
            
            MenuListItem(
                icon: "heart.text.square",
                title: "Biomarkers",
                subtitle: "Lab results and health metrics",
                iconColor: .heartRate
            )
            
            MenuListItem(
                icon: "pills.fill",
                title: "Medications",
                subtitle: "Prescription management",
                iconColor: .medication,
                badge: 1
            )
            
            MenuListItem(
                icon: "gearshape.fill",
                title: "Settings",
                subtitle: "App preferences and account",
                iconColor: .gray
            )
            
            MenuListItem(
                icon: "rectangle.portrait.and.arrow.right",
                title: "Log Out",
                iconColor: .red,
                hasChevron: false
            )
        }
        .padding(.horizontal)
    }
}

#Preview("Different States") {
    VStack(spacing: Spacing.medium) {
        Text("Menu Item States")
            .font(.title2)
            .fontWeight(.bold)
            .padding(.horizontal)
        
        VStack(spacing: Spacing.xs) {
            MenuListItem(
                icon: "heart.fill",
                title: "Normal State",
                subtitle: "Regular menu item",
                iconColor: .healthPrimary
            )
            
            MenuListItem(
                icon: "star.fill",
                title: "Selected State",
                subtitle: "Currently active item",
                iconColor: .orange
            )
            
            MenuListItem(
                icon: "bell.fill",
                title: "With Badge",
                subtitle: "Has notification count",
                iconColor: .blue,
                badge: 99
            )
            
            MenuListItem(
                icon: "trash.fill",
                title: "No Chevron",
                subtitle: "Action item without navigation",
                iconColor: .red,
                hasChevron: false
            )
            
            MenuListItem(
                icon: "sparkles",
                title: "Just Title",
                iconColor: .purple
            )
        }
        .padding(.horizontal)
        
        Spacer()
    }
}
