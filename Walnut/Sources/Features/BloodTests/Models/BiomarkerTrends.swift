//
//  BiomarkerTrends.swift
//  Walnut
//
//  Created by Mayank Gandhi on 03/09/25.
//  Copyright © 2025 m. All rights reserved.
//

import Foundation

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

