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
            // Fetch all medications for this specific patient
            let descriptor = FetchDescriptor<Medication>()
            let allMedications = try modelContext.fetch(descriptor)

            // Filter medications that belong to this patient
            let patientMedications = allMedications.filter { medication in
                if let patientID = medication.patient?.id {
                    return patientID == patient.id
                } else if let medicalCase = medication.prescription?.medicalCase {
                    return medicalCase.patient?.id == patient.id && (medicalCase.isActive ?? true)
                } else {
                    return false
                }
            }

            // Use MedicationEngine to filter only active/ongoing medications
            activeMedications = MedicationEngine.filterActiveMedications(from: patientMedications)

            // Sort by medication name for consistent display
            activeMedications.sort { ($0.name ?? "") < ($1.name ?? "") }

        } catch {
            errorMessage = "Failed to load medications: \(error.localizedDescription)"
        }

        isLoading = false
    }

    func isOngoing(medication: Medication) -> Bool {
        // Use MedicationEngine for consistent activity determination
        return MedicationEngine.isMedicationActive(medication)
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

