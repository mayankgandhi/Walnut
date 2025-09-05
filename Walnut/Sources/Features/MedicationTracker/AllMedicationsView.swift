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
    @Environment(\.modelContext) private var modelContext
    @State private var medicationTracker = MedicationTracker()
    @State private var showMedicationEditor = false
    @State private var medicationToEdit: Medication? = nil
    @State private var groupedMedications: [MealTime: [MedicationTracker.MedicationScheduleInfo]] = [:]
    
    // SwiftData query for active prescriptions to automatically update UI
    @Query private var allPrescriptions: [Prescription]
    
    // Computed property optimized with caching
    private var activeMedications: [Medication] {
        // Filter for active medical cases and get their prescriptions
        let activePrescriptions = allPrescriptions.filter { prescription in
            guard let medicalCase = prescription.medicalCase else { return false }
            return medicalCase.patient?.id == patient.id && (medicalCase.isActive ?? false)
        }
        
        // Flatten medications from active prescriptions
        return activePrescriptions.compactMap { $0.medications }.reduce([], +)
    }
    
    // Background task for grouping medications
    @MainActor
    private func updateGroupedMedications() {
        Task {
            let medications = activeMedications
            let grouped = await withTaskGroup(of: (MealTime, [MedicationTracker.MedicationScheduleInfo]).self) { group in
                var result: [MealTime: [MedicationTracker.MedicationScheduleInfo]] = [:]
                
                for mealTime in MealTime.allCases {
                    group.addTask {
                        let filteredInfo = await medicationTracker.getMedicationInfoForMealTime(medications, mealTime: mealTime)
                        return (mealTime, filteredInfo)
                    }
                }
                
                for await (mealTime, infos) in group {
                    result[mealTime] = infos
                }
                
                return result
            }
            
            groupedMedications = grouped
        }
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Spacing.medium) {
                // Active Medications Section
                if !groupedMedications.isEmpty {
                    ForEach(MealTime.allCases, id: \.self) { timePeriod in
                        if let medications = groupedMedications[timePeriod],
                         !medications.isEmpty {
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
        .onAppear {
            updateGroupedMedications()
        }
        .onChange(of: allPrescriptions) { _, _ in
            updateGroupedMedications()
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
        MedicationCard(medication: medicationInfo.medication)
    }
    
    private func handleMedicationSave(_ medication: Medication) {
        Task { @MainActor in
            // Find the prescription that contains this medication and update it
            let relevantPrescriptions = allPrescriptions.filter { prescription in
                prescription.medications?.contains(where: { $0.id == medication.id }) == true
            }
            
            for prescription in relevantPrescriptions {
                if let medicationIndex = prescription.medications?.firstIndex(where: { $0.id == medication.id }) {
                    // Update the medication in the prescription using SwiftData
                    prescription.medications?[medicationIndex] = medication
                    prescription.updatedAt = Date()
                    
                    // Save context
                    do {
                        try modelContext.save()
                        // UI will automatically update due to @Query
                    } catch {
                        print("Error saving medication: \(error)")
                    }
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
