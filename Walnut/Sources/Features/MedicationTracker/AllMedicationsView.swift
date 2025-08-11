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
    @State private var showAddMedication = false
    
    private var activeMedications: [Medication] {
        patient.medicalCases.flatMap { $0.prescriptions.flatMap { $0.medications } }
            .filter { $0.isActive }
    }
    
    private var inactiveMedications: [Medication] {
        patient.medicalCases.flatMap { $0.prescriptions.flatMap { $0.medications } }
            .filter { !$0.isActive }
    }
    
    private var groupedActiveMedications: [MedicationTracker.TimePeriod: [MedicationTracker.MedicationScheduleInfo]] {
        medicationTracker.groupMedicationsByTimePeriod(activeMedications)
    }
    
    var body: some View {
        List {
            // Active Medications Section
            if !activeMedications.isEmpty {
                Section {
                    ForEach(MedicationTracker.TimePeriod.allCases, id: \.self) { timePeriod in
                        if let medications = groupedActiveMedications[timePeriod], !medications.isEmpty {
                            timePeriodSection(timePeriod: timePeriod, medications: medications)
                        }
                    }
                } header: {
                    HStack {
                        Image(systemName: "pills.fill")
                            .foregroundStyle(.healthSuccess)
                        Text("Active Medications")
                            .font(.headline)
                    }
                }
            }
            
            // Inactive Medications Section
            if !inactiveMedications.isEmpty {
                Section {
                    ForEach(inactiveMedications) { medication in
                        medicationRow(medication: medication, isActive: false)
                    }
                } header: {
                    HStack {
                        Image(systemName: "pause.circle.fill")
                            .foregroundStyle(.secondary)
                        Text("Inactive Medications")
                            .font(.headline)
                    }
                }
            }
            
            // Empty State
            if activeMedications.isEmpty && inactiveMedications.isEmpty {
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
                    showAddMedication = true
                } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 16, weight: .semibold))
                }
            }
        }
        .sheet(isPresented: $showAddMedication) {
            // TODO: Add MedicationEditor sheet
            Text("Add Medication")
        }
    }
    
    @ViewBuilder
    private func timePeriodSection(
        timePeriod: MedicationTracker.TimePeriod,
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
            Circle()
                .fill(medicationInfo.timePeriod.color.opacity(0.1))
                .frame(width: 36, height: 36)
                .overlay {
                    Text(String(medicationInfo.medication.name.prefix(1).uppercased()))
                        .font(.system(.caption, design: .rounded, weight: .bold))
                        .foregroundStyle(medicationInfo.timePeriod.color)
                }
            
            // Medication Details
            VStack(alignment: .leading, spacing: 2) {
                Text(medicationInfo.medication.name)
                    .font(.system(.body, design: .rounded, weight: .medium))
                    .foregroundStyle(.primary)
                
                Text(medicationInfo.dosageText)
                    .font(.system(.caption, design: .rounded))
                    .foregroundStyle(.secondary)
                
                Text(medicationInfo.displayTime)
                    .font(.system(.caption2, design: .rounded))
                    .foregroundStyle(medicationInfo.timePeriod.color)
            }
            
            Spacer()
            
            // Status Indicator
            Circle()
                .fill(.healthSuccess)
                .frame(width: 8, height: 8)
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
            Circle()
                .fill((isActive ? Color.healthSuccess : Color.secondary).opacity(0.1))
                .frame(width: 36, height: 36)
                .overlay {
                    Text(String(medication.name.prefix(1).uppercased()))
                        .font(.system(.caption, design: .rounded, weight: .bold))
                        .foregroundStyle(isActive ? .healthSuccess : .secondary)
                }
            
            // Medication Details
            VStack(alignment: .leading, spacing: 2) {
                Text(medication.name)
                    .font(.system(.body, design: .rounded, weight: .medium))
                    .foregroundStyle(isActive ? .primary : .secondary)
                
                if let dosage = medication.dosage {
                    Text(dosage)
                        .font(.system(.caption, design: .rounded))
                        .foregroundStyle(.secondary)
                }
            }
            
            Spacer()
            
            // Status Indicator
            Circle()
                .fill(isActive ? .healthSuccess : .secondary)
                .frame(width: 8, height: 8)
        }
        .padding(.vertical, Spacing.xs)
    }
}

#Preview {
    NavigationStack {
        AllMedicationsView(patient: .samplePatient)
    }
    .modelContainer(for: Patient.self, inMemory: true)
}