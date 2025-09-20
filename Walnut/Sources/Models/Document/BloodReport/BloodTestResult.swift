//
//  BioMarkerResult.swift
//  Walnut
//
//  Created by Mayank Gandhi on 28/07/25.
//  Copyright © 2025 m. All rights reserved.
//

import Foundation
import SwiftData

@Model
class BioMarkerResult: Identifiable, Sendable {
    
    var id: UUID?
    
    var testName: String?
    var value: String?
    var unit: String?
    var referenceRange: String?
    var isAbnormal: Bool?
    
    var bloodReport: BioMarkerReport?
    
    init(id: UUID = UUID(),
         testName: String,
         value: String,
         unit: String,
         referenceRange: String,
         isAbnormal: Bool = false,
         bloodReport: BioMarkerReport? = nil) {
        self.id = id
        self.testName = testName
        self.value = value
        self.unit = unit
        self.referenceRange = referenceRange
        self.isAbnormal = isAbnormal
        self.bloodReport = bloodReport
    }
}

// MARK: - Sample Data
extension BioMarkerResult {
    @MainActor
    static func sampleResults(for bloodReport: BioMarkerReport) -> [BioMarkerResult] {
        [
            BioMarkerResult(
                testName: "Hemoglobin",
                value: "14.2",
                unit: "g/dL",
                referenceRange: "12.0-15.5",
                isAbnormal: false,
                bloodReport: bloodReport
            ),
            BioMarkerResult(
                testName: "White Blood Cell Count",
                value: "7.8",
                unit: "K/uL",
                referenceRange: "4.5-11.0",
                isAbnormal: false,
                bloodReport: bloodReport
            ),
            BioMarkerResult(
                testName: "Platelets",
                value: "320",
                unit: "K/uL",
                referenceRange: "150-450",
                isAbnormal: false,
                bloodReport: bloodReport
            )
        ]
    }
}
