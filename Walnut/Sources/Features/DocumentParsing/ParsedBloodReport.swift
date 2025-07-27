//
//  ParsedBloodReport.swift
//  Walnut
//
//  Created by Mayank Gandhi on 28/07/25.
//  Copyright © 2025 m. All rights reserved.
//

import Foundation

struct ParsedBloodReport: Codable {
    let testName: String
    let labName: String
    let category: String
    let resultDate: Date
    let notes: String
    let testResults: [ParsedBloodTestResult]
}

struct ParsedBloodTestResult: Codable {
    let testName: String
    let value: String
    let unit: String
    let referenceRange: String
    let isAbnormal: Bool
}