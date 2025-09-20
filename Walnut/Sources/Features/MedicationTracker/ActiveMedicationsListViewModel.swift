//
//  ActiveMedicationsListViewModel.swift
//  Walnut
//
//  Created by Mayank Gandhi on 19/09/25.
//  Copyright © 2025 m. All rights reserved.
//

import Foundation
import SwiftUI
import SwiftData

@Observable
class ActiveMedicationsListViewModel {

    private let modelContext: ModelContext
    private let patient: Patient
    var activeMedications: [Medication] = []
    var isLoading = false
    var errorMessage: String?

    init(modelContext: ModelContext, patient: Patient) {
        self.modelContext = modelContext
        self.patient = patient
    }

    @MainActor
    func loadActiveMedications() {
        isLoading = true
        errorMessage = nil

        do {
            // Fetch all medications for this specific patient from active medical cases
            let descriptor = FetchDescriptor<Medication>()
            let allMedications = try modelContext.fetch(descriptor)

            // Filter medications that belong to this patient and are from active medical cases
            activeMedications = allMedications.filter { medication in
                if let patientID = medication.patient?.id {
                    return patientID == patient.id
                } else if let medicalCase = medication.prescription?.medicalCase {
                    return medicalCase.isActive ?? true
                } else {
                    return true
                }
            }

            // Sort by medication name for consistent display
            activeMedications.sort { ($0.name ?? "") < ($1.name ?? "") }

        } catch {
            errorMessage = "Failed to load medications: \(error.localizedDescription)"
        }

        isLoading = false
    }

    func isOngoing(medication: Medication) -> Bool {
        guard let duration = medication.duration else { return false }

        switch duration {
        case .ongoing, .asNeeded, .untilFollowUp:
            return true
        case .days(let days):
            guard let prescription = medication.prescription,
                  let dateIssued = prescription.dateIssued else { return false }
            let endDate = Calendar.current.date(byAdding: .day, value: days, to: dateIssued) ?? dateIssued
            return endDate > Date()
        case .weeks(let weeks):
            guard let prescription = medication.prescription,
                  let dateIssued = prescription.dateIssued else { return false }
            let endDate = Calendar.current.date(byAdding: .weekOfYear, value: weeks, to: dateIssued) ?? dateIssued
            return endDate > Date()
        case .months(let months):
            guard let prescription = medication.prescription,
                  let dateIssued = prescription.dateIssued else { return false }
            let endDate = Calendar.current.date(byAdding: .month, value: months, to: dateIssued) ?? dateIssued
            return endDate > Date()
        }
    }

    func medicationStatus(for medication: Medication) -> MedicationStatus {
        if isOngoing(medication: medication) {
            return .active
        } else {
            return .completed
        }
    }
    
    struct MedicationKey: Hashable {
        let medicalCaseName: String
        let medicationSpecialty: MedicalSpecialty?
        
        init(medicalCaseName: String, medicationSpecialty: MedicalSpecialty?) {
            self.medicalCaseName = medicalCaseName
            self.medicationSpecialty = medicationSpecialty
        }
    }

    func groupedMedications() -> [MedicationKey: [Medication]] {
        return Dictionary(grouping: activeMedications) { medication in
            guard let medicalCase = medication.prescription?.medicalCase,
                  let title = medicalCase.title else {
                return MedicationKey(
                    medicalCaseName: "Other",
                    medicationSpecialty: nil
                )
            }
            return MedicationKey(
                    medicalCaseName: title,
                    medicationSpecialty: medicalCase.specialty
                )
        }
    }
}

enum MedicationStatus {
    case active
    case completed

    var color: Color {
        switch self {
        case .active:
            return .healthSuccess
        case .completed:
            return .secondary
        }
    }

    var displayText: String {
        switch self {
        case .active:
            return "Active"
        case .completed:
            return "Completed"
        }
    }
}

