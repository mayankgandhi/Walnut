//
//  AggregatedBiomarker.swift
//  Walnut
//
//  Created by Mayank Gandhi on 26/08/25.
//  Copyright © 2025 m. All rights reserved.
//

import Foundation
import SwiftUI
import WalnutDesignSystem

// MARK: - Supporting Types

struct AggregatedBiomarker: Identifiable, Hashable {
    
    static func == (lhs: AggregatedBiomarker, rhs: AggregatedBiomarker) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    let id: UUID
    let testName: String
    let currentValue: String
    let unit: String
    let referenceRange: String
    let category: String
    let latestDate: Date
    let historicalValues: [BiomarkerDataPoint]
    let healthStatus: HealthStatus
    let trendDirection: TrendDirection
    let trendText: String
    let trendPercentage: String
    let latestBloodReport: BloodReport
    let testCount: Int
    
    
    var currentNumericValue: Double {
        Double(currentValue) ?? 0.0
    }
    
    var healthStatusColor: Color {
        switch healthStatus {
        case .optimal: return .healthSuccess
        case .good: return .healthPrimary
        case .warning: return .healthWarning
        case .critical: return .healthError
        }
    }
}
