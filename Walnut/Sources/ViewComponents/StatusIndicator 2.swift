//
//  StatusIndicator 2.swift
//  Walnut
//
//  Created by Mayank Gandhi on 01/09/25.
//  Copyright © 2025 m. All rights reserved.
//

import SwiftUI
import WalnutDesignSystem

/// Simple status indicator
public struct HealthStatusIndicator: View {
    private let status: HealthStatus
    private let showIcon: Bool
    
    public init(status: HealthStatus, showIcon: Bool = true) {
        self.status = status
        self.showIcon = showIcon
    }
    
    public var body: some View {
        HStack(spacing: Spacing.xs) {
            if showIcon {
                Image(systemName: status.icon)
                    .font(.caption)
                    .foregroundStyle(status.color)
            } else {
                Circle()
                    .fill(status.color)
                    .frame(width: 8, height: 8)
            }
        }
        .accessibilityLabel("Health status: \(status.color == .healthSuccess ? "Good" : status.color == .healthWarning ? "Warning" : "Critical")")
    }
}
