//
//  HealthIndicators.swift
//  WalnutDesignSystem
//
//  Created by Mayank Gandhi on 06/08/25.
//  Copyright © 2025 m. All rights reserved.
//

import SwiftUI

// MARK: - Health Status

/// Simple health status indicator
public enum HealthStatus {
    case good
    case warning
    case critical
    
    public var color: Color {
        switch self {
        case .good: return .healthSuccess
        case .warning: return .healthWarning
        case .critical: return .healthError
        }
    }
    
    public var icon: String {
        switch self {
        case .good: return "checkmark.circle.fill"
        case .warning: return "exclamationmark.triangle.fill"
        case .critical: return "xmark.circle.fill"
        }
    }
}

/// Simple status indicator
public struct StatusIndicator: View {
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

// MARK: - Health Metric Display

/// Health metric display with native styling
public struct HealthMetric: View {
    private let value: String
    private let unit: String
    private let label: String
    private let status: HealthStatus?
    
    public init(
        value: String,
        unit: String = "",
        label: String,
        status: HealthStatus? = nil
    ) {
        self.value = value
        self.unit = unit
        self.label = label
        self.status = status
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            HStack(alignment: .firstTextBaseline) {
                Text(value)
                    .healthMetricPrimary()
                
                if !unit.isEmpty {
                    Text(unit)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                if let status = status {
                    StatusIndicator(status: status)
                }
            }
            
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}

// MARK: - Progress Ring

// MARK: - Preview

#Preview("Health Indicators") {
    VStack(spacing: Spacing.large) {
        VStack(spacing: Spacing.medium) {
            Text("Status Indicators")
                .font(.headline)
            
            HStack(spacing: Spacing.medium) {
                StatusIndicator(status: .good)
                StatusIndicator(status: .warning)
                StatusIndicator(status: .critical)
            }
        }
        
        VStack(spacing: Spacing.medium) {
            Text("Health Metrics")
                .font(.headline)
            
            HealthMetric(
                value: "120/80",
                unit: "mmHg",
                label: "Blood Pressure",
                status: .good
            )
            .padding(Spacing.medium)
            .cardStyle()
            .padding(Spacing.medium)
            
            HealthMetric(
                value: "98.6",
                unit: "°F",
                label: "Temperature",
                status: .good
            )
            .padding(Spacing.medium)
            .cardStyle()
            .padding(Spacing.medium)
        }
        
        VStack(spacing: Spacing.medium) {
            Text("Progress Rings")
                .font(.headline)
            
            
        }
    }
    .padding(Spacing.large)
}
