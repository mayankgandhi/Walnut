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
    @State private var showAllMedications = false
    
    private var upcomingMedications: [MedicationTracker.MedicationScheduleInfo] {
        medicationTracker.getUpcomingMedications(activeMedications, withinHours: 6)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.medium) {
            
            sectionHeaderView
            
            if upcomingMedications.isEmpty {
                emptyStateView
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
            } else {
                ForEach(Array(upcomingMedications.enumerated()), id: \.element.medication.id) { index, medicationInfo in
                    MedicationCard.upcoming(
                        medicationName: medicationInfo.medication.name ?? "",
                        dosage: medicationInfo.dosageText,
                        timing: medicationInfo.displayTime,
                        instructions: medicationInfo.medication.instructions,
                        timePeriod: medicationInfo.timePeriod,
                        timeUntilDue: medicationInfo.timeUntilDue.map { medicationTracker.formatTimeUntilDue($0) } ?? ""
                    )
                }
            }
        }
        .padding(Spacing.medium)
        .onAppear {
            loadActiveMedications()
        }
        .navigationDestination(isPresented: $showAllMedications) {
            ActiveMedicationsSection(patient: patient)
        }
    }
    
    // MARK: - Subviews
    
    private var sectionHeaderView: some View {
        VStack(alignment: .leading, spacing: Spacing.small) {
            
            HealthCardHeader(
                iconName: "pills",
                iconColor: Color.healthPrimary,
                title: "Upcoming Medications",
                actionIcon: "cross.case.fill",
                actionColor: Color.healthSuccess) {
                    showAllMedications = true
                }
            
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
        ContentUnavailableView(
            "All caught up!",
            systemImage: "checkmark.circle.fill",
            description: Text("No medications due in the next 6 hours")
        )
    }
    
    private func loadActiveMedications() {
        let activeMedicalCases = patient.medicalCases?
            .filter { $0.isActive ?? false }
        let activeMedicalCasesPrescriptions: [Prescription] = (activeMedicalCases ?? []).compactMap(\.prescriptions)
            .reduce([], +)
        let activeMedications: [Medication] = activeMedicalCasesPrescriptions
            .compactMap(\.medications).reduce([], +)
        self.activeMedications = activeMedications
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

