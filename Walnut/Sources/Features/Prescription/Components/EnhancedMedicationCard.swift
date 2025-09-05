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
            VStack(alignment: .leading, spacing: Spacing.medium) {
                medicationHeaderSection
                
                if !(medication.frequency ?? []).isEmpty {
                    frequencySection
                }
                
                if let instructions = medication.instructions, !instructions.isEmpty {
                    instructionsSection(instructions)
                }
                
                progressSection
            }
        }
        .overlay(
            // Subtle gradient overlay for depth
            LinearGradient(
                colors: [
                    medicationStatusColor.opacity(0.03),
                    Color.clear,
                    medicationStatusColor.opacity(0.02)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .clipShape(RoundedRectangle(cornerRadius: 12))
        )
    }
    
    // MARK: - Subviews
    
    private var medicationHeaderSection: some View {
        VStack(alignment: .leading, spacing: Spacing.small) {
            HStack(alignment: .top) {
                medicationStatusIcon
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: Spacing.xs) {
                    durationBadge
                    medicationTypeIndicator
                }
            }
            
            medicationInfoSection
        }
    }
    
    private var medicationStatusIcon: some View {
        ZStack {
            // Animated background ring
            Circle()
                .stroke(medicationStatusColor.opacity(0.2), lineWidth: 2)
                .frame(width: 40, height: 40)
                .scaleEffect(1.2)
            
            // Main icon background
            Circle()
                .fill(
                    LinearGradient(
                        colors: [
                            medicationStatusColor,
                            medicationStatusColor.opacity(0.8)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 36, height: 36)
                .shadow(color: medicationStatusColor.opacity(0.3), radius: 4, x: 0, y: 2)
            
            // Icon with subtle animation
            Image(systemName: medicationIcon)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(.white)
                .symbolEffect(.pulse.wholeSymbol, options: .repeating.speed(0.5))
        }
    }
    
    private var medicationInfoSection: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            if let name = medication.name, !name.isEmpty {
                Text(name)
                    .font(.title3.weight(.bold))
                    .foregroundStyle(.primary)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                    .shadow(color: .black.opacity(0.05), radius: 1, x: 0, y: 1)
            }
            
            HStack(spacing: Spacing.small) {
                if let dosage = medication.dosage, !dosage.isEmpty {
                    dosageInfo(dosage)
                }
                
                Spacer()
                
                // Daily frequency indicator
                if let frequency = medication.frequency, !frequency.isEmpty {
                    frequencyIndicator(count: frequency.count)
                }
            }
        }
    }
    
    private func dosageInfo(_ dosage: String) -> some View {
        HStack(spacing: 4) {
            Image(systemName: "scalemass.fill")
                .font(.caption2)
                .foregroundStyle(Color.healthPrimary)
                .symbolEffect(.bounce, value: dosage)
            
            Text(dosage)
                .font(.caption.weight(.semibold))
                .foregroundStyle(.primary)
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(Color.healthPrimary.opacity(0.1))
                .clipShape(Capsule())
        }
    }
    
    private func frequencyIndicator(count: Int) -> some View {
        HStack(spacing: 2) {
            Image(systemName: "clock.fill")
                .font(.caption2)
                .foregroundStyle(Color.healthWarning)
            
            Text("\(count)x")
                .font(.caption2.weight(.bold))
                .foregroundStyle(Color.healthWarning)
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 2)
        .background(Color.healthWarning.opacity(0.15))
        .clipShape(Capsule())
    }
    
    private var medicationTypeIndicator: some View {
        Text(medicationType)
            .font(.caption2.weight(.medium))
            .foregroundStyle(.white)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(medicationStatusColor.opacity(0.8))
            .clipShape(Capsule())
    }
    
    private var durationBadge: some View {
        OptionalView(medication.numberOfDays) { numberOfDays in
            VStack(spacing: 1) {
                Text("\(numberOfDays)")
                    .font(.headline.weight(.black))
                    .foregroundStyle(Color.healthSuccess)
                    .scaleEffect(1.1)
                
                Text(numberOfDays == 1 ? "day" : "days")
                    .font(.caption2.weight(.medium))
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal, Spacing.small)
            .padding(.vertical, 6)
            .background(
                LinearGradient(
                    colors: [
                        Color.healthSuccess.opacity(0.15),
                        Color.healthSuccess.opacity(0.05)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.healthSuccess.opacity(0.3), lineWidth: 1)
            )
            .shadow(color: Color.healthSuccess.opacity(0.2), radius: 2, x: 0, y: 1)
        }
    }
    
    private var progressSection: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            HStack {
                Text("Treatment Progress")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                
                Spacer()
                
                Text("Day \(currentDay) of \(medication.numberOfDays ?? 0)")
                    .font(.caption2.weight(.medium))
                    .foregroundStyle(.tertiary)
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background track
                    RoundedRectangle(cornerRadius: 3)
                        .fill(Color.secondary.opacity(0.2))
                        .frame(height: 6)
                    
                    // Progress fill
                    RoundedRectangle(cornerRadius: 3)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.healthSuccess,
                                    Color.healthSuccess.opacity(0.8)
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geometry.size.width * progressPercentage, height: 6)
                        .animation(.easeInOut(duration: 1), value: progressPercentage)
                }
            }
            .frame(height: 6)
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
        } else if name.lowercased().contains("vitamin") {
            return "leaf.fill"
        } else if name.lowercased().contains("blood") || name.lowercased().contains("pressure") {
            return "heart.fill"
        } else {
            return "pills.fill"
        }
    }
    
    private var medicationType: String {
        guard let name = medication.name else {
            return "Medication"
        }
        
        if name.lowercased().contains("antibiotic") {
            return "Antibiotic"
        } else if name.lowercased().contains("pain") {
            return "Pain Relief"
        } else if name.lowercased().contains("vitamin") {
            return "Supplement"
        } else if name.lowercased().contains("blood") || name.lowercased().contains("pressure") {
            return "Heart"
        } else {
            return "Medication"
        }
    }
    
    private var currentDay: Int {
        // For demo purposes, show a random day between 1 and total days
        // In real implementation, this would be calculated based on start date
        return min(Int.random(in: 1...5), medication.numberOfDays ?? 1)
    }
    
    private var progressPercentage: Double {
        guard let totalDays = medication.numberOfDays, totalDays > 0 else {
            return 0
        }
        return Double(currentDay) / Double(totalDays)
    }
}

// MARK: - Previews

#Preview("Rich 2-Column Medication Grid") {
    ScrollView {
        LazyVGrid(columns: [
            GridItem(.flexible(), spacing: Spacing.medium),
            GridItem(.flexible(), spacing: Spacing.medium)
        ], spacing: Spacing.medium) {
            
            MedicationListItem(
                medication: Medication(
                    id: UUID(),
                    name: "Lisinopril Blood Pressure",
                    frequency: [.init(mealTime: .breakfast, timing: .before, dosage: "10mg")],
                    numberOfDays: 30,
                    instructions: "Take consistently at the same time each day for best results"
                )
            )
            
            MedicationListItem(
                medication: Medication(
                    id: UUID(),
                    name: "Amoxicillin Antibiotic",
                    frequency: [
                        .init(mealTime: .breakfast, timing: .before, dosage: "500mg"),
                        .init(mealTime: .lunch, timing: .before, dosage: "500mg"),
                        .init(mealTime: .dinner, timing: .before, dosage: "500mg")
                    ],
                    numberOfDays: 10,
                    instructions: "Complete entire course. Take on empty stomach 1 hour before meals."
                )
            )
            
            MedicationListItem(
                medication: Medication(
                    id: UUID(),
                    name: "Vitamin D3 Supplement",
                    frequency: [.init(mealTime: .breakfast, timing: .after, dosage: "2000 IU")],
                    numberOfDays: 90,
                    instructions: "Take with fatty meal for better absorption"
                )
            )
            
            MedicationListItem(
                medication: Medication(
                    id: UUID(),
                    name: "Acetaminophen Pain Relief",
                    frequency: [
                        .init(mealTime: .breakfast, timing: .after, dosage: "650mg"),
                        .init(mealTime: .bedtime, timing: nil, dosage: "650mg")
                    ],
                    numberOfDays: 5,
                    instructions: "Do not exceed 4000mg in 24 hours. Can cause liver damage."
                )
            )
            
            MedicationListItem(
                medication: Medication(
                    id: UUID(),
                    name: "Metformin",
                    frequency: [
                        .init(mealTime: .breakfast, timing: .after, dosage: "500mg"),
                        .init(mealTime: .dinner, timing: .after, dosage: "500mg")
                    ],
                    numberOfDays: 30,
                    instructions: "Take with meals to reduce stomach upset and improve absorption"
                )
            )
            
            MedicationListItem(
                medication: Medication(
                    id: UUID(),
                    name: "Atorvastatin",
                    frequency: [.init(mealTime: .bedtime, timing: nil, dosage: "20mg")],
                    numberOfDays: 30,
                    instructions: "Take at bedtime. Avoid grapefruit and grapefruit juice."
                )
            )
            
        }
        .padding()
    }
    .background(Color(UIColor.systemGroupedBackground))
}
