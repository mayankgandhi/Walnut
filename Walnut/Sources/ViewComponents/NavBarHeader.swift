//
//  NavBarHeader.swift
//  WalnutDesignSystem
//
//  Created by Mayank Gandhi on 12/09/25.
//  Copyright © 2025 m. All rights reserved.
//

import SwiftUI
import WalnutDesignSystem

struct NavBarHeader: View {
    
    // MARK: - Properties
    
    private let iconName: String?
    private let iconColor: Color?
    
    private let title: String
    private let subtitle: String?
    private let iconBackgroundSize: CGFloat = 64
    
    
    // MARK: - Initialization
    
    init(
        iconName: String? = nil,
        iconColor: Color? = nil,
        title: String,
        subtitle: String? = nil,
    ) {
        self.iconName = iconName
        self.iconColor = iconColor
        self.title = title
        self.subtitle = subtitle
    }
    
    // MARK: - Body
    
    public var body: some View {
        HStack(spacing: Spacing.medium) {
            if let iconName, let iconColor {
                iconImageView(iconName, iconColor: iconColor)
            }
            contentView
            Spacer()
        }
        .padding(.horizontal, Spacing.medium)
        .padding(.top, Spacing.medium)
    }
    
    // MARK: - View Components
    
    
    @ViewBuilder
    private func iconImageView(_ iconName: String, iconColor: Color) -> some View {
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
            
            if let subtitle = subtitle, subtitle != "" {
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
            NavBarHeader(
                iconName: "pill-bottle",
                iconColor: .red,
                title: "Patient Summary",
                subtitle: nil
            )
        }
    }
}

