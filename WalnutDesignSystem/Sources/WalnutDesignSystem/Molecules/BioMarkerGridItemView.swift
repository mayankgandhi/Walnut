//
//  BioMarkerGridItemView.swift
//  WalnutDesignSystem
//
//  Created by Claude on 15/08/25.
//  Copyright © 2025 m. All rights reserved.
//

import SwiftUI

public struct BioMarkerGridItemView: View {
    let biomarker: BioMarker
    let isSelected: Bool
    let onTap: () -> Void
    
    @State private var isPressed = false
    @State private var hoverOffset: CGFloat = 0
    @State private var glowOpacity: Double = 0
    
    public init(biomarker: BioMarker, isSelected: Bool = false, onTap: @escaping () -> Void) {
        self.biomarker = biomarker
        self.isSelected = isSelected
        self.onTap = onTap
    }
    
    public var body: some View {
        Button(action: onTap) {
            ZStack {
                // Clean card design
                RoundedRectangle(cornerRadius: 16)
                    .fill(.white)
                    .shadow(
                        color: isSelected ? biomarker.healthStatus.color.opacity(0.3) : Color.black.opacity(0.08),
                        radius: isSelected ? 12 : 8,
                        x: 0,
                        y: isPressed ? 2 : 4
                    )
                
                // Content - Value-First Design
                VStack(spacing: Spacing.medium) {
                    // Top section with small icon and status
                    HStack {
                        // Small supporting icon
                        Circle()
                            .fill(biomarker.healthStatus.color.opacity(0.15))
                            .frame(width: 32, height: 32)
                            .overlay {
                                Image(systemName: biomarker.iconName)
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundStyle(biomarker.healthStatus.color)
                            }
                        
                        Spacer()
                        
                        // Status indicator with better text handling
                        HStack(spacing: Spacing.xs) {
                            Circle()
                                .fill(biomarker.healthStatus.color)
                                .frame(width: 6, height: 6)
                                .scaleEffect(biomarker.healthStatus == .critical ? 1.2 : 1.0)
                                .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: biomarker.healthStatus == .critical)
                            
                            Text(biomarker.healthStatus.displayName.uppercased())
                                .font(.caption2.weight(.bold))
                                .foregroundStyle(biomarker.healthStatus.color)
                                .lineLimit(1)
                                .minimumScaleFactor(0.7)
                        }
                        .padding(.horizontal, Spacing.small)
                        .padding(.vertical, 3)
                        .background(biomarker.healthStatus.color.opacity(0.1))
                        .clipShape(Capsule())
                    }
                    
                    // Main content - PROMINENT VALUE
                    VStack(spacing: Spacing.small) {
                        // Hero value - the star of the show with better text handling
                        VStack(spacing: Spacing.xs) {
                            HStack(alignment: .firstTextBaseline, spacing: 4) {
                                Text(biomarker.currentValue)
                                    .font(.system(size: 36, weight: .bold, design: .rounded))
                                    .foregroundStyle(biomarker.healthStatus.color)
                                    .lineLimit(2)
                                    .minimumScaleFactor(0.5)
                                    .multilineTextAlignment(.center)
                                    .scaleEffect(isPressed ? 0.95 : 1.0)
                                    .offset(y: hoverOffset)
                                    .allowsTightening(true)
                                
                                if !biomarker.unit.isEmpty {
                                    Text(biomarker.unit)
                                        .font(.subheadline.weight(.medium))
                                        .foregroundStyle(.secondary)
                                        .lineLimit(1)
                                        .minimumScaleFactor(0.8)
                                        .offset(y: 2) // Align with baseline
                                }
                            }
                            
                            // Trend indicator directly under value with better text handling
                            if let trend = biomarker.trend {
                                HStack(spacing: 4) {
                                    Image(systemName: trend.iconName)
                                        .font(.caption.weight(.medium))
                                    Text(trend.displayName)
                                        .font(.caption.weight(.medium))
                                        .lineLimit(1)
                                        .minimumScaleFactor(0.8)
                                }
                                .foregroundStyle(trend.color)
                                .padding(.horizontal, Spacing.small)
                                .padding(.vertical, 2)
                                .background(trend.color.opacity(0.1))
                                .clipShape(Capsule())
                            }
                        }
                        
                        // Glow effect behind the value for critical status
                        if biomarker.healthStatus == .critical {
                            Rectangle()
                                .fill(biomarker.healthStatus.color.opacity(glowOpacity * 0.5))
                                .frame(height: 2)
                                .blur(radius: 4)
                                .scaleEffect(x: 0.8, y: 1.0)
                        }
                    }
                    
                    Spacer()
                    
                    // Bottom section with name and reference - improved text handling
                    VStack(spacing: Spacing.xs) {
                        // Biomarker name with better handling for long names
                        Text(biomarker.name)
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.primary)
                            .lineLimit(3)
                            .minimumScaleFactor(0.8)
                            .multilineTextAlignment(.center)
                            .allowsTightening(true)
                            .fixedSize(horizontal: false, vertical: true)
                        
                        // Reference range with truncation
                        if !biomarker.referenceRange.isEmpty {
                            Text("Ref: \(biomarker.referenceRange)")
                                .font(.caption2)
                                .foregroundStyle(.tertiary)
                                .lineLimit(2)
                                .minimumScaleFactor(0.7)
                                .multilineTextAlignment(.center)
                        }
                    }
                }
                .padding(Spacing.medium)
                
                // Selection overlay
                if isSelected {
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(biomarker.healthStatus.color, lineWidth: 2)
                        .overlay(
                            VStack {
                                HStack {
                                    Spacer()
                                    Circle()
                                        .fill(biomarker.healthStatus.color)
                                        .frame(width: 20, height: 20)
                                        .overlay {
                                            Image(systemName: "checkmark")
                                                .font(.caption.weight(.bold))
                                                .foregroundStyle(.white)
                                        }
                                        .offset(x: 6, y: -6)
                                }
                                Spacer()
                            }
                        )
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(isPressed ? 0.98 : 1.0)
        .animation(.easeInOut(duration: 0.15), value: isPressed)
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: hoverOffset)
        .animation(.easeInOut(duration: 0.3), value: glowOpacity)
        .onTapGesture {
            // Haptic feedback
            let impactFeedback = UIImpactFeedbackGenerator(style: .light)
            impactFeedback.impactOccurred()
        }
        .onLongPressGesture(
            minimumDuration: 1,
            perform: {},
            onPressingChanged: { pressing in
                isPressed = pressing
                if pressing {
                    hoverOffset = -2
                    glowOpacity = 0.3
                } else {
                    hoverOffset = 0
                    glowOpacity = 0
                }
            }
        )
        .onAppear {
            // Subtle entrance animation
            withAnimation(.easeOut(duration: 0.6).delay(Double.random(in: 0...0.3))) {
                hoverOffset = 0
            }
        }
    }
}

// MARK: - Supporting Types

public struct BioMarker {
    public let id: UUID
    public let name: String
    public let currentValue: String
    public let unit: String
    public let referenceRange: String
    public let healthStatus: HealthStatus
    public let iconName: String
    public let trend: Trend?
    public let lastUpdated: Date
    
    public init(
        id: UUID = UUID(),
        name: String,
        currentValue: String,
        unit: String,
        referenceRange: String = "",
        healthStatus: HealthStatus,
        iconName: String,
        trend: Trend? = nil,
        lastUpdated: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.currentValue = currentValue
        self.unit = unit
        self.referenceRange = referenceRange
        self.healthStatus = healthStatus
        self.iconName = iconName
        self.trend = trend
        self.lastUpdated = lastUpdated
    }
}



public enum Trend: CaseIterable {
    case improving, stable, declining
    
    public var color: Color {
        switch self {
        case .improving: return .healthSuccess
        case .stable: return .healthPrimary
        case .declining: return .healthError
        }
    }
    
    public var iconName: String {
        switch self {
        case .improving: return "arrow.up.right"
        case .stable: return "arrow.right"
        case .declining: return "arrow.down.right"
        }
    }
    
    public var displayName: String {
        switch self {
        case .improving: return "Improving"
        case .stable: return "Stable"
        case .declining: return "Declining"
        }
    }
}

// MARK: - Sample Data

extension BioMarker {
    public static let samples: [BioMarker] = [
        BioMarker(
            name: "Cholesterol",
            currentValue: "185",
            unit: "mg/dL",
            referenceRange: "<200",
            healthStatus: .good,
            iconName: "heart.fill",
            trend: .stable
        ),
        BioMarker(
            name: "Blood Pressure",
            currentValue: "120/80",
            unit: "mmHg",
            referenceRange: "<120/80",
            healthStatus: .optimal,
            iconName: "waveform.path.ecg",
            trend: .improving
        ),
        BioMarker(
            name: "Hemoglobin",
            currentValue: "13.8",
            unit: "g/dL",
            referenceRange: "12.0-15.5",
            healthStatus: .good,
            iconName: "drop.fill",
            trend: .stable
        ),
        BioMarker(
            name: "Blood Sugar",
            currentValue: "110",
            unit: "mg/dL",
            referenceRange: "70-99",
            healthStatus: .warning,
            iconName: "cube.fill",
            trend: .declining
        ),
        BioMarker(
            name: "BMI",
            currentValue: "22.4",
            unit: "kg/m²",
            referenceRange: "18.5-24.9",
            healthStatus: .optimal,
            iconName: "figure.walk",
            trend: .improving
        ),
        BioMarker(
            name: "Vitamin D",
            currentValue: "18",
            unit: "ng/mL",
            referenceRange: "30-100",
            healthStatus: .critical,
            iconName: "sun.max.fill",
            trend: .declining
        )
    ]
    
    // Long text test samples
    public static let longTextSamples: [BioMarker] = [
        BioMarker(
            name: "Very Long Biomarker Name That Might Overflow",
            currentValue: "12345.67890",
            unit: "units/mL",
            referenceRange: "1000.0-2000.0 (very specific range)",
            healthStatus: .warning,
            iconName: "testtube.2",
            trend: .stable
        ),
        BioMarker(
            name: "Extremely Long Test Name for Checking Text Wrapping Behavior",
            currentValue: "999999",
            unit: "ng/dL/sec",
            referenceRange: "<50 (normal), 50-100 (borderline), >100 (high risk)",
            healthStatus: .critical,
            iconName: "heart.fill",
            trend: .declining
        ),
        BioMarker(
            name: "Short",
            currentValue: "1000000000",
            unit: "units",
            referenceRange: "0-999999999999",
            healthStatus: .good,
            iconName: "drop.fill",
            trend: .improving
        ),
        BioMarker(
            name: "Hyphenated-Long-Biomarker-Name-Test",
            currentValue: "12.3456789",
            unit: "μg/mL/hr",
            referenceRange: "10.0-15.0",
            healthStatus: .optimal,
            iconName: "cube.fill",
            trend: .stable
        )
    ]
}

// MARK: - Preview

#Preview("Single Item") {
    BioMarkerGridItemView(
        biomarker: BioMarker.samples[0],
        onTap: {}
    )
    .frame(width: 160, height: 200)
    .padding()
}

#Preview("Grid Layout") {
    ScrollView {
        LazyVGrid(columns: [
            GridItem(.flexible(), spacing: Spacing.medium),
            GridItem(.flexible(), spacing: Spacing.medium)
        ], spacing: Spacing.medium) {
            ForEach(BioMarker.samples, id: \.id) { biomarker in
                BioMarkerGridItemView(
                    biomarker: biomarker,
                    isSelected: biomarker.healthStatus == .critical,
                    onTap: {}
                )
                .frame(height: 200)
            }
        }
        .padding()
    }
    .background(Color(UIColor.systemGroupedBackground))
}

#Preview("Different States") {
    HStack(spacing: Spacing.medium) {
        BioMarkerGridItemView(
            biomarker: BioMarker.samples[1],
            onTap: {}
        )
        .frame(width: 160, height: 200)
        
        BioMarkerGridItemView(
            biomarker: BioMarker.samples[5],
            isSelected: true,
            onTap: {}
        )
        .frame(width: 160, height: 200)
    }
    .padding()
}

#Preview("Long Text Scenarios") {
    ScrollView {
        LazyVGrid(columns: [
            GridItem(.flexible(), spacing: Spacing.medium),
            GridItem(.flexible(), spacing: Spacing.medium)
        ], spacing: Spacing.medium) {
            ForEach(BioMarker.longTextSamples, id: \.id) { biomarker in
                BioMarkerGridItemView(
                    biomarker: biomarker,
                    onTap: {}
                )
                .frame(height: 200)
            }
        }
        .padding()
    }
    .background(Color(UIColor.systemGroupedBackground))
}
