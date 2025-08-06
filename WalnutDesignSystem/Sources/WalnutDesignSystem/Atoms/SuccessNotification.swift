//
//  SuccessNotification.swift
//  WalnutDesignSystem
//
//  Created by Mayank Gandhi on 06/08/25.
//  Copyright © 2025 m. All rights reserved.
//

import SwiftUI

/// Success notification with droplet animation (matching the middle design)
public struct SuccessNotification: View {
    private let message: String
    private let timestamp: String
    private let value: String
    private let unit: String
    private let status: String
    @State private var animateDroplet = false
    
    public init(
        message: String = "Success!",
        timestamp: String,
        value: String,
        unit: String,
        status: String
    ) {
        self.message = message
        self.timestamp = timestamp
        self.value = value
        self.unit = unit
        self.status = status
    }
    
    public var body: some View {
        VStack(spacing: Spacing.large) {
            // Animated droplet
            ZStack {
                // Background droplets
                ForEach(0..<3, id: \.self) { index in
                    Image(systemName: "drop.fill")
                        .font(.system(size: 20))
                        .foregroundStyle(Color.healthPrimary.opacity(0.3))
                        .offset(
                            x: CGFloat(index - 1) * 30,
                            y: animateDroplet ? -20 : 0
                        )
                        .scaleEffect(animateDroplet ? 0.8 : 1.0)
                        .animation(
                            .easeInOut(duration: 1.5)
                            .delay(Double(index) * 0.2)
                            .repeatForever(autoreverses: true),
                            value: animateDroplet
                        )
                }
                
                // Main droplet with checkmark
                ZStack {
                    Image(systemName: "drop.fill")
                        .font(.system(size: 60))
                        .foregroundStyle(Color.healthPrimary.opacity(0.8))
                    
                    Image(systemName: "checkmark")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundStyle(.white)
                }
                .scaleEffect(animateDroplet ? 1.1 : 1.0)
                .animation(
                    .easeInOut(duration: 2)
                    .repeatForever(autoreverses: true),
                    value: animateDroplet
                )
            }
            .frame(height: 100)
            
            // Success message
            Text(message)
                .font(.title2.weight(.semibold))
                .foregroundStyle(.primary)
            
            Text(timestamp)
                .font(.caption)
                .foregroundStyle(.secondary)
            
            // Large value display
            VStack(spacing: Spacing.xs) {
                HStack(alignment: .firstTextBaseline) {
                    Text(value)
                        .font(.system(size: 48, weight: .bold, design: .rounded))
                        .foregroundStyle(.primary)
                    
                    Text(unit)
                        .font(.title3)
                        .foregroundStyle(.secondary)
                }
                
                Text(status)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.orange)
            }
            
            // Action buttons
            HStack(spacing: Spacing.medium) {
                Button("Before meal") {}
                    .buttonStyle(.bordered)
                    .tint(Color.healthPrimary)
                
                Button("10 Insulin units") {}
                    .buttonStyle(.borderedProminent)
                    .tint(Color.healthPrimary)
            }
        }
        .padding(Spacing.large)
        .onAppear {
            animateDroplet = true
        }
    }
}

/// Nutrition list item (matching the left screen nutrition items)
public struct NutritionListItem: View {
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
        .padding(.vertical, Spacing.small)
    }
}

/// Line chart component (matching the monitoring chart)
public struct LineChart: View {
    private let data: [Double]
    private let color: Color
    private let showPoints: Bool
    
    public init(data: [Double], color: Color = .healthPrimary, showPoints: Bool = true) {
        self.data = data
        self.color = color
        self.showPoints = showPoints
    }
    
    public var body: some View {
        GeometryReader { geometry in
            let maxValue = data.max() ?? 1
            let minValue = data.min() ?? 0
            let range = maxValue - minValue
            let stepX = geometry.size.width / CGFloat(data.count - 1)
            
            ZStack {
                // Line path
                Path { path in
                    guard !data.isEmpty else { return }
                    
                    let firstPoint = CGPoint(
                        x: 0,
                        y: geometry.size.height * (1 - (data[0] - minValue) / range)
                    )
                    path.move(to: firstPoint)
                    
                    for (index, value) in data.enumerated().dropFirst() {
                        let point = CGPoint(
                            x: stepX * CGFloat(index),
                            y: geometry.size.height * (1 - (value - minValue) / range)
                        )
                        path.addLine(to: point)
                    }
                }
                .stroke(color, style: StrokeStyle(lineWidth: 2, lineCap: .round))
                
                // Data points
                if showPoints {
                    ForEach(Array(data.enumerated()), id: \.offset) { index, value in
                        Circle()
                            .fill(color)
                            .frame(width: 6, height: 6)
                            .position(
                                x: stepX * CGFloat(index),
                                y: geometry.size.height * (1 - (value - minValue) / range)
                            )
                    }
                }
                
                // Highlight current point
                if let lastValue = data.last {
                    Circle()
                        .fill(.orange)
                        .frame(width: 8, height: 8)
                        .position(
                            x: stepX * CGFloat(data.count - 1),
                            y: geometry.size.height * (1 - (lastValue - minValue) / range)
                        )
                }
            }
        }
        .frame(height: 80)
    }
}
