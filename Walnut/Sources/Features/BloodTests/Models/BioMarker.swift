//
//  BioMarker.swift
//  Walnut
//
//  Created by Mayank Gandhi on 03/09/25.
//  Copyright © 2025 m. All rights reserved.
//

import Foundation

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
    
    init(from bloodTestResult: BioMarkerResult) {
        self.id = bloodTestResult.id
        self.name = bloodTestResult.testName
        self.currentValue = bloodTestResult.value
        self.unit = bloodTestResult.unit
        self.referenceRange = bloodTestResult.referenceRange
        self.healthStatus = bloodTestResult.isAbnormal == true ? .warning : .good
        self.iconName = Self.iconName(for: bloodTestResult.testName)
        self.lastUpdated = bloodTestResult.bloodReport?.createdAt ?? Date()
    }
    
    private static func iconName(for testName: String?) -> String {
        guard let testName = testName?.lowercased() else { return "testtube.2" }
        
        switch testName {
        case let name where name.contains("hemoglobin") || name.contains("hgb"):
            return "drop.fill"
        case let name where name.contains("white blood") || name.contains("wbc"):
            return "shield.fill"
        case let name where name.contains("platelet"):
            return "circle.grid.2x2.fill"
        case let name where name.contains("glucose") || name.contains("sugar"):
            return "cube.fill"
        case let name where name.contains("cholesterol"):
            return "heart.fill"
        case let name where name.contains("vitamin"):
            return "sun.max.fill"
        case let name where name.contains("protein") || name.contains("albumin"):
            return "ellipsis.circle.fill"
        case let name where name.contains("liver") || name.contains("alt") || name.contains("ast"):
            return "cross.case.fill"
        case let name where name.contains("kidney") || name.contains("creatinine"):
            return "lungs.fill"
        default:
            return "testtube.2"
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
