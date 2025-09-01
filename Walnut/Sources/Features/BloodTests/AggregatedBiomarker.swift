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
    let historicalValues: [Double]
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
    
    var description: String {
        switch testName.lowercased() {
        case let name where name.contains("hemoglobin"):
            return "Protein that carries oxygen in red blood cells"
        case let name where name.contains("glucose"):
            return "Blood sugar levels, important for diabetes monitoring"
        case let name where name.contains("cholesterol"):
            return "Blood fats that affect cardiovascular health"
        case let name where name.contains("white blood"):
            return "Immune system cells that fight infections"
        case let name where name.contains("platelet"):
            return "Blood cells that help with clotting"
        case let name where name.contains("creatinine"):
            return "Kidney function marker"
        case let name where name.contains("thyroid") || name.contains("tsh"):
            return "Thyroid hormone levels affecting metabolism"
        default:
            return "Blood test biomarker for health monitoring"
        }
    }
}
