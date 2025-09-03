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
