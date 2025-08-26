//
//  UpcomingMedicationsSection.swift
//  Walnut
//
//  Created by Mayank Gandhi on 01/08/25.
//  Copyright © 2025 m. All rights reserved.
//

import SwiftUI
import WalnutDesignSystem

struct UpcomingMedicationsSection: View {
    
    let patient: Patient

    @State private var activeMedications: [Medication] = []
    @State private var medicationTracker = MedicationTracker()
    @State private var currentTime = Date()
    
    private var upcomingMedications: [MedicationTracker.MedicationScheduleInfo] {
        medicationTracker.getUpcomingMedications(activeMedications, withinHours: 6)
    }
    
    var body: some View {
        HealthCard {
            VStack(alignment: .leading, spacing: Spacing.medium) {

                sectionHeaderView
                
                if upcomingMedications.isEmpty {
                    emptyStateView
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                } else {
                    ForEach(Array(upcomingMedications.enumerated()), id: \.element.medication.id) { index, medicationInfo in
                        MedicationCard.upcoming(
                            medicationName: medicationInfo.medication.name,
                            dosage: medicationInfo.dosageText,
                            timing: medicationInfo.displayTime,
                            instructions: medicationInfo.medication.instructions,
                            timePeriod: mapToDesignSystemTimePeriod(medicationInfo.timePeriod),
                            timeUntilDue: medicationInfo.timeUntilDue.map { medicationTracker.formatTimeUntilDue($0) } ?? ""
                        ) {
                            
                        }
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                        .listRowInsets(EdgeInsets(top: Spacing.xs, leading: 0, bottom: Spacing.xs, trailing: 0))
                    }
                }
            }
        }
        .onAppear {
            loadActiveMedications()
        }
    }
    
    // MARK: - Subviews
    
    private var sectionHeaderView: some View {
        HStack(spacing: Spacing.small) {
            Image(systemName: "clock.badge.fill")
                .font(.headline)
                .foregroundStyle(Color.healthWarning)
            
            Text("Upcoming Medications")
                .font(.headline.weight(.semibold))
            
            Spacer()
            
            if !upcomingMedications.isEmpty {
                Text("Next 6 hours")
                    .font(.caption.weight(.medium))
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, Spacing.small)
                    .padding(.vertical, Spacing.xs)
                    .background(Color.healthWarning.opacity(0.1))
                    .clipShape(Capsule())
            }
        }
    }
    
    private var emptyStateView: some View {
        HealthCard {
            VStack(spacing: Spacing.medium) {
                WalnutDesignSystem.StatusIndicator(status: HealthStatus.good, showIcon: true)
                    .scaleEffect(2.0)
                
                VStack(spacing: Spacing.xs) {
                    Text("All caught up!")
                        .font(.headline.weight(.semibold))
                        .foregroundStyle(.primary)
                    
                    Text("No medications due in the next 6 hours")
                        .font(.body)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
            }
            .frame(maxWidth: .infinity)
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

#Preview("With Medications") {
    UpcomingMedicationsSection(patient: .samplePatientWithMedications)
        .modelContainer(for: Patient.self, inMemory: true)
}

#Preview("Empty State") {
    UpcomingMedicationsSection(patient: .samplePatient)
        .modelContainer(for: Patient.self, inMemory: true)
}

