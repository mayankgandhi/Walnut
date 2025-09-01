//
//  BioMarkerGridItemView.swift
//  WalnutDesignSystem
//
//  Created by Claude on 15/08/25.
//  Copyright © 2025 m. All rights reserved.
//

import SwiftUI
import WalnutDesignSystem

public struct BioMarkerGridItemView: View {
    let biomarker: BioMarker
    
    public init(biomarker: BioMarker) {
        self.biomarker = biomarker
    }
    
    public var body: some View {
        HealthCard {
            HStack(alignment: .center, spacing: Spacing.medium) {
                if let healthStatus = biomarker.healthStatus,
                   let iconName = biomarker.iconName {
                    Circle()
                        .fill(healthStatus.color.opacity(0.15))
                        .frame(width: 32, height: 32)
                        .overlay {
                            Image(systemName: iconName)
                                .font(.system(size: 14, weight: .medium))
                                .foregroundStyle(healthStatus.color)
                        }
                }
                
                
                // Bottom section with name and reference - improved text handling
                VStack(alignment: .leading, spacing: Spacing.xs) {
                    // Biomarker name with better handling for long names
                    if let name = biomarker.name {
                        Text(name)
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.primary)
                            .lineLimit(3)
                            .minimumScaleFactor(0.8)
                            .multilineTextAlignment(.leading)
                            .allowsTightening(true)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    
                    // Reference range with truncation
                    if let referenceRange = biomarker.referenceRange,
                       !referenceRange.isEmpty {
                        Text("Ref: \(referenceRange)")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                            .lineLimit(2)
                            .minimumScaleFactor(0.7)
                            .multilineTextAlignment(.leading)
                    }
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: Spacing.small) {
                    
                    HStack(alignment: .center, spacing: 4) {
                        if let currentValue = biomarker.currentValue {
                            Text(currentValue)
                                .font(
                                    .system(
                                        .headline,
                                        design: .rounded,
                                        weight: .bold
                                    )
                                )
                                .lineLimit(2)
                                .minimumScaleFactor(0.5)
                                .multilineTextAlignment(.center)
                        }
                        
                        if let unit = biomarker.unit,
                            !unit.isEmpty {
                            Text(unit)
                                .font(.subheadline.weight(.medium))
                                .foregroundStyle(.secondary)
                                .lineLimit(1)
                                .minimumScaleFactor(0.8)
                        }
                    }
                    
                    // Status indicator with better text handling
                    if let healthStatus = biomarker.healthStatus {
                        HStack(spacing: Spacing.xs) {
                            Circle()
                                .fill(healthStatus.color)
                                .frame(width: 6, height: 6)
                                .scaleEffect(healthStatus == .critical ? 1.2 : 1.0)
                            
                            Text(healthStatus.displayName.uppercased())
                                .font(.caption2.weight(.bold))
                                .foregroundStyle(healthStatus.color)
                                .lineLimit(1)
                                .minimumScaleFactor(0.7)
                        }
                        .padding(.horizontal, Spacing.small)
                        .padding(.vertical, 3)
                        .background(healthStatus.color.opacity(0.1))
                        .clipShape(Capsule())
                    }
                }
            }
        }
    }
}

// MARK: - Supporting Types

public struct BioMarker {
    public let id: UUID?
    public let name: String?
    public let currentValue: String?
    public let unit: String?
    public let referenceRange: String?
    public let healthStatus: HealthStatus?
    public let iconName: String?
    public let lastUpdated: Date?
    
    public init(
        id: UUID = UUID(),
        name: String,
        currentValue: String,
        unit: String,
        referenceRange: String = "",
        healthStatus: HealthStatus? = nil,
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

#Preview("List") {
    ScrollView {
        
        ForEach(BioMarker.samples, id: \.id) { biomarker in
            BioMarkerGridItemView(
                biomarker: biomarker
            )
        }
    }
    .background(Color(UIColor.systemGroupedBackground))
}

#Preview("Different States") {
        BioMarkerGridItemView(
            biomarker: BioMarker.samples[1]
        )
        
        BioMarkerGridItemView(
            biomarker: BioMarker.samples[5]
        )
}
