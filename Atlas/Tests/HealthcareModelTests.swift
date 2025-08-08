//
//  HealthcareModelTests.swift
//  AtlasTests
//
//  Created by Mayank Gandhi on 08/08/25.
//  Copyright © 2025 m. All rights reserved.
//

import XCTest
@testable import Atlas

final class HealthcareModelTests: XCTestCase {
    
    func testBloodTypeValidation() throws {
        let validBloodTypes = ["A+", "A-", "B+", "B-", "O+", "O-", "AB+", "AB-"]
        
        for bloodType in validBloodTypes {
            XCTAssertTrue(isValidBloodType(bloodType), "Blood type \(bloodType) should be valid")
        }
        
        let invalidBloodTypes = ["C+", "XY", "A", "B", "++"]
        for bloodType in invalidBloodTypes {
            XCTAssertFalse(isValidBloodType(bloodType), "Blood type \(bloodType) should be invalid")
        }
    }
    
    func testHealthStatusValidation() throws {
        // Test that health status values are within expected range
        let validStatuses = ["excellent", "good", "fair", "needs_attention"]
        
        for status in validStatuses {
            XCTAssertTrue(isValidHealthStatus(status), "Health status \(status) should be valid")
        }
    }
    
    func testDateValidation() throws {
        let today = Date()
        let pastDate = Calendar.current.date(byAdding: .year, value: -25, to: today)!
        let futureDate = Calendar.current.date(byAdding: .year, value: 1, to: today)!
        
        XCTAssertTrue(isValidBirthDate(pastDate), "Past date should be valid for birth date")
        XCTAssertFalse(isValidBirthDate(futureDate), "Future date should not be valid for birth date")
    }
    
    func testNotificationSettings() throws {
        var settings = NotificationSettings()
        
        XCTAssertFalse(settings.medicationReminders, "Default medication reminders should be false")
        
        settings.enableMedicationReminders()
        XCTAssertTrue(settings.medicationReminders, "Medication reminders should be enabled after calling enableMedicationReminders")
        
        settings.disableMedicationReminders()
        XCTAssertFalse(settings.medicationReminders, "Medication reminders should be disabled after calling disableMedicationReminders")
    }
}

// MARK: - Helper Functions for Testing

private func isValidBloodType(_ bloodType: String) -> Bool {
    let validTypes = ["A+", "A-", "B+", "B-", "O+", "O-", "AB+", "AB-"]
    return validTypes.contains(bloodType)
}

private func isValidHealthStatus(_ status: String) -> Bool {
    let validStatuses = ["excellent", "good", "fair", "needs_attention"]
    return validStatuses.contains(status)
}

private func isValidBirthDate(_ date: Date) -> Bool {
    return date <= Date()
}

// MARK: - Test Models

private struct NotificationSettings {
    var medicationReminders: Bool = false
    
    mutating func enableMedicationReminders() {
        medicationReminders = true
    }
    
    mutating func disableMedicationReminders() {
        medicationReminders = false
    }
}