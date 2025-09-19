//
//  MedicationsService.swift
//  Walnut
//
//  Created by Mayank Gandhi on 19/09/25.
//  Copyright © 2025 m. All rights reserved.
//

import Foundation
import SwiftData
import SwiftUI

/// Observable service managing medications data and operations for a specific patient
@Observable
class MedicationsService {

    // MARK: - Properties

    /// The patient this service is managing medications for
    let patient: Patient

    /// Current active medications (computed from SwiftData queries)
    private(set) var activeMedications: [Medication] = []

    /// Schedule service for timeline management
    let scheduleService: MedicationScheduleService

    /// Error state
    private(set) var errorMessage: String?

    // MARK: - Initialization

    init(patient: Patient) {
        self.patient = patient
        self.scheduleService = MedicationScheduleService()
    }

    // MARK: - Public Methods

    /// Update the medications list and refresh schedule
    func updateMedications(_ prescriptions: [Prescription], _ directMedications: [Medication]) {
        let activePrescriptions = prescriptions.filter { prescription in
            guard let medicalCase = prescription.medicalCase else { return false }
            return medicalCase.patient?.id == patient.id && (medicalCase.isActive ?? false)
        }

        let prescriptionMedications = activePrescriptions.compactMap { $0.medications }.reduce([], +)

        // Include medications directly associated with the patient (not through prescriptions)
        let patientDirectMedications = directMedications.filter { medication in
            medication.patient?.id == patient.id && medication.prescription == nil
        }

        activeMedications = prescriptionMedications + patientDirectMedications

        // Update schedule service
        scheduleService.updateMedications(activeMedications)
    }

    /// Save a medication update
    func saveMedication(_ medication: Medication, in prescriptions: [Prescription], using modelContext: ModelContext) async throws {
        // Find and update the prescription containing this medication
        let relevantPrescriptions = prescriptions.filter { prescription in
            prescription.medications?.contains(where: { $0.id == medication.id }) == true
        }

        for prescription in relevantPrescriptions {
            if let medicationIndex = prescription.medications?.firstIndex(where: { $0.id == medication.id }) {
                prescription.medications?[medicationIndex] = medication
                prescription.updatedAt = Date()

                try modelContext.save()
                return
            }
        }
    }

    /// Save a new medication
    func saveNewMedication(_ medication: Medication, using modelContext: ModelContext) async throws {
        modelContext.insert(medication)
        try modelContext.save()
    }

    /// Set error message
    func setError(_ message: String) {
        errorMessage = message
    }

    /// Clear error message
    func clearError() {
        errorMessage = nil
    }
}