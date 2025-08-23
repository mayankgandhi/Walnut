//
//  PrescriptionMedicationsCard.swift
//  Walnut
//
//  Created by Mayank Gandhi on 03/08/25.
//  Copyright © 2025 m. All rights reserved.
//

import SwiftUI
import WalnutDesignSystem

struct PrescriptionMedicationsCard: View {
    let medications: [Medication]
    @State private var isExpanded = true
    
    var body: some View {
        HealthCard {
            VStack(alignment: .leading, spacing: Spacing.medium) {
                // Enhanced Header with Walnut Design System
                
                
                HealthCardHeader
                    .medicalDocuments(count: medications.count, onAddTap: {
                        /// TODO
                    })
                
                if medications.isEmpty {
                    // Empty state with design system styling
                    VStack(spacing: Spacing.medium) {
                        Image(systemName: "pills")
                            .font(.system(size: 48))
                            .foregroundStyle(.quaternary)
                        
                        VStack(spacing: Spacing.xs) {
                            Text("No medications")
                                .font(.subheadline.weight(.medium))
                                .foregroundStyle(.secondary)
                            
                            Text("Prescription medications will appear here")
                                .font(.caption)
                                .foregroundStyle(.tertiary)
                                .multilineTextAlignment(.center)
                        }
                    }
                    .padding(.vertical, Spacing.large)
                    .transition(.opacity.combined(with: .move(edge: .top)))
                } else {
                    LazyVStack(spacing: Spacing.small) {
                        ForEach(medications, id: \.id) { medication in
                            EnhancedMedicationCard(medication: medication)
                        }
                    }
                    .transition(.opacity.combined(with: .move(edge: .top)))
                }
                
            }
        }
    }
    
}

// MARK: - Enhanced Medication Card Component

struct EnhancedMedicationCard: View {
    let medication: Medication
    @State private var isPressed = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.small) {
            medicationHeaderSection
            
            if !medication.frequency.isEmpty {
                frequencySection
            }
            
            if let instructions = medication.instructions, !instructions.isEmpty {
                instructionsSection(instructions)
            }
        }
        .padding(Spacing.small)
        .background(cardBackground)
        .scaleEffect(isPressed ? 0.98 : 1.0)
        .animation(.easeInOut(duration: 0.1), value: isPressed)
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
            Text(medication.name)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.primary)
                .lineLimit(2)
            
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
            Text("\(medication.numberOfDays)")
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
        HStack(spacing: 6) {
            Image(systemName: "clock")
                .font(.caption)
                .foregroundStyle(Color.healthWarning)
            
            Text("Schedule")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.primary)
            
            Spacer()
            
            Text("\(medication.frequency.count)x daily")
                .font(.caption2.weight(.medium))
                .foregroundStyle(Color.healthWarning)
        }
    }
    
    private var frequencyGrid: some View {
        LazyVGrid(columns: [
            GridItem(.flexible(), spacing: Spacing.xs),
            GridItem(.flexible(), spacing: Spacing.xs)
        ], spacing: Spacing.xs) {
            ForEach(medication.frequency.indices, id: \.self) { index in
                frequencyChip(at: index)
            }
        }
    }
    
    private func frequencyChip(at index: Int) -> some View {
        VStack(spacing: 2) {
            Text(medication.frequency[index].mealTime.rawValue)
                .font(.caption.weight(.bold))
                .foregroundStyle(Color.healthWarning)
            
            Text("Time \(index + 1)")
                .font(.caption2.weight(.medium))
                .foregroundStyle(.tertiary)
        }
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
        // You can customize icons based on medication type
        if medication.name.lowercased().contains("antibiotic") {
            return "shield.fill"
        } else if medication.name.lowercased().contains("pain") {
            return "bolt.fill"
        } else {
            return "pills.fill"
        }
    }
}

