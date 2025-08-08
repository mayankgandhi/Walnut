//
//  BiomarkerInfo.swift
//  WalnutDesignSystem
//
//  Created by Mayank Gandhi on 08/08/25.
//  Copyright © 2025 m. All rights reserved.
//

import Foundation
import SwiftUI

/// Biomarker information model
public struct BiomarkerInfo {
    let name: String
    let description: String
    let normalRange: String
    let unit: String
    
    public init(name: String, description: String, normalRange: String, unit: String) {
        self.name = name
        self.description = description
        self.normalRange = normalRange
        self.unit = unit
    }
}

/// Biomarker trends model for full-screen display
public struct BiomarkerTrends {
    let currentValue: Double
    let currentValueText: String
    let comparisonText: String
    let comparisonPercentage: String
    let trendDirection: TrendDirection
    let normalRange: String
    
    public init(
        currentValue: Double,
        currentValueText: String,
        comparisonText: String,
        comparisonPercentage: String,
        trendDirection: TrendDirection,
        normalRange: String
    ) {
        self.currentValue = currentValue
        self.currentValueText = currentValueText
        self.comparisonText = comparisonText
        self.comparisonPercentage = comparisonPercentage
        self.trendDirection = trendDirection
        self.normalRange = normalRange
    }
}

public enum TrendDirection {
    case up, down, stable
    
    var iconName: String {
        switch self {
        case .up: return "arrow.up.circle.fill"
        case .down: return "arrow.down.circle.fill"
        case .stable: return "minus.circle.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .up: return .green
        case .down: return .orange
        case .stable: return .gray
        }
    }
}
