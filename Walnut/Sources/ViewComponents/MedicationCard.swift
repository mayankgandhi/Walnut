//
//  MedicationCard.swift
//  WalnutDesignSystem
//
//  Created by Mayank Gandhi on 11/08/25.
//  Copyright © 2025 m. All rights reserved.
//

import SwiftUI
import WalnutDesignSystem

// MARK: - Medication Card Component

/// Professional medication card component for healthcare apps
struct MedicationCard: View {
    private let medicationName: String
    private let dosage: String?
    private let timing: String?
    private let instructions: String?
    private let timePeriod: MealTime?
    private let timeUntilDue: String?
    private let accentColor: Color
    private let showTimeIndicator: Bool
    private let showActionButton: Bool
    private let actionIcon: String
    private let actionColor: Color
    private let onTap: (() -> Void)?
    private let onAction: (() -> Void)?
    
    @State private var isPressed = false
    
    init(
        medicationName: String,
        dosage: String? = nil,
        timing: String? = nil,
        instructions: String? = nil,
        timePeriod: MealTime? = nil,
        timeUntilDue: String? = nil,
        accentColor: Color = .healthPrimary,
        showTimeIndicator: Bool = true,
        showActionButton: Bool = true,
        actionIcon: String = "checkmark.circle.fill",
        actionColor: Color = .healthSuccess,
        onTap: (() -> Void)? = nil,
        onAction: (() -> Void)? = nil
    ) {
        self.medicationName = medicationName
        self.dosage = dosage
        self.timing = timing
        self.instructions = instructions
        self.timePeriod = timePeriod
        self.timeUntilDue = timeUntilDue
        self.accentColor = accentColor
        self.showTimeIndicator = showTimeIndicator
        self.showActionButton = showActionButton
        self.actionIcon = actionIcon
        self.actionColor = actionColor
        self.onTap = onTap
        self.onAction = onAction
    }
    
    public var body: some View {
        Button(action: {
            onTap?()
        }) {
            HealthCard {
                HStack(spacing: Spacing.medium) {
                    // Time Period Indicator
                    if showTimeIndicator, let timePeriod = timePeriod {
                        timePeriodIndicator(timePeriod: timePeriod)
                    } else {
                        // Generic medication icon if no time period
                        medicationIcon
                    }
                    
                    // Medication Details
                    medicationDetails
                    
                    Spacer()
                    
                    // Action Button
                    if showActionButton {
                        actionButton
                    }
                }
            }
            .overlay(alignment: .leading) {
                // Accent color stripe
                Rectangle()
                    .fill(accentColor)
                    .frame(width: 4)
                    .clipShape(RoundedRectangle(cornerRadius: 2))
            }
        }
        .buttonStyle(.plain)
        .scaleEffect(isPressed ? 0.98 : 1.0)
        .animation(.easeInOut(duration: 0.1), value: isPressed)
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, perform: {}, onPressingChanged: { pressing in
            if onTap != nil {
                isPressed = pressing
            }
        })
    }
    
    @ViewBuilder
    private func timePeriodIndicator(timePeriod: MealTime) -> some View {
        VStack(spacing: Spacing.xs) {
            // Time period icon with background
            Circle()
                .fill(timePeriod.color.opacity(0.15))
                .frame(width: Size.avatarMedium, height: Size.avatarMedium)
                .overlay {
                    Image(systemName: timePeriod.icon)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(timePeriod.color)
                }
            
            // Time until due badge
            if let timeUntilDue = timeUntilDue {
                Text(timeUntilDue)
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, Spacing.small)
                    .padding(.vertical, 2)
                    .background(Color.healthWarning, in: Capsule())
            }
        }
    }
    
    @ViewBuilder
    private var medicationIcon: some View {
        Circle()
            .fill(accentColor.opacity(0.15))
            .frame(width: Size.avatarMedium, height: Size.avatarMedium)
            .overlay {
                Text(String(medicationName.prefix(1).uppercased()))
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(accentColor)
            }
    }
    
    @ViewBuilder
    private var medicationDetails: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            // Medication name
            Text(medicationName)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.primary)
            
            // Dosage and timing
            if let dosage = dosage, !dosage.isEmpty {
                HStack(spacing: Spacing.xs) {
                    Text(dosage)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    
                    if let timing = timing, !timing.isEmpty {
                        Text("•")
                            .font(.caption)
                            .foregroundStyle(.tertiary)
                        
                        Text(timing)
                            .font(.caption)
                            .foregroundStyle(timePeriod?.color ?? accentColor)
                    }
                }
            }
            
            // Instructions if available
            if let instructions = instructions, !instructions.isEmpty {
                Text(instructions)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }
        }
    }
    
    @ViewBuilder
    private var actionButton: some View {
        Button {
            onAction?()
        } label: {
            Image(systemName: actionIcon)
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(actionColor)
        }
        .buttonStyle(.borderless)
        .touchTarget()
    }
}

// MARK: - Convenience Initializers

extension MedicationCard {
    /// Create a medication card for upcoming medications
    static func upcoming(
        medicationName: String,
        dosage: String,
        timing: String,
        instructions: String? = nil,
        timePeriod: MealTime,
        timeUntilDue: String,
        onTap: (() -> Void)? = nil,
        onMarkTaken: @escaping () -> Void
    ) -> MedicationCard {
        MedicationCard(
            medicationName: medicationName,
            dosage: dosage,
            timing: timing,
            instructions: instructions,
            timePeriod: timePeriod,
            timeUntilDue: timeUntilDue,
            accentColor: timePeriod.color,
            showTimeIndicator: true,
            showActionButton: true,
            actionIcon: "checkmark.circle.fill",
            actionColor: .healthSuccess,
            onTap: onTap,
            onAction: onMarkTaken
        )
    }
    
    /// Create a medication card for general display
    static func display(
        medicationName: String,
        dosage: String? = nil,
        timing: String? = nil,
        instructions: String? = nil,
        accentColor: Color = .healthPrimary,
        onTap: (() -> Void)? = nil,
        onEdit: (() -> Void)? = nil
    ) -> MedicationCard {
        MedicationCard(
            medicationName: medicationName,
            dosage: dosage,
            timing: timing,
            instructions: instructions,
            accentColor: accentColor,
            showTimeIndicator: false,
            showActionButton: onEdit != nil,
            actionIcon: "pencil.circle.fill",
            actionColor: .healthPrimary,
            onTap: onTap,
            onAction: onEdit
        )
    }
}

// MARK: - Preview

#Preview("Medication Cards") {
    ScrollView {
        VStack(spacing: Spacing.medium) {
            Text("Upcoming Medications")
                .font(.title2.weight(.bold))
                .frame(maxWidth: .infinity, alignment: .leading)
            
            MedicationCard.upcoming(
                medicationName: "Lisinopril",
                dosage: "10mg",
                timing: "Before Breakfast",
                instructions: "Take with water on empty stomach",
                timePeriod: .breakfast,
                timeUntilDue: "2h 30m"
            ) {
                print("Marked as taken")
            }
            
            MedicationCard.upcoming(
                medicationName: "Metformin",
                dosage: "500mg",
                timing: "After Dinner",
                timePeriod: .dinner,
                timeUntilDue: "5h 15m"
            ) {
                print("Marked as taken")
            }
            
            Text("All Medications")
                .font(.title2.weight(.bold))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, Spacing.large)
            
            MedicationCard.display(
                medicationName: "Aspirin",
                dosage: "81mg",
                timing: "Daily",
                instructions: "Blood thinner - take with food"
            ) {
                print("Edit medication")
            }
            
            MedicationCard.display(
                medicationName: "Vitamin D3",
                dosage: "1000 IU",
                accentColor: .orange
            ) {
                print("Tapped medication")
            } onEdit: {
                print("Edit vitamin")
            }
        }
        .padding(Spacing.medium)
    }
}
