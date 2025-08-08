//
//  Typography.swift
//  WalnutDesignSystem
//
//  Created by Mayank Gandhi on 06/08/25.
//  Copyright © 2025 m. All rights reserved.
//

import SwiftUI

/// Walnut Typography Extensions
/// Uses native SwiftUI font styles with healthcare-specific additions
public extension Font {
    
    // MARK: - Health-Specific Fonts
    
    /// Large health metrics (glucose, blood pressure)
    static let healthMetricLarge = Font.system(size: 36, weight: .bold, design: .rounded)
    
    /// Medium health metrics
    static let healthMetricMedium = Font.system(size: 24, weight: .semibold, design: .rounded)
    
    /// Small health metrics for compact displays
    static let healthMetricSmall = Font.system(size: 18, weight: .medium, design: .rounded)
}

// MARK: - Text Style Modifiers

public extension Text {
    /// Primary health metric display style
    func healthMetricPrimary() -> some View {
        self
            .font(.healthMetricLarge)
            .foregroundStyle(.primary)
    }
    
    /// Secondary health metric display style
    func healthMetricSecondary() -> some View {
        self
            .font(.healthMetricMedium)
            .foregroundStyle(.secondary)
    }
    
    /// Success message style
    func successStyle() -> some View {
        self
            .font(.caption)
            .fontWeight(.medium)
            .foregroundStyle(Color.healthSuccess)
    }
    
    /// Error message style
    func errorStyle() -> some View {
        self
            .font(.caption)
            .fontWeight(.medium)
            .foregroundStyle(Color.healthError)
    }
    
    /// Warning message style
    func warningStyle() -> some View {
        self
            .font(.caption)
            .fontWeight(.medium)
            .foregroundStyle(Color.healthWarning)
    }
}
