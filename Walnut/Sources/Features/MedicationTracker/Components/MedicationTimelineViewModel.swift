//
//  MedicationTimelineViewModel.swift
//  Walnut
//
//  Created by Mayank Gandhi on 19/09/25.
//  Copyright © 2025 m. All rights reserved.
//

import Foundation
import SwiftUI
import SwiftData

@Observable
class MedicationTimelineViewModel {

    // MARK: - Properties

    let patient: Patient
    private let modelContext: ModelContext

    // Data
    var allPrescriptions: [Prescription] = []
    var allMedications: [Medication] = []

    // Computed scheduled doses organized by time slot
    var scheduledDoses: [TimeSlot: [ScheduledDose]] = [:]

    // MARK: - Initialization

    init(patient: Patient, modelContext: ModelContext) {
        self.patient = patient
        self.modelContext = modelContext
        refreshData()
    }

    // MARK: - Data Management

    func refreshData() {
        fetchPrescriptions()
        fetchMedications()
        generateScheduledDoses()
    }

    private func fetchPrescriptions() {
        let descriptor = FetchDescriptor<Prescription>()
        do {
            allPrescriptions = try modelContext.fetch(descriptor)
        } catch {
            print("Failed to fetch prescriptions: \(error.localizedDescription)")
        }
    }

    private func fetchMedications() {
        let descriptor = FetchDescriptor<Medication>()
        do {
            allMedications = try modelContext.fetch(descriptor)
        } catch {
            print("Failed to fetch medications: \(error.localizedDescription)")
        }
    }

    // MARK: - Scheduled Doses Logic

    private func generateScheduledDoses() {
        let activeMedications = getActiveMedications()

        // Use MedicationEngine to generate the schedule
        self.scheduledDoses = MedicationEngine.generateDailySchedule(from: activeMedications)
    }

    private func getActiveMedications() -> [Medication] {
        let prescriptionMedications = prescriptionBasedMedications
        let directMedications = patientDirectMedications
        return prescriptionMedications + directMedications
    }

    private var prescriptionBasedMedications: [Medication] {
        let activePrescriptions = allPrescriptions.filter { prescription in
            guard let medicalCase = prescription.medicalCase else { return false }
            return medicalCase.patient?.id == patient.id && (medicalCase.isActive ?? false)
        }
        return activePrescriptions.compactMap { $0.medications }.reduce([], +)
    }

    private var patientDirectMedications: [Medication] {
        return allMedications.filter { medication in
            medication.patient?.id == patient.id && medication.prescription == nil
        }
    }

    // MARK: - Additional Computed Properties

    /// Total number of doses scheduled for today
    var totalDosesForToday: Int {
        scheduledDoses.values.reduce(0) { $0 + $1.count }
    }

    /// Next upcoming dose after current time
    var nextUpcomingDose: ScheduledDose? {
        let activeMedications = getActiveMedications()
        return MedicationEngine.getNextUpcomingDose(from: activeMedications)
    }

    /// Description of next upcoming dose
    var nextUpcomingDoseDescription: String {
        guard let nextDose = nextUpcomingDose else {
            return "No upcoming doses today"
        }
        return "Next: \(nextDose.medication.name ?? "Unknown") at \(nextDose.displayTime)"
    }

    // MARK: - Additional Methods

    /// Refresh schedule for a specific date
    func refreshSchedule(for date: Date = Date()) {
        let activeMedications = getActiveMedications()
        self.scheduledDoses = MedicationEngine.generateDailySchedule(from: activeMedications, for: date)
    }

    /// Get schedule for multiple days
    func getMultiDaySchedule(startDate: Date, numberOfDays: Int) -> [Date: [TimeSlot: [ScheduledDose]]] {
        let activeMedications = getActiveMedications()
        return MedicationEngine.generateMultiDaySchedule(
            from: activeMedications,
            startDate: startDate,
            numberOfDays: numberOfDays
        )
    }

}
