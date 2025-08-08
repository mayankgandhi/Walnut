//
//  BioMarkerInfoView.swift
//  WalnutDesignSystem
//
//  Created by Mayank Gandhi on 08/08/25.
//  Copyright © 2025 m. All rights reserved.
//

import SwiftUI

/// Biomarker information display view
public struct BiomarkerInfoView: View {
    let biomarkerInfo: BiomarkerInfo
    
    public init(biomarkerInfo: BiomarkerInfo) {
        self.biomarkerInfo = biomarkerInfo
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Biomarker name
            Text(biomarkerInfo.name)
                .font(.headline)
                .foregroundColor(.primary)
            
            // Description
            Text(biomarkerInfo.description)
                .font(.body)
                .foregroundColor(.secondary)
                .fixedSize(horizontal: false, vertical: true)
            
            // Normal range and units
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Normal Range")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(biomarkerInfo.normalRange)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("Unit")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(biomarkerInfo.unit)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemGray6))
        )
    }
}
