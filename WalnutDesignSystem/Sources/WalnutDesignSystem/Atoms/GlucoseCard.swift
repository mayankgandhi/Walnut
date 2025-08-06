//
//  GlucoseCard.swift
//  WalnutDesignSystem
//
//  Created by Mayank Gandhi on 06/08/25.
//  Copyright © 2025 m. All rights reserved.
//

import SwiftUI

/// Glucose monitoring card matching the reference design
public struct GlucoseCard: View {
    private let currentValue: String
    private let lastValue: String
    private let status: String
    private let statusColor: Color
    private let timestamp: String
    
    public init(
        currentValue: String,
        lastValue: String,
        status: String,
        statusColor: Color = .healthWarning,
        timestamp: String
    ) {
        self.currentValue = currentValue
        self.lastValue = lastValue
        self.status = status
        self.statusColor = statusColor
        self.timestamp = timestamp
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: Spacing.medium) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: Spacing.xs) {
                    HStack(spacing: Spacing.xs) {
                        Circle()
                            .fill(Color.glucose)
                            .frame(width: 8, height: 8)
                        
                        Text("Glucose")
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(.primary)
                    }
                    
                    Text("Latest measurement")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                Text(timestamp)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            
            // Main metrics
            HStack(alignment: .bottom, spacing: Spacing.large) {
                VStack(alignment: .leading, spacing: Spacing.xs) {
                    Text(currentValue)
                        .font(.system(size: 48, weight: .bold, design: .rounded))
                        .foregroundStyle(.primary)
                    
                    Text(status)
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(statusColor)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: Spacing.xs) {
                    Text("Last scan")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                    
                    Text(lastValue)
                        .font(.title2.weight(.semibold))
                        .foregroundStyle(.secondary)
                    
                    Text("Growth")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                    
                    Text("Negative")
                        .font(.caption2.weight(.medium))
                        .foregroundStyle(.secondary)
                }
            }
            
            // Action buttons
            HStack(spacing: Spacing.small) {
                Button(action: {}) {
                    HStack(spacing: Spacing.xs) {
                        Image(systemName: "clock")
                            .font(.caption)
                        Text("Before meal")
                            .font(.caption.weight(.medium))
                    }
                    .padding(.horizontal, Spacing.small)
                    .padding(.vertical, Spacing.xs)
                    .background(.ultraThinMaterial, in: Capsule())
                }
                .foregroundStyle(.secondary)
                
                Button(action: {}) {
                    HStack(spacing: Spacing.xs) {
                        Image(systemName: "syringe")
                            .font(.caption)
                        Text("10 Insulin units")
                            .font(.caption.weight(.medium))
                    }
                    .padding(.horizontal, Spacing.small)
                    .padding(.vertical, Spacing.xs)
                    .background(.ultraThinMaterial, in: Capsule())
                }
                .foregroundStyle(.secondary)
                
                Button(action: {}) {
                    Image(systemName: "plus")
                        .font(.caption.weight(.medium))
                        .foregroundStyle(.white)
                        .frame(width: 24, height: 24)
                        .background(Color.healthPrimary, in: Circle())
                }
            }
        }
        .padding(Spacing.medium)
        .cardStyle()
    }
}

#Preview {
    GlucoseCard(
        currentValue: "100",
        lastValue: "80",
        status: "stable",
        statusColor: .green,
        timestamp: "12:11pm"
    )
}
