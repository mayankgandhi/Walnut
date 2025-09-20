//
//  MedicationEngineTests.swift
//  Walnut
//
//  Created by Mayank Gandhi on 20/09/25.
//  Copyright © 2025 m. All rights reserved.
//

import Foundation

/// Test examples and usage demonstrations for MedicationEngine
struct MedicationEngineTestExamples {

    static func runTestExamples() {
        print("🧪 Testing MedicationEngine with sample data...")

        // Test with sample medications
        testWithSampleMedications()
        testWithComplexSchedules()
        testMealBasedMedications()
        testUpcomingDoseCalculation()

        print("✅ All MedicationEngine tests completed!")
    }

    // MARK: - Basic Tests

    static func testWithSampleMedications() {
        print("\n📋 Test 1: Basic Sample Medications")

        let medications = [
            Medication.sampleMedication,
            Medication.complexMedication
        ]

        let schedule = MedicationEngine.generateDailySchedule(from: medications)

        print("Generated schedule for \(medications.count) medications:")
        for (timeSlot, doses) in schedule.sorted(by: { $0.key.rawValue < $1.key.rawValue }) {
            print("  \(timeSlot.displayName): \(doses.count) dose(s)")
            for dose in doses {
                print("    - \(dose.medication.name ?? "Unknown") at \(dose.displayTime)")
                if let mealRelation = dose.mealRelation {
                    print("      \(mealRelation.displayText)")
                }
            }
        }
    }

    // MARK: - Complex Schedule Tests

    static func testWithComplexSchedules() {
        print("\n⏰ Test 2: Complex Medication Schedules")

        let medications = [
            Medication.hourlyMedication,
            Medication.weeklyMedication,
            Medication.monthlyMedication
        ]

        let schedule = MedicationEngine.generateDailySchedule(from: medications)

        print("Complex schedule results:")
        for (timeSlot, doses) in schedule.sorted(by: { $0.key.rawValue < $1.key.rawValue }) {
            print("  \(timeSlot.displayName):")
            for dose in doses {
                print("    - \(dose.medication.name ?? "Unknown") (\(dose.medication.dosage ?? "No dosage")) at \(dose.displayTime)")
            }
        }
    }

    // MARK: - Meal-Based Tests

    static func testMealBasedMedications() {
        print("\n🍽️ Test 3: Meal-Based Medications")

        // Create a meal-based medication
        let mealBasedMedication = Medication(
            name: "Metformin",
            frequency: [
                .mealBased(mealTime: .breakfast, timing: .after),
                .mealBased(mealTime: .dinner, timing: .after)
            ],
            duration: .ongoing,
            dosage: "500mg",
            patient: .samplePatient
        )

        let schedule = MedicationEngine.generateDailySchedule(from: [mealBasedMedication])

        print("Meal-based medication schedule:")
        for (timeSlot, doses) in schedule.sorted(by: { $0.key.rawValue < $1.key.rawValue }) {
            for dose in doses {
                if let mealRelation = dose.mealRelation {
                    print("  \(dose.medication.name ?? "Unknown") - \(mealRelation.displayText) at \(dose.displayTime)")
                }
            }
        }
    }

    // MARK: - Upcoming Dose Tests

    static func testUpcomingDoseCalculation() {
        print("\n🔮 Test 4: Next Upcoming Dose")

        let medications = [
            Medication.sampleMedication,
            Medication.complexMedication,
            Medication.hourlyMedication
        ]

        if let nextDose = MedicationEngine.getNextUpcomingDose(from: medications) {
            print("Next upcoming dose:")
            print("  \(nextDose.medication.name ?? "Unknown") at \(nextDose.displayTime)")
            if let mealRelation = nextDose.mealRelation {
                print("  \(mealRelation.displayText)")
            }
        } else {
            print("No upcoming doses found for today")
        }
    }

    // MARK: - Integration Example

    static func demonstrateTimelineViewIntegration() {
        print("\n🔗 Integration Example: Direct usage with MedicationTimelineView")

        let medications = [
            Medication.sampleMedication,
            Medication.complexMedication,
            Medication.hourlyMedication
        ]

        // This is exactly how you'd use it with MedicationTimelineView
        let scheduledDoses = MedicationEngine.generateDailySchedule(from: medications)

        print("Ready for MedicationTimelineView:")
        print("  Input: [Medication] (\(medications.count) medications)")
        print("  Output: [TimeSlot: [ScheduledDose]] (\(scheduledDoses.keys.count) time slots)")

        // Example usage:
        // MedicationTimelineView(scheduledDoses: scheduledDoses)
    }
}

// MARK: - Performance Tests

extension MedicationEngineTestExamples {

    static func testPerformance() {
        print("\n⚡ Performance Test: Large medication list")

        // Create a large list of medications
        var medications: [Medication] = []
        for i in 0..<100 {
            let medication = Medication(
                name: "Medication \(i)",
                frequency: [.daily(times: [DateComponents(hour: 8 + (i % 12), minute: 0)])],
                duration: .days(30),
                dosage: "10mg",
                patient: .samplePatient
            )
            medications.append(medication)
        }

        let startTime = Date()
        let schedule = MedicationEngine.generateDailySchedule(from: medications)
        let endTime = Date()

        let totalDoses = schedule.values.reduce(0) { $0 + $1.count }
        let processingTime = endTime.timeIntervalSince(startTime)

        print("Performance results:")
        print("  Medications processed: \(medications.count)")
        print("  Doses generated: \(totalDoses)")
        print("  Processing time: \(String(format: "%.3f", processingTime))s")
    }
}