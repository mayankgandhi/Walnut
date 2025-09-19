//
//  MedicationsViewModel.swift
//  Walnut
//
//  Created by Mayank Gandhi on 19/09/25.
//  Copyright © 2025 m. All rights reserved.
//

import Foundation
import SwiftUI
import SwiftData

@Observable
class MedicationsViewModel {

    // MARK: - Properties

    let patient: Patient
    private let modelContext: ModelContext

    // UI State
    var showingAddMedication = false
    var showingMedicationsList = false
    var medicationToEdit: Medication?
    var errorMessage: String?
    var showingError = false

    // Data
    var allPrescriptions: [Prescription] = []
    var allMedications: [Medication] = []

    // MARK: - Computed Properties

    var activeMedications: [Medication] {
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

    var todaysActiveMedications: [Medication] {
        // Filter medications that should be shown for today
        // This is a simple filter - could be enhanced with more complex scheduling logic
        return activeMedications.filter { medication in
            // Include all active medications for now
            // In the future, this could filter based on scheduling, duration, etc.
            return true
        }
    }

    // MARK: - Initialization

    init(patient: Patient, modelContext: ModelContext) {
        self.patient = patient
        self.modelContext = modelContext
    }

    // MARK: - Data Management

    func refreshData() {
        fetchPrescriptions()
        fetchMedications()
    }

    private func fetchPrescriptions() {
        let descriptor = FetchDescriptor<Prescription>()
        do {
            allPrescriptions = try modelContext.fetch(descriptor)
        } catch {
            handleError("Failed to fetch prescriptions: \(error.localizedDescription)")
        }
    }

    private func fetchMedications() {
        let descriptor = FetchDescriptor<Medication>()
        do {
            allMedications = try modelContext.fetch(descriptor)
        } catch {
            handleError("Failed to fetch medications: \(error.localizedDescription)")
        }
    }

    // MARK: - Actions

    func showAddMedication() {
        showingAddMedication = true
    }

    func showMedicationsList() {
        showingMedicationsList = true
    }

    func editMedication(_ medication: Medication) {
        medicationToEdit = medication
    }

    func handleNewMedicationSave(_ medication: Medication) {
        showingAddMedication = false
        refreshData()
    }

    func handleMedicationSave(_ medication: Medication) {
        // Find and update the prescription containing this medication
        let relevantPrescriptions = allPrescriptions.filter { prescription in
            prescription.medications?.contains(where: { $0.id == medication.id }) == true
        }

        for prescription in relevantPrescriptions {
            if let medicationIndex = prescription.medications?.firstIndex(where: { $0.id == medication.id }) {
                prescription.medications?[medicationIndex] = medication
                prescription.updatedAt = Date()

                do {
                    try modelContext.save()
                    refreshData()
                    return
                } catch {
                    handleError("Failed to update medication: \(error.localizedDescription)")
                    return
                }
            }
        }
    }

    func dismissMedicationsList() {
        showingMedicationsList = false
    }

    func handleMedicationEdit(from list: Medication) {
        showingMedicationsList = false
        medicationToEdit = list
    }

    // MARK: - Error Handling

    private func handleError(_ message: String) {
        errorMessage = message
        showingError = true
        print("MedicationsViewModel Error: \(message)")
    }

    func clearError() {
        errorMessage = nil
        showingError = false
    }
}
