//
//  ActiveMedicationsView.swift
//  Walnut
//
//  Created by Mayank Gandhi on 19/09/25.
//  Copyright © 2025 m. All rights reserved.
//

import SwiftUI
import WalnutDesignSystem

struct ActiveMedicationsView: View {

    // MARK: - Properties
    let patient: Patient
    let todaysMedications: [Medication]
    let onAddMedication: () -> Void
    let onShowAllMedications: () -> Void
    let onEditMedication: (Medication) -> Void
    
    // MARK: - Body

    var body: some View {
        ScrollView {
            VStack(spacing: Spacing.medium) {
                headerView

                // Main medications content
                if !todaysMedications.isEmpty {
                    medicationsListView
                } else {
                    MedicationEmptyState()
                }
            }
            .padding(.bottom, 100) // Extra padding for better scrolling
        }
        .background {
            ContentBackgroundView(color: .yellow)
        }
    }

    // MARK: - Private Views

    private var headerView: some View {
        HStack {
            NavBarHeader(
                iconName: "pill-bottle",
                iconColor: .yellow,
                title: "Medications",
                subtitle: "\(todaysMedications.count) Today"
            )

            HStack(spacing: Spacing.small) {
                Button(action: onShowAllMedications) {
                    Image(systemName: "list.bullet")
                }
                .buttonStyle(.glass)

                Button(action: onAddMedication) {
                    Image(systemName: "plus")
                }
                .buttonStyle(.glass)
            }
            .padding(.trailing, Spacing.medium)
        }
    }

    private var medicationsListView: some View {
        LazyVStack(spacing: Spacing.medium) {
            ForEach(todaysMedications, id: \.id) { medication in
                TodaysMedicationCard(
                    medication: medication,
                    onEdit: { onEditMedication(medication) }
                )
            }
        }
        .padding(.horizontal, Spacing.medium)
    }
}

struct TodaysMedicationCard: View {

    let medication: Medication
    let onEdit: () -> Void

    var body: some View {
        HealthCard {
            HStack {
                VStack(alignment: .leading, spacing: Spacing.xs) {
                    Text(medication.name ?? "Medication")
                        .font(.headline)
                        .foregroundStyle(.primary)

                    if let dosage = medication.dosage {
                        Text(dosage)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }

                    if let instructions = medication.instructions {
                        Text(instructions)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .lineLimit(2)
                    }
                }

                Spacer()

                VStack(spacing: Spacing.xs) {
                    Button(action: onEdit) {
                        Image(systemName: "pencil")
                            .foregroundStyle(.secondary)
                    }
                    .buttonStyle(.plain)

                    if let frequency = medication.frequency, !frequency.isEmpty {
                        Text("\(frequency.count)x daily")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .padding(Spacing.medium)
        }
    }
}

#Preview {
    NavigationStack {
        ActiveMedicationsView(
            patient: .samplePatient,
            todaysMedications: [.sampleMedication, .complexMedication],
            onAddMedication: { print("Add medication") },
            onShowAllMedications: { print("Show all medications") },
            onEditMedication: { _ in print("Edit medication") }
        )
    }
    .modelContainer(for: Patient.self, inMemory: true)
}
