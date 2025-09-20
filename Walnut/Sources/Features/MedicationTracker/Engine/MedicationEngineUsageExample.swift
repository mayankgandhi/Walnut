//
//  MedicationEngineUsageExample.swift
//  Walnut
//
//  Created by Mayank Gandhi on 20/09/25.
//  Copyright © 2025 m. All rights reserved.
//

import SwiftUI

/// Usage example showing how to integrate MedicationEngine with existing views
struct MedicationEngineUsageExample: View {

    // Sample medications (in real app, these would come from SwiftData)
    @State private var medications: [Medication] = [
        .sampleMedication,
        .complexMedication,
        .hourlyMedication
    ]

    var body: some View {
        NavigationView {
            VStack {
                Text("MedicationEngine Integration Example")
                    .font(.title2.weight(.semibold))
                    .padding()

                // This is the key integration point:
                // 1. Pass medications to MedicationEngine
                // 2. Get back [TimeSlot: [ScheduledDose]]
                // 3. Pass directly to MedicationTimelineView

                ScrollView {
                    MedicationTimelineView(
                        scheduledDoses: MedicationEngine.generateDailySchedule(
                            from: medications,
                            for: Date()
                        )
                    )
                }
                .refreshable {
                    // Refresh the view when user pulls to refresh
                    // The engine will regenerate the schedule
                }

                Spacer()

                // Button to add test medication
                Button("Add Test Medication") {
                    addTestMedication()
                }
                .buttonStyle(.borderedProminent)
                .padding()
            }
            .navigationTitle("Daily Schedule")
        }
    }

    private func addTestMedication() {
        let newMedication = Medication(
            name: "Test Medicine \(medications.count + 1)",
            frequency: [
                .daily(times: [DateComponents(hour: Int.random(in: 8...20), minute: 0)]),
                .mealBased(mealTime: .lunch, timing: .before)
            ],
            duration: .days(7),
            dosage: "25mg",
            patient: .samplePatient
        )
        medications.append(newMedication)
    }
}

// MARK: - ViewModel Integration Example

/// Example of how to use MedicationEngine in a ViewModel
class MedicationScheduleViewModel: ObservableObject {

    @Published var scheduledDoses: [TimeSlot: [ScheduledDose]] = [:]
    @Published var nextUpcomingDose: ScheduledDose?

    private var medications: [Medication] = []

    func loadMedications(_ medications: [Medication]) {
        self.medications = medications
        refreshSchedule()
    }

    func refreshSchedule(for date: Date = Date()) {
        // Use MedicationEngine to generate the schedule
        scheduledDoses = MedicationEngine.generateDailySchedule(
            from: medications,
            for: date
        )

        // Calculate next upcoming dose
        nextUpcomingDose = MedicationEngine.getNextUpcomingDose(
            from: medications,
            after: Date()
        )
    }

    var totalDosesForToday: Int {
        scheduledDoses.values.reduce(0) { $0 + $1.count }
    }

    var upcomingDoseText: String {
        guard let nextDose = nextUpcomingDose else {
            return "No upcoming doses"
        }
        return "Next: \(nextDose.medication.name ?? "Unknown") at \(nextDose.displayTime)"
    }
}

// MARK: - SwiftData Integration Example

/// Example showing how to integrate with SwiftData
struct MedicationEngineSwiftDataExample: View {

    // In real app, this would be @Query from SwiftData
    // @Query private var medications: [Medication]

    // For demo purposes, using sample data
    private let medications: [Medication] = [
        .sampleMedication,
        .complexMedication,
        .weeklyMedication
    ]

    var body: some View {
        VStack {
            Text("Today's Medications")
                .font(.title.weight(.bold))
                .padding()

            // Direct integration: medications → engine → timeline view
            MedicationTimelineView(
                scheduledDoses: MedicationEngine.generateDailySchedule(from: medications)
            )

            // Additional features using the engine
            VStack(alignment: .leading, spacing: 8) {
                if let nextDose = MedicationEngine.getNextUpcomingDose(from: medications) {
                    Text("Next dose: \(nextDose.medication.name ?? "Unknown") at \(nextDose.displayTime)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                let totalDoses = MedicationEngine.generateDailySchedule(from: medications)
                    .values.reduce(0) { $0 + $1.count }

                Text("\(totalDoses) doses scheduled for today")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding()
        }
    }
}

#Preview {
    MedicationEngineUsageExample()
}