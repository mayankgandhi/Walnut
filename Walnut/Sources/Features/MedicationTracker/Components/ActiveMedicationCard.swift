//
//  ActiveMedicationCard.swift
//  Walnut
//
//  Created by Mayank Gandhi on 20/09/25.
//  Copyright © 2025 m. All rights reserved.
//

import SwiftUI
import WalnutDesignSystem

/// Reusable card component for displaying active medication information
struct ActiveMedicationCard: View {

    // MARK: - Properties

    let medication: Medication

    // MARK: - Body

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.small) {
            // Header with medication name
            medicationHeader

            // Dosage and duration information
            medicationDetails

            // Frequency information
            frequencySection

            // Instructions
            instructionsSection

            Spacer()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .glassEffect(.regular, in: RoundedRectangle(cornerRadius: 12))
    }

    // MARK: - Private Views

    private var medicationHeader: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            Text(medication.name ?? "Unknown")
                .font(.system(.subheadline, design: .rounded, weight: .semibold))
                .foregroundStyle(.primary)
                .lineLimit(2)
                .multilineTextAlignment(.leading)
        }
    }

    private var medicationDetails: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            // Dosage information
            if let dosage = medication.dosage {
                Label {
                    Text(dosage)
                        .font(.caption.weight(.medium))
                        .foregroundStyle(Color.healthPrimary)
                } icon: {
                    Image(systemName: "cross.vial")
                        .font(.caption.weight(.medium))
                        .foregroundStyle(Color.healthPrimary)
                }
                .labelStyle(.titleAndIcon)
            }

            // Duration information
            if let duration = medication.duration {
                Label {
                    Text(duration.displayText)
                        .font(.caption.weight(.medium))
                        .foregroundStyle(Color.healthPrimary)
                } icon: {
                    Image(systemName: "calendar")
                        .font(.caption.weight(.medium))
                        .foregroundStyle(Color.healthPrimary)
                }
                .labelStyle(.titleAndIcon)
            }
        }
    }

    private var frequencySection: some View {
        Group {
            if let frequencies = medication.frequency, !frequencies.isEmpty {
                LazyVGrid(columns: [GridItem(.flexible())], spacing: 2) {
                    ForEach(Array(frequencies.enumerated()), id: \.offset) { _, frequency in
                        Label {
                            Text(frequency.displayText)
                                .font(.caption2.weight(.medium))
                                .foregroundStyle(.primary)
                                .multilineTextAlignment(.leading)
                        } icon: {
                            Image(systemName: frequency.icon)
                                .font(.caption2)
                                .foregroundStyle(frequency.color)
                        }
                        .labelStyle(.titleAndIcon)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
            }
        }
    }

    private var instructionsSection: some View {
        Group {
            if let instructions = medication.instructions, !instructions.isEmpty {
                Text(instructions.lowercased())
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .lineLimit(3)
                    .truncationMode(.tail)
            }
        }
    }
}


// MARK: - Preview

#Preview {
    VStack(spacing: Spacing.medium) {
        ActiveMedicationCard(medication: .sampleMedication)
        ActiveMedicationCard(medication: .complexMedication)
        ActiveMedicationCard(medication: .hourlyMedication)
    }
    .padding()
}
