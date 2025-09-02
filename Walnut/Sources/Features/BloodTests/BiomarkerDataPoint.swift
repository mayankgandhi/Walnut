//
//  BiomarkerDataPoint.swift
//  Walnut
//
//  Created by Mayank Gandhi on 01/09/25.
//  Copyright © 2025 m. All rights reserved.
//

import Foundation

// Historical data model - keeping for compatibility
public struct BiomarkerDataPoint: Identifiable {
    public let id = UUID()
    public let date: Date
    public let value: Double
    public let bloodReport: String?
    public let bloodReportURLPath: String?
    
    init(
        date: Date,
        value: Double,
        bloodReport: String? = nil,
        bloodReportURLPath: String? = nil
    ) {
        self.date = date
        self.value = value
        self.bloodReport = bloodReport
        self.bloodReportURLPath = bloodReportURLPath
    }
}

