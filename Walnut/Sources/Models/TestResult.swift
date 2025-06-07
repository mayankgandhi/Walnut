//
//  TestResult.swift
//  Walnut
//
//  Created by Mayank Gandhi on 07/06/25.
//

import CoreData
import Foundation

// MARK: - Test Result Entity (Individual Markers)

@objc(TestResult)
public class TestResult: NSManagedObject {
    @NSManaged public var id: UUID
    
    @NSManaged public var createdAt: Date
    @NSManaged public var updatedAt: Date
    
    // Test Marker Information
    @NSManaged public var markerName: String // e.g., "Glucose", "Hemoglobin A1C", "Total Cholesterol"
    @NSManaged public var markerCode: String? // Laboratory code for the marker
    
    // Result Values
    @NSManaged public var value: String // Text representation of the result
    @NSManaged public var numericValue: Double // Numeric value (0.0 if not applicable)
    @NSManaged public var unit: String? // mg/dL, mmol/L, %, etc.
    
    // Additional Metadata
    @NSManaged public var notes: String?
    
    // Relationships
    @NSManaged public var labResult: LabResult? // Parent lab result
    @NSManaged public var patient: Patient? // Direct reference to patient for easier queries
}
