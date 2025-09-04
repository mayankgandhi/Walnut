//
//  EnhancedMedicationCard.swift
//  Walnut
//
//  Created by Mayank Gandhi on 03/09/25.
//  Copyright © 2025 m. All rights reserved.
//

import SwiftUI
import WalnutDesignSystem

struct EnhancedMedicationCard: View {
    
    let medication: Medication
    
    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.medium) {
            medicationHeaderSection
            
            if !(medication.frequency ?? []).isEmpty {
                frequencySection
            }
            
            if let instructions = medication.instructions, !instructions.isEmpty {
                instructionsSection(instructions)
            }
        }
        
    }
    
    // MARK: - Subviews
    
    private var medicationHeaderSection: some View {
        HStack(spacing: Spacing.medium) {
            medicationStatusIcon
            medicationInfoSection
            Spacer()
            durationBadge
        }
    }
    
    private var medicationStatusIcon: some View {
        Circle()
            .fill(medicationStatusColor)
            .frame(width: 32, height: 32)
            .overlay {
                Image(systemName: medicationIcon)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(.white)
            }
    }
    
    private var medicationInfoSection: some View {
        VStack(alignment: .leading, spacing: 2) {
            if let name = medication.name, !name.isEmpty {
                Text(name)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.primary)
                    .lineLimit(2)
            }
            
            if let dosage = medication.dosage, !dosage.isEmpty {
                dosageInfo(dosage)
            }
        }
    }
    
    private func dosageInfo(_ dosage: String) -> some View {
        HStack(spacing: 4) {
            Image(systemName: "scalemass")
                .font(.caption2)
                .foregroundStyle(Color.healthPrimary)
            
            Text(dosage)
                .font(.caption.weight(.medium))
                .foregroundStyle(.secondary)
        }
    }
    
    private var durationBadge: some View {
        VStack(spacing: 2) {
            Text("\(String(describing: medication.numberOfDays))")
                .font(.caption.weight(.bold))
                .foregroundStyle(Color.healthSuccess)
            
            Text(medication.numberOfDays == 1 ? "day" : "days")
                .font(.caption2.weight(.medium))
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, Spacing.small)
        .padding(.vertical, 4)
        .background(Color.healthSuccess.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 6))
    }
    
    private var frequencySection: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            frequencyHeader
            frequencyGrid
        }
        .padding(Spacing.small)
        .background(Color.healthWarning.opacity(0.05))
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.healthWarning.opacity(0.1), lineWidth: 1)
        )
    }
    
    private var frequencyHeader: some View {
        OptionalView(medication.frequency) { frequency in
            HStack(spacing: 6) {
                Image(systemName: "clock")
                    .font(.caption)
                    .foregroundStyle(Color.healthWarning)
                
                Text("Schedule")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.primary)
                
                Spacer()
                
                Text("\(frequency.count)x daily")
                    .font(.caption2.weight(.medium))
                    .foregroundStyle(Color.healthWarning)
            }
        }
    }
    
    private var frequencyGrid: some View {
        LazyVGrid(columns: [
            GridItem(.flexible(), spacing: Spacing.xs),
            GridItem(.flexible(), spacing: Spacing.xs)
        ], spacing: Spacing.xs) {
            ForEach((medication.frequency ?? []).indices, id: \.self) { index in
                frequencyChip(schedule: medication.frequency![index])
            }
        }
    }
    
    private func frequencyChip(schedule: MedicationSchedule) -> some View {
        HStack(spacing: Spacing.xs) {
            if let timing = schedule.timing {
                Text(timing.rawValue.capitalized)
                    .font(.caption.weight(.bold))
                    .foregroundStyle(Color.healthWarning)
            }
            Text(schedule.mealTime.rawValue.capitalized)
                .font(.caption.weight(.bold))
                .foregroundStyle(Color.healthWarning)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, Spacing.xs)
        .padding(.vertical, 4)
        .background(Color.healthWarning.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 6))
    }
    
    private func instructionsSection(_ instructions: String) -> some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            instructionsHeader
            instructionsContent(instructions)
        }
    }
    
    private var instructionsHeader: some View {
        HStack(spacing: 6) {
            Image(systemName: "doc.text")
                .font(.caption)
                .foregroundStyle(Color.healthPrimary)
            
            Text("Instructions")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.primary)
        }
    }
    
    private func instructionsContent(_ instructions: String) -> some View {
        Text(instructions)
            .font(.caption)
            .foregroundStyle(.primary)
            .lineSpacing(2)
            .padding(Spacing.small)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.healthPrimary.opacity(0.05))
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.healthPrimary.opacity(0.1), lineWidth: 1)
            )
    }
    
    private var cardBackground: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(Color(UIColor.secondarySystemGroupedBackground))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(medicationStatusColor.opacity(0.1), lineWidth: 1)
            )
    }
    
    // MARK: - Helper Properties
    
    private var medicationStatusColor: Color {
        // You can add logic here based on medication type or status
        return Color.healthSuccess
    }
    
    private var medicationIcon: String {
        guard let name = medication.name else {
            return "pills.fill"
        }
        // You can customize icons based on medication type
        if name.lowercased().contains("antibiotic") {
            return "shield.fill"
        } else if name.lowercased().contains("pain") {
            return "bolt.fill"
        } else {
            return "pills.fill"
        }
    }
}
