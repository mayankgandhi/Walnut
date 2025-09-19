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
        var dosesByTimeSlot: [TimeSlot: [ScheduledDose]] = [:]

        for medication in activeMedications {
            let doses = generateDosesForMedication(medication)

            for dose in doses {
                if dosesByTimeSlot[dose.timeSlot] == nil {
                    dosesByTimeSlot[dose.timeSlot] = []
                }
                dosesByTimeSlot[dose.timeSlot]?.append(dose)
            }
        }

        // Sort doses within each time slot by scheduled time
        for timeSlot in TimeSlot.allCases {
            dosesByTimeSlot[timeSlot]?.sort { $0.scheduledTime < $1.scheduledTime }
        }

        self.scheduledDoses = dosesByTimeSlot
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

    private func generateDosesForMedication(_ medication: Medication) -> [ScheduledDose] {
        var doses: [ScheduledDose] = []

        guard let frequency = medication.frequency, !frequency.isEmpty else {
            // If no frequency specified, create a single morning dose
            let morningTime = Calendar.current.date(bySettingHour: 8, minute: 0, second: 0, of: Date()) ?? Date()
            let dose = ScheduledDose(
                medication: medication,
                scheduledTime: morningTime,
                timeSlot: .morning,
                mealRelation: determineMealRelation(for: medication, timeSlot: .morning)
            )
            doses.append(dose)
            return doses
        }

        // Generate doses based on frequency
        let numberOfDoses = frequency.count
        let doseTimes = generateDoseTimesForFrequency(numberOfDoses)

        for (index, doseTime) in doseTimes.enumerated() {
            let timeSlot = determineTimeSlot(for: doseTime)
            let dose = ScheduledDose(
                medication: medication,
                scheduledTime: doseTime,
                timeSlot: timeSlot,
                mealRelation: determineMealRelation(for: medication, timeSlot: timeSlot)
            )
            doses.append(dose)
        }

        return doses
    }

    private func generateDoseTimesForFrequency(_ numberOfDoses: Int) -> [Date] {
        let calendar = Calendar.current
        let today = Date()
        var doseTimes: [Date] = []

        switch numberOfDoses {
        case 1:
            // Once daily - morning
            if let time = calendar.date(bySettingHour: 8, minute: 0, second: 0, of: today) {
                doseTimes.append(time)
            }
        case 2:
            // Twice daily - morning and evening
            if let morning = calendar.date(bySettingHour: 8, minute: 0, second: 0, of: today),
               let evening = calendar.date(bySettingHour: 20, minute: 0, second: 0, of: today) {
                doseTimes.append(contentsOf: [morning, evening])
            }
        case 3:
            // Three times daily - morning, afternoon, evening
            if let morning = calendar.date(bySettingHour: 8, minute: 0, second: 0, of: today),
               let afternoon = calendar.date(bySettingHour: 14, minute: 0, second: 0, of: today),
               let evening = calendar.date(bySettingHour: 20, minute: 0, second: 0, of: today) {
                doseTimes.append(contentsOf: [morning, afternoon, evening])
            }
        case 4:
            // Four times daily - morning, midday, afternoon, evening
            if let morning = calendar.date(bySettingHour: 8, minute: 0, second: 0, of: today),
               let midday = calendar.date(bySettingHour: 12, minute: 0, second: 0, of: today),
               let afternoon = calendar.date(bySettingHour: 16, minute: 0, second: 0, of: today),
               let evening = calendar.date(bySettingHour: 20, minute: 0, second: 0, of: today) {
                doseTimes.append(contentsOf: [morning, midday, afternoon, evening])
            }
        default:
            // For more than 4 doses, distribute evenly throughout the day
            let hoursInterval = 24.0 / Double(numberOfDoses)
            for i in 0..<numberOfDoses {
                let hour = Int(8.0 + (Double(i) * hoursInterval)) % 24
                if let time = calendar.date(bySettingHour: hour, minute: 0, second: 0, of: today) {
                    doseTimes.append(time)
                }
            }
        }

        return doseTimes
    }

    private func determineTimeSlot(for date: Date) -> TimeSlot {
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: date)

        switch hour {
        case 6..<11:
            return .morning
        case 11..<14:
            return .midday
        case 14..<17:
            return .afternoon
        case 17..<21:
            return .evening
        default:
            return .night
        }
    }

    private func determineMealRelation(for medication: Medication, timeSlot: TimeSlot) -> MealRelation? {
        // This is a simplified implementation - could be enhanced with medication-specific meal requirements
        guard let instructions = medication.instructions?.lowercased() else { return nil }

        if instructions.contains("with food") || instructions.contains("after meal") {
            switch timeSlot {
            case .morning:
                return MealRelation(mealTime: .breakfast, timing: .after, offsetMinutes: 0)
            case .midday:
                return MealRelation(mealTime: .lunch, timing: .after, offsetMinutes: 0)
            case .afternoon, .evening:
                return MealRelation(mealTime: .dinner, timing: .after, offsetMinutes: 0)
            case .night:
                return nil
            }
        } else if instructions.contains("before meal") || instructions.contains("on empty stomach") {
            switch timeSlot {
            case .morning:
                return MealRelation(mealTime: .breakfast, timing: .before, offsetMinutes: -30)
            case .midday:
                return MealRelation(mealTime: .lunch, timing: .before, offsetMinutes: -30)
            case .afternoon, .evening:
                return MealRelation(mealTime: .dinner, timing: .before, offsetMinutes: -30)
            case .night:
                return nil
            }
        }

        return nil
    }
}
