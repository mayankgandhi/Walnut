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
        List {
            // Active Medications Section
            if !activeMedications.isEmpty {
                Section {
                    ForEach(MealTime.allCases, id: \.self) { timePeriod in
                        if let medications = groupedActiveMedications()[timePeriod], !medications.isEmpty {
                            timePeriodSection(timePeriod: timePeriod, medications: medications)
                        }
                    }
                } header: {
                    HStack {
                        Image(systemName: "pills.fill")
                            .foregroundStyle(Color.healthSuccess)
                        Text("Active Medications")
                            .font(.headline)
                    }
                }
            }
            
            
            
            // Empty State
            if activeMedications.isEmpty {
                ContentUnavailableView(
                    "No Medications",
                    systemImage: "pills",
                    description: Text("Add medications to track dosages and schedules")
                )
                .listRowBackground(Color.clear)
            }
        }
        .navigationTitle("All Medications")
        .navigationBarTitleDisplayMode(.large)
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
            // Time Period Header
            HStack(spacing: Spacing.xs) {
                Image(systemName: timePeriod.icon)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(timePeriod.color)
                
                Text(timePeriod.rawValue)
                    .font(.system(.subheadline, design: .rounded, weight: .semibold))
                    .foregroundStyle(timePeriod.color)
                
                Spacer()
                
                Text("\(medications.count) medication\(medications.count == 1 ? "" : "s")")
                    .font(.system(.caption, design: .rounded))
                    .foregroundStyle(.secondary)
            }
            .padding(.vertical, Spacing.xs)
            
            // Medications in this time period
            VStack(spacing: Spacing.xs) {
                ForEach(medications, id: \.medication.id) { medicationInfo in
                    medicationScheduleRow(medicationInfo: medicationInfo)
                }
            }
        }
        .padding(.vertical, Spacing.xs)
    }
    
    @ViewBuilder
    private func medicationScheduleRow(medicationInfo: MedicationTracker.MedicationScheduleInfo) -> some View {
        HStack(spacing: Spacing.medium) {
            // Medication Icon
            OptionalView(medicationInfo.medication.name) { name in
                Circle()
                    .fill(medicationInfo.timePeriod.color.opacity(0.1))
                    .frame(width: 36, height: 36)
                    .overlay {
                        Text(String(name.prefix(1).uppercased()))
                            .font(.system(.caption, design: .rounded, weight: .bold))
                            .foregroundStyle(medicationInfo.timePeriod.color)
                    }
            }
            
            
            // Medication Details
            VStack(alignment: .leading, spacing: 2) {
                OptionalView(medicationInfo.medication.name) { name in
                    Text(name)
                        .font(.system(.body, design: .rounded, weight: .medium))
                        .foregroundStyle(.primary)
                }
                
                Text(medicationInfo.dosageText)
                    .font(.system(.caption, design: .rounded))
                    .foregroundStyle(.secondary)
                
                Text(medicationInfo.displayTime)
                    .font(.system(.caption2, design: .rounded))
                    .foregroundStyle(medicationInfo.timePeriod.color)
            }
            
            Spacer()
            
            // Edit button
            Button {
                medicationToEdit = medicationInfo.medication
                showMedicationEditor = true
            } label: {
                Image(systemName: "pencil.circle.fill")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(Color.healthPrimary)
            }
            .buttonStyle(.borderless)
        }
        .padding(.horizontal, Spacing.small)
        .padding(.vertical, Spacing.xs)
        .background(Color(.systemGray6).opacity(0.5))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
    
    @ViewBuilder
    private func medicationRow(medication: Medication, isActive: Bool) -> some View {
        HStack(spacing: Spacing.medium) {
            // Medication Icon
            if let name = medication.name {
                Circle()
                    .fill((isActive ? Color.healthSuccess : Color.secondary).opacity(0.1))
                    .frame(width: 36, height: 36)
                    .overlay {
                        Text(String(name.prefix(1).uppercased()))
                            .font(.system(.caption, design: .rounded, weight: .bold))
                            .foregroundStyle(isActive ? Color.healthSuccess : .secondary)
                    }
                
                
                // Medication Details
                VStack(alignment: .leading, spacing: 2) {
                    Text(name)
                        .font(.system(.body, design: .rounded, weight: .medium))
                        .foregroundStyle(isActive ? .primary : .secondary)
                    
                    if let dosage = medication.dosage {
                        Text(dosage)
                            .font(.system(.caption, design: .rounded))
                            .foregroundStyle(.secondary)
                    }
                }
            }

            Spacer()
            
            // Edit button
            Button {
                medicationToEdit = medication
                showMedicationEditor = true
            } label: {
                Image(systemName: "pencil.circle.fill")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(isActive ? Color.healthPrimary : .secondary)
            }
            .buttonStyle(.borderless)
        }
        .padding(.vertical, Spacing.xs)
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
