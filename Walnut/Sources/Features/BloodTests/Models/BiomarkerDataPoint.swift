//
//  BiomarkerDataPoint.swift
//  Walnut
//
//  Created by Mayank Gandhi on 01/09/25.
//  Copyright © 2025 m. All rights reserved.
//

import Foundation

// Historical data model - keeping for compatibility
struct BiomarkerDataPoint: Identifiable {
     let id = UUID()
     let date: Date
     let value: Double
     let bloodReport: String?
     let document: Document?
    
    init(
        date: Date,
        value: Double,
        bloodReport: String? = nil,
        document: Document? = nil
    ) {
        self.date = date
        self.value = value
        self.bloodReport = bloodReport
        self.document = document
    }
}

