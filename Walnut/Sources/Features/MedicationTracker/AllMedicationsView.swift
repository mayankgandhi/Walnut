//
//  AllMedicationsView.swift
//  Walnut
//
//  Created by Mayank Gandhi on 11/08/25.
//  Copyright © 2025 m. All rights reserved.
//

import SwiftUI
import SwiftData
import WalnutDesignSystem

struct AllMedicationsView: View {
    
    let patient: Patient
    @State private var medicationTracker = MedicationTracker()
    @State private var showMedicationEditor = false
    @State private var medicationToEdit: Medication? = nil
    
    private var activeMedications: [Medication] {
        let activeMedicalCases = patient.medicalCases?
            .filter { $0.isActive ?? false }
        let activeMedicalCasesPrescriptions: [Prescription] = (activeMedicalCases ?? []).compactMap(\.prescriptions)
            .reduce([], +)
        let activeMedications: [Medication] = activeMedicalCasesPrescriptions
            .compactMap(\.medications).reduce([], +)
        return activeMedications
    }
    
    private func groupedActiveMedications() -> [MealTime: [MedicationTracker.MedicationScheduleInfo]] {
        medicationTracker.groupMedicationsByMealTime(activeMedications)
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Spacing.medium) {
                // Active Medications Section
                if !activeMedications.isEmpty {
                    ForEach(MealTime.allCases, id: \.self) { timePeriod in
                        if let medications = groupedActiveMedications()[timePeriod], !medications.isEmpty {
                            timePeriodSection(timePeriod: timePeriod, medications: medications)
                        }
                    }
                } else {
                    ContentUnavailableView(
                        "No Medications",
                        systemImage: "pills",
                        description: Text("Add medications to track dosages and schedules")
                    )
                    .listRowBackground(Color.clear)
                }
            }
            .padding(.horizontal, Spacing.medium)
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    medicationToEdit = nil
                    showMedicationEditor = true
                } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 16, weight: .semibold))
                }
            }
        }
        .sheet(isPresented: $showMedicationEditor) {
            MedicationEditor(
                medication: medicationToEdit,
                onSave: handleMedicationSave
            )
        }
    }
    
    @ViewBuilder
    private func timePeriodSection(
        timePeriod: MealTime,
        medications: [MedicationTracker.MedicationScheduleInfo]
    ) -> some View {
        VStack(alignment: .leading, spacing: Spacing.small) {
            HealthCardHeader(
                iconName: timePeriod.iconString,
                title: "\(timePeriod.displayName) Medications",
                subtitle: "\(medications.count) medication\(medications.count == 1 ? "" : "s")"
            )
            
            LazyVGrid(
                columns: [.init(), .init()],
                spacing: Spacing.small
            ) {
                ForEach(medications) { medicationInfo in
                    medicationScheduleRow(medicationInfo: medicationInfo)
                }
            }
        }
    }
    
    @ViewBuilder
    private func medicationScheduleRow(medicationInfo: MedicationTracker.MedicationScheduleInfo) -> some View {
        MedicationCard(
            medicationName: medicationInfo.medication.name ?? "Medication",
            dosage: medicationInfo.dosageText,
            timing: medicationInfo.displayTime,
            timePeriod: medicationInfo.timePeriod,
            accentColor: medicationInfo.timePeriod.color,
        )
    }
    
    private func handleMedicationSave(_ medication: Medication) {
        // Find the prescription that contains this medication and update it
        for medicalCase in patient.medicalCases ?? [] {
            for prescription in medicalCase.prescriptions ?? [] {
                if let medicationIndex = prescription.medications?.firstIndex(
                    where: { $0.id == medication.id
                    }) {
                    // Update the medication in the prescription
                    prescription.medications?[medicationIndex] = medication
                    prescription.updatedAt = Date()
                    return
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        AllMedicationsView(patient: .samplePatient)
    }
    .modelContainer(for: Patient.self, inMemory: true)
}
