//
//  MetricView.swift
//  WalnutDesignSystem
//
//  Created by Mayank Gandhi on 08/08/25.
//  Copyright © 2025 m. All rights reserved.
//

import SwiftUI

/// Individual metric display component
public struct MetricView: View {
    let value: String
    let unit: String
    let label: String
    
    public init(value: String, unit: String, label: String) {
        self.value = value
        self.unit = unit
        self.label = label
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack(alignment: .bottom, spacing: 2) {
                Text(value)
                    .font(.title2)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                if !unit.isEmpty {
                    Text(unit)
                        .font(.caption)
                        .foregroundColor(.gray)
                        .offset(y: -2)
                }
            }
            Text(label)
                .font(.caption)
                .foregroundColor(.gray)
        }
    }
}
