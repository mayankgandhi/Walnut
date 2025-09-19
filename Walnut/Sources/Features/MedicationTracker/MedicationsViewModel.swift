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

    // MARK: - Initialization

    init(patient: Patient, modelContext: ModelContext) {
        self.patient = patient
        self.modelContext = modelContext
    }
    
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
    }

    func handleMedicationSave(_ medication: Medication) {
        showingAddMedication = false
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
