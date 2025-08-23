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
    
    public init(biomarker: BioMarker) {
        self.biomarker = biomarker
    }
    
    public var body: some View {
        
        HStack(spacing: Spacing.medium) {
            // Top section with small icon and status
            // Small supporting icon
            Circle()
                .fill(biomarker.healthStatus.color.opacity(0.15))
                .frame(width: 32, height: 32)
                .overlay {
                    Image(systemName: biomarker.iconName)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(biomarker.healthStatus.color)
                }
            
            
            // Status indicator with better text handling
            HStack(spacing: Spacing.xs) {
                Circle()
                    .fill(biomarker.healthStatus.color)
                    .frame(width: 6, height: 6)
                    .scaleEffect(biomarker.healthStatus == .critical ? 1.2 : 1.0)
                
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
            
            VStack(spacing: Spacing.small) {
                // Hero value - the star of the show with better text handling
                VStack(spacing: Spacing.xs) {
                    HStack(alignment: .firstTextBaseline, spacing: 4) {
                        Text(biomarker.currentValue)
                            .font(
                                .system(
                                    .headline,
                                    design: .rounded,
                                    weight: .bold
                                )
                            )
                            .foregroundStyle(biomarker.healthStatus.color)
                            .lineLimit(2)
                            .minimumScaleFactor(0.5)
                            .multilineTextAlignment(.center)
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
                }
                
                // Glow effect behind the value for critical status
                if biomarker.healthStatus == .critical {
                    Rectangle()
                        .fill(biomarker.healthStatus.color)
                        .frame(height: 2)
                        .blur(radius: 4)
                        .scaleEffect(x: 0.8, y: 1.0)
                }
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
    public let lastUpdated: Date
    
    public init(
        id: UUID = UUID(),
        name: String,
        currentValue: String,
        unit: String,
        referenceRange: String = "",
        healthStatus: HealthStatus,
        iconName: String,
        lastUpdated: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.currentValue = currentValue
        self.unit = unit
        self.referenceRange = referenceRange
        self.healthStatus = healthStatus
        self.iconName = iconName
        self.lastUpdated = lastUpdated
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
        ),
        BioMarker(
            name: "Blood Pressure",
            currentValue: "120/80",
            unit: "mmHg",
            referenceRange: "<120/80",
            healthStatus: .optimal,
            iconName: "waveform.path.ecg",
        ),
        BioMarker(
            name: "Hemoglobin",
            currentValue: "13.8",
            unit: "g/dL",
            referenceRange: "12.0-15.5",
            healthStatus: .good,
            iconName: "drop.fill",
        ),
        BioMarker(
            name: "Blood Sugar",
            currentValue: "110",
            unit: "mg/dL",
            referenceRange: "70-99",
            healthStatus: .warning,
            iconName: "cube.fill",
        ),
        BioMarker(
            name: "BMI",
            currentValue: "22.4",
            unit: "kg/m²",
            referenceRange: "18.5-24.9",
            healthStatus: .optimal,
            iconName: "figure.walk",
        ),
        BioMarker(
            name: "Vitamin D",
            currentValue: "18",
            unit: "ng/mL",
            referenceRange: "30-100",
            healthStatus: .critical,
            iconName: "sun.max.fill",
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
        ),
        BioMarker(
            name: "Extremely Long Test Name for Checking Text Wrapping Behavior",
            currentValue: "999999",
            unit: "ng/dL/sec",
            referenceRange: "<50 (normal), 50-100 (borderline), >100 (high risk)",
            healthStatus: .critical,
            iconName: "heart.fill",
        ),
        BioMarker(
            name: "Short",
            currentValue: "1000000000",
            unit: "units",
            referenceRange: "0-999999999999",
            healthStatus: .good,
            iconName: "drop.fill",
        ),
        BioMarker(
            name: "Hyphenated-Long-Biomarker-Name-Test",
            currentValue: "12.3456789",
            unit: "μg/mL/hr",
            referenceRange: "10.0-15.0",
            healthStatus: .optimal,
            iconName: "cube.fill",
        )
    ]
}

// MARK: - Preview

#Preview("Single Item") {
    BioMarkerGridItemView(
        biomarker: BioMarker.samples[0],
    )
}

#Preview("Grid Layout") {
    ScrollView {
        LazyVGrid(columns: [
            GridItem(.flexible(), spacing: Spacing.medium),
            GridItem(.flexible(), spacing: Spacing.medium)
        ], spacing: Spacing.medium) {
            ForEach(BioMarker.samples, id: \.id) { biomarker in
                BioMarkerGridItemView(
                    biomarker: biomarker
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
            biomarker: BioMarker.samples[1]
        )
        
        BioMarkerGridItemView(
            biomarker: BioMarker.samples[5]
        )
    }
    .padding()
}
