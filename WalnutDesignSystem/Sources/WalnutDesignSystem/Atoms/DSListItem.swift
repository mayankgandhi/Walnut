//
//  DSListItem.swift
//  WalnutDesignSystem
//
//  Created by Mayank Gandhi on 06/08/25.
//  Copyright © 2025 m. All rights reserved.
//

import SwiftUI

/// Nutrition list item (matching the left screen nutrition items)
public struct DSListItem: View {
    private let icon: String
    private let title: String
    private let subtitle: String
    private let value: String
    private let unit: String
    private let iconColor: Color
    
    public init(
        icon: String,
        title: String,
        subtitle: String,
        value: String,
        unit: String,
        iconColor: Color
    ) {
        self.icon = icon
        self.title = title
        self.subtitle = subtitle
        self.value = value
        self.unit = unit
        self.iconColor = iconColor
    }
    
    public var body: some View {
        HStack(spacing: Spacing.medium) {
            // Icon
            Circle()
                .fill(iconColor.opacity(0.2))
                .frame(width: 40, height: 40)
                .overlay(
                    Image(systemName: icon)
                        .font(.system(size: 18))
                        .foregroundStyle(iconColor)
                )
            
            VStack(alignment: .leading, spacing: Spacing.xs) {
                Text(title)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.primary)
                
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: Spacing.xs) {
                HStack(alignment: .firstTextBaseline, spacing: 2) {
                    Text(value)
                        .font(.title3.weight(.bold))
                        .foregroundStyle(.primary)
                    
                    Text(unit)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding()
        .background(Color.secondary.opacity(0.1))
        .cornerRadius(12)
    }
}

#Preview {
    DSListItem(
        icon: "medical.thermometer",
        title: "Food",
        subtitle: "Sub title is great",
        value: "100",
        unit: "mg",
        iconColor: .glucose
    )
    .padding()
}
