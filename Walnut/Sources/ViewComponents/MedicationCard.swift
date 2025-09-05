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
    
    @State private var isPressed = false
    
    init(
        medicationName: String,
        dosage: String? = nil,
        timing: String? = nil,
        instructions: String? = nil,
        timePeriod: MealTime? = nil,
        timeUntilDue: String? = nil,
        accentColor: Color = .healthPrimary,
        showTimeIndicator: Bool = true
    ) {
        self.medicationName = medicationName
        self.dosage = dosage
        self.timing = timing
        self.instructions = instructions
        self.timePeriod = timePeriod
        self.timeUntilDue = timeUntilDue
        self.accentColor = accentColor
        self.showTimeIndicator = showTimeIndicator
    }
    
    public var body: some View {
        VStack {
                // Time Period Indicator
                if showTimeIndicator, let timePeriod = timePeriod {
                    timePeriodIndicator(timePeriod: timePeriod)
                } else {
                    // Generic medication icon if no time period
                    medicationIcon
                }
                
                // Medication Details
                medicationDetails            
            
            instructionsRow
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .padding(Spacing.small)
        .background(
            (timePeriod?.color ?? Color.healthPrimary).opacity(0.1)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 6)
                .stroke((timePeriod?.color ?? Color.healthPrimary), lineWidth: 1)
        )
        
    }
    
    @ViewBuilder
    private func timePeriodIndicator(timePeriod: MealTime) -> some View {
        // Time period icon with background
        Circle()
            .fill(timePeriod.color.opacity(0.15))
            .frame(width: Size.avatarMedium, height: Size.avatarMedium)
            .overlay {
                Image(timePeriod.iconString)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 36, height: 36)
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
        // Medication name
        Text(medicationName)
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(.primary)
        
        // Dosage and timing
        if let dosage = dosage, !dosage.isEmpty {
            Text(dosage)
                .font(.caption)
                .foregroundStyle(.secondary)
            
            
        }
        
        
    }
    
    @ViewBuilder
    private var instructionsRow: some View {
        VStack {
            if let timing = timing, !timing.isEmpty {
                Text(timing)
                    .font(.caption)
                    .foregroundStyle(timePeriod?.color ?? accentColor)
            }
            
            // Instructions if available
            if let instructions = instructions,
               !instructions.isEmpty {
                Text(instructions)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }
        }
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
            
        )
    }
    
    /// Create a medication card for general display
    static func display(
        medicationName: String,
        dosage: String? = nil,
        timing: String? = nil,
        instructions: String? = nil,
        accentColor: Color = .healthPrimary
    ) -> MedicationCard {
        MedicationCard(
            medicationName: medicationName,
            dosage: dosage,
            timing: timing,
            instructions: instructions,
            accentColor: accentColor,
            showTimeIndicator: false
        )
    }
}

// MARK: - Preview

#Preview {
    MedicationCard.upcoming(
        medicationName: "Lisinopril",
        dosage: "10mg",
        timing: "Before Breakfast",
        instructions: "Take with water on empty stomach",
        timePeriod: .breakfast,
        timeUntilDue: "2h 30m"
    )
}

#Preview("Medication Cards") {
    ScrollView {
        
        Text("Upcoming Medications")
            .font(.title2.weight(.bold))
            .frame(maxWidth: .infinity, alignment: .leading)
        
        
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible()),
        ], spacing: Spacing.medium) {
            
            MedicationCard.upcoming(
                medicationName: "Lisinopril",
                dosage: "10mg",
                timing: "Before Breakfast",
                instructions: "Take with water on empty stomach",
                timePeriod: .breakfast,
                timeUntilDue: "2h 30m"
            )
            
            MedicationCard.upcoming(
                medicationName: "Metformin",
                dosage: "500mg",
                timing: "After Dinner",
                timePeriod: .dinner,
                timeUntilDue: "5h 15m"
            )
            
            MedicationCard.upcoming(
                medicationName: "Metformin",
                dosage: "500mg",
                timing: "After Dinner",
                timePeriod: .dinner,
                timeUntilDue: "5h 15m"
            )
            
        }
        .padding(Spacing.medium)
        
        VStack {
            Text("All Medications")
                .font(.title2.weight(.bold))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, Spacing.large)
            
            MedicationCard.display(
                medicationName: "Aspirin",
                dosage: "81mg",
                timing: "Daily",
                instructions: "Blood thinner - take with food"
            )
            
            MedicationCard.display(
                medicationName: "Vitamin D3",
                dosage: "1000 IU",
                accentColor: .orange
            )
        }
    }
}
