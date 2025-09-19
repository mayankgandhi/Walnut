//
//  MedicationsListView.swift
//  Walnut
//
//  Created by Mayank Gandhi on 19/09/25.
//  Copyright © 2025 m. All rights reserved.
//

import Foundation
import SwiftUI
import SwiftData
import WalnutDesignSystem

struct ActiveMedicationsListView: View {

    let patient: Patient
    let medications: [Medication] = []
    let onEdit: (Medication) -> Void

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: Spacing.medium) {
            if medications.isEmpty {
                emptyStateView
            } else {
                medicationsList
            }
        }
        .navigationTitle("All Medications")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Done") {
                    dismiss()
                }
            }
        }
        .background {
            ContentBackgroundView(color: .yellow)
        }
    }

    private var emptyStateView: some View {
        ContentUnavailableView {
            Label("No Medications", systemImage: "pill")
        } description: {
            Text("No active medications found for this patient")
        } actions: {
            Button("Close") {
                dismiss()
            }
            .buttonStyle(.borderedProminent)
        }
    }

    private var medicationsList: some View {
        ScrollView {
            LazyVStack(spacing: Spacing.medium) {
                ForEach(medications, id: \.id) { medication in
                    ActiveMedicationsListItem(
                        medication: medication,
                        onEdit: {
                            onEdit(medication)
                        }
                    )
                }
            }
            .padding(.horizontal, Spacing.medium)
            .padding(.top, Spacing.small)
        }
    }
}

struct ActiveMedicationsListItem: View {

    let medication: Medication
    let onEdit: () -> Void

    var body: some View {
        HealthCard {
            VStack(alignment: .leading, spacing: Spacing.small) {
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
                    }

                    Spacer()

                    Button(action: onEdit) {
                        Image(systemName: "pencil")
                            .foregroundStyle(.secondary)
                    }
                    .buttonStyle(.plain)
                }

                if frequencyText != nil {
                    HStack {
                        Image(systemName: "clock")
                            .foregroundStyle(.secondary)
                            .font(.caption)

                        Text(frequencyText!)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }

                if let instructions = medication.instructions {
                    Text(instructions)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }

                HStack {
                    if let prescription = medication.prescription {
                        Label("Prescription", systemImage: "doc.text")
                            .font(.caption2)
                            .foregroundStyle(.blue)
                    } else {
                        Label("Direct", systemImage: "person")
                            .font(.caption2)
                            .foregroundStyle(.green)
                    }

                    Spacer()
                    if durationText != nil {
                        Text(durationText!)
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .padding(Spacing.medium)
        }
    }

    private var frequencyText: String? {
        guard let frequency = medication.frequency else { return nil }
        if frequency.isEmpty {
            return "As needed"
        }

        let times = frequency.map { time in
            time.displayText
        }.joined(separator: ", ")

        return "\(frequency.count)x daily at \(times)"
    }

    private var durationText: String? {
        guard let duration = medication.duration else { return nil }
        switch duration {
        case .days(let count):
            return "\(count) days"
        case .weeks(let count):
            return "\(count) weeks"
        case .months(let count):
            return "\(count) months"
        case .asNeeded:
            return "As needed"
        case .ongoing:
            return "Ongoing"
            case .untilFollowUp(let date):
                return "Until next Follow up on: \(date.formatted(date: .abbreviated, time: .omitted))"
        }
    }
}

#Preview("With Medications") {
    NavigationView {
        ActiveMedicationsListView(
            patient: .samplePatient,
            onEdit: { _ in }
        )
    }
    .modelContainer(for: Patient.self, inMemory: true)
}

#Preview("Empty State") {
    NavigationView {
        ActiveMedicationsListView(
            patient: .samplePatient,
            onEdit: { _ in }
        )
    }
    .modelContainer(for: Patient.self, inMemory: true)
}
