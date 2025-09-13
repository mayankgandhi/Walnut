//
//  MedicationListItem.swift
//  Walnut
//
//  Created by Mayank Gandhi on 03/09/25.
//  Copyright © 2025 m. All rights reserved.
//

import SwiftUI
import WalnutDesignSystem

struct MedicationListItem: View {
    
    let medication: Medication
    
    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.small) {
            // Header with icon and basic info
            medicationHeaderSection
            
            // Frequency schedules if available
            if let frequencies = medication.frequency, !frequencies.isEmpty {
                frequencySection(frequencies)
                    .padding(Spacing.small)
                    .background(Color.healthWarning.opacity(0.05))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.healthWarning.opacity(0.1), lineWidth: 1)
                    )
            }
            
            
            // Instructions if available
            if let instructions = medication.instructions,
               !instructions.isEmpty,
               instructions != "" {
                instructionsSection(instructions)
                    .padding(Spacing.small)
                    .background(Color.healthWarning.opacity(0.05))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.healthWarning.opacity(0.1), lineWidth: 1)
                    )
            }
        }
    }
    
    
    // MARK: - Header Section
    
    private var medicationHeaderSection: some View {
        HStack(spacing: Spacing.medium) {
            // Medication info
            VStack(alignment: .leading, spacing: Spacing.xs) {
                HStack(spacing: Spacing.xs) {
                    
                    if let name = medication.name, !name.isEmpty {
                        Text(name)
                            .font(.headline.weight(.semibold))
                            .foregroundStyle(.primary)
                            .lineLimit(2)
                            .multilineTextAlignment(.leading)
                    }
                    
                    if let dosage = medication.dosage, !dosage.isEmpty {
                        dosageChip(dosage)
                    }
                    
                }
                
                if let duration = medication.duration {
                    HStack {
                        Image(systemName: "calendar")
                            .font(.caption)
                        Text("\(duration.displayText)")
                            .font(.caption)
                    }
                }
            }
            
            Spacer()
        }
    }
    
    private var medicationIcon: some View {
        Circle()
            .fill(Color.healthPrimary.opacity(0.15))
            .frame(width: 32, height: 32)
            .overlay {
                Image("pills")
                    .resizable()
                    .frame(width: 32, height: 32)
            }
    }
    
    private func dosageChip(_ dosage: String) -> some View {
        HStack(spacing: 4) {
            Image(systemName: "scalemass.fill")
                .font(.caption2)
                .foregroundStyle(Color.healthSuccess)
            
            Text(dosage)
                .font(.caption.weight(.medium))
                .foregroundStyle(.primary)
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 3)
        .background(Color.healthSuccess.opacity(0.1))
        .clipShape(Capsule())
    }
    
    private func frequencySection(_ frequencies: [MedicationFrequency]) -> some View {
        VStack(alignment: .leading, spacing: Spacing.small) {
        
            Label("Schedule", systemImage: "clock")
                    .font(.caption.weight(.medium))
            
            if frequencies.count == 1 {
                VStack(alignment: .leading, spacing: Spacing.small) {
                    ForEach(Array(frequencies.enumerated()), id: \.offset) { index, frequency in
                        frequencyItemView(frequency)
                    }
                }
            } else {
                LazyVGrid(
                    columns: [.init(), .init()],
                    alignment: .leading,
                    spacing: Spacing.xs
                ) {
                    ForEach(Array(frequencies.enumerated()), id: \.offset) { index, frequency in
                        frequencyItemView(frequency)
                    }
                }
            }
            
        }
    }
    
    private func frequencyItemView(_ frequency: MedicationFrequency) -> some View {
        Label(frequency.displayText, systemImage: frequency.icon)
            .font(.caption.weight(.medium))
            .frame(maxWidth: .infinity, alignment: .topLeading)
            .padding(.horizontal, Spacing.small)
            .padding(.vertical, Spacing.xs)
            .background(frequency.color.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 8))
        
    }
    
    // MARK: - Details Section
    
    private func detailItem(icon: String, title: String, value: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: Spacing.small) {
            Label(title, systemImage: icon)
                .font(.caption.weight(.medium))
            
            Text(value)
                .font(.caption.weight(.regular))
                .foregroundStyle(.primary)
                .lineLimit(2)
                .multilineTextAlignment(.leading)
        }
    }
    
    // MARK: - Instructions Section
    
    private func instructionsSection(_ instructions: String) -> some View {
        VStack(alignment: .leading, spacing: Spacing.small) {
            
            Label("Instructions", systemImage: "doc.text")
                .font(.caption.weight(.medium))
            
            Text(instructions)
                .font(.caption.weight(.regular))
                .foregroundStyle(.primary)
                .lineSpacing(2)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
            
        }
    }
}

// MARK: - Preview

#Preview("Simple Medication") {
    MedicationListItem(medication: .sampleMedication)
        .padding()
}

#Preview("Complex Medication") {
    MedicationListItem(medication: .complexMedication)
        .padding()
}

#Preview("Hourly Medication") {
    MedicationListItem(medication: .hourlyMedication)
        .padding()
}

#Preview("Weekly Medication") {
    MedicationListItem(medication: .weeklyMedication)
        .padding()
}

#Preview("Monthly Medication") {
    MedicationListItem(medication: .monthlyMedication)
        .padding()
}
