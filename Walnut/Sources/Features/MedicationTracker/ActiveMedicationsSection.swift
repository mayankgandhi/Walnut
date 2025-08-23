//
//  ActiveMedicationsSection.swift
//  Walnut
//
//  Created by Mayank Gandhi on 01/08/25.
//  Copyright © 2025 m. All rights reserved.
//

import SwiftUI
import WalnutDesignSystem

struct ActiveMedicationsSection: View {
    
    let patient: Patient
    
    @Environment(\.modelContext) private var modelContext
    @State private var activeMedications: [Medication] = []
    @State private var medicationTracker = MedicationTracker()
    
    private var groupedMedications: [MedicationTracker.TimePeriod: [MedicationTracker.MedicationScheduleInfo]] {
        medicationTracker.groupMedicationsByTimePeriod(activeMedications)
    }
    
    var body: some View {
        Section {
            if activeMedications.isEmpty {
                emptyStateView
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
            } else {
                // Time Period Groups
                ForEach(MedicationTracker.TimePeriod.allCases, id: \.self) { timePeriod in
                    if let medicationsForPeriod = groupedMedications[timePeriod], !medicationsForPeriod.isEmpty {
                        timePeriodSection(timePeriod: timePeriod, medications: medicationsForPeriod)
                            .listRowBackground(Color.clear)
                            .listRowSeparator(.hidden)
                            .listRowInsets(EdgeInsets(top: Spacing.xs, leading: 0, bottom: Spacing.xs, trailing: 0))
                    }
                }
            }
        } header: {
            sectionHeaderView
        }
        .onAppear {
            loadActiveMedications()
        }
    }
    
    // MARK: - Subviews
    
    private var sectionHeaderView: some View {
        HStack(spacing: Spacing.small) {
            Image(systemName: "pills.fill")
                .font(.headline)
                .foregroundStyle(Color.healthSuccess)
            
            Text("Active Medications")
                .font(.headline.weight(.semibold))
            
            Spacer()
            
            if !activeMedications.isEmpty {
                Text("\(activeMedications.count) medication\(activeMedications.count == 1 ? "" : "s")")
                    .font(.caption.weight(.medium))
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, Spacing.small)
                    .padding(.vertical, Spacing.xs)
                    .background(Color.healthSuccess.opacity(0.1))
                    .clipShape(Capsule())
            }
        }
    }
    
    private var emptyStateView: some View {
        HealthCard {
            VStack(spacing: Spacing.medium) {
                Circle()
                    .fill(Color.secondary.opacity(0.15))
                    .frame(width: Size.avatarLarge, height: Size.avatarLarge)
                    .overlay {
                        Image(systemName: "pills.fill")
                            .font(.system(size: 24, weight: .semibold))
                            .foregroundStyle(.secondary)
                    }
                
                VStack(spacing: Spacing.xs) {
                    Text("No Active Medications")
                        .font(.headline.weight(.semibold))
                        .foregroundStyle(.primary)
                    
                    Text("This patient has no active medications")
                        .font(.body)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
            }
            .frame(maxWidth: .infinity)
        }
    }
    
    private func timePeriodSection(timePeriod: MedicationTracker.TimePeriod, medications: [MedicationTracker.MedicationScheduleInfo]) -> some View {
        HealthCard {
            VStack(alignment: .leading, spacing: Spacing.medium) {
                // Time Period Header
                HStack(spacing: Spacing.small) {
                    Circle()
                        .fill(mapToDesignSystemTimePeriod(timePeriod).color.opacity(0.15))
                        .frame(width: Size.avatarMedium, height: Size.avatarMedium)
                        .overlay {
                            Image(systemName: mapToDesignSystemTimePeriod(timePeriod).icon)
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundStyle(mapToDesignSystemTimePeriod(timePeriod).color)
                        }
                    
                    VStack(alignment: .leading, spacing: Spacing.xs) {
                        Text(mapToDesignSystemTimePeriod(timePeriod).displayName)
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.primary)
                        
                        Text("\(medications.count) medication\(medications.count == 1 ? "" : "s")")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    
                    Spacer()
                    
                    WalnutDesignSystem.StatusIndicator(status: .good, showIcon: false)
                }
                
                // Medications in this time period
                VStack(spacing: Spacing.small) {
                    ForEach(medications, id: \.medication.id) { medicationInfo in
                        MedicationCard.display(
                            medicationName: medicationInfo.medication.name,
                            dosage: medicationInfo.dosageText,
                            timing: medicationInfo.displayTime,
                            instructions: medicationInfo.medication.instructions,
                            accentColor: mapToDesignSystemTimePeriod(timePeriod).color
                        )
                    }
                }
            }
        }
    }
    
    private func loadActiveMedications() {
        let activeCases = patient.medicalCases.filter { $0.isActive }
        let medications = activeCases.flatMap { $0.prescriptions.flatMap { $0.medications } }
        self.activeMedications = medications
    }
    
    private func mapToDesignSystemTimePeriod(_ timePeriod: MedicationTracker.TimePeriod) -> MedicationTimePeriod {
        switch timePeriod {
        case .morning:
            return .morning
        case .afternoon:
            return .afternoon
        case .evening:
            return .evening
        case .night:
            return .night
        }
    }
}
