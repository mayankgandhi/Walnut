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
        HealthCard {
            VStack(alignment: .leading, spacing: Spacing.small) {
                medicationHeaderSection
                
                if !(medication.frequency ?? []).isEmpty {
                    frequencySection
                }
                
                if let instructions = medication.instructions, !instructions.isEmpty {
                    instructionsSection(instructions)
                }
            }
        }
    }
    
    // MARK: - Subviews
    
    private var medicationHeaderSection: some View {
        VStack(alignment: .leading, spacing: Spacing.small) {
            HStack {
                medicationStatusIcon
                
                Spacer()
                
                durationBadge
            }
            
            medicationInfoSection
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
        VStack(alignment: .leading, spacing: Spacing.xs) {
            if let name = medication.name, !name.isEmpty {
                Text(name)
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(.primary)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
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
        OptionalView(medication.numberOfDays) { numberOfDays in
            VStack(spacing: 2) {
                Text("\(numberOfDays)")
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
        Label(
            schedule.timing == nil ? "\(schedule.mealTime.rawValue.capitalized)" : "\(schedule.timing!.rawValue.capitalized) \(schedule.mealTime.rawValue.capitalized)",
            systemImage: schedule.icon
        )
        .font(.caption.weight(.bold))
        .foregroundStyle(schedule.mealTime.color)
        .frame(maxWidth: .infinity, alignment: .center)
        .padding(.horizontal, Spacing.xs)
        .padding(.vertical, Spacing.xs)
        .background(schedule.mealTime.color.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 6))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.healthPrimary.opacity(0.1), lineWidth: 1)
        )
    }
    
    private func instructionsSection(_ instructions: String) -> some View {
        VStack(alignment: .leading, spacing: Spacing.small) {
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
            .lineSpacing(1)
            .multilineTextAlignment(.leading)
            .padding(Spacing.small)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.healthPrimary.opacity(0.05))
            .clipShape(RoundedRectangle(cornerRadius: 6))
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .stroke(Color.healthPrimary.opacity(0.1), lineWidth: 1)
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

// MARK: - Previews

#Preview("Single Medication Card") {
    VStack(spacing: Spacing.medium) {
        MedicationListItem(
            medication: Medication(
                id: UUID(),
                name: "Ibuprofen",
                frequency: [.init(mealTime: .breakfast, timing: .after, dosage: "200mg")],
                numberOfDays: 5,
                instructions: "Take with food to avoid stomach upset"
            )
        )
        .padding()
        
        Spacer()
    }
    .background(Color(UIColor.systemGroupedBackground))
}
