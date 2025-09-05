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
    private let timePeriod: MealTime?
    private let accentColor: Color
    
    init(
        medicationName: String,
        dosage: String? = nil,
        timing: String? = nil,
        timePeriod: MealTime? = nil,
        accentColor: Color = .healthPrimary,
    ) {
        self.medicationName = medicationName
        self.dosage = dosage
        self.timing = timing
        self.timePeriod = timePeriod
        self.accentColor = accentColor
    }
    
    public var body: some View {
        HealthCard {
            VStack(alignment: .leading, spacing: Spacing.medium) {
                // Header with icon and time indicator
                enhancedMedicationIcon
                
                // Medication content
                VStack(alignment: .leading, spacing: Spacing.small) {
                    medicationDetails
                    
                    timingSection
                    
                    
                }
            }
        }
        
    }
    
    @ViewBuilder
    private var enhancedMedicationIcon: some View {
        ZStack {
            // Animated background ring
            Circle()
                .stroke((timePeriod?.color ?? accentColor).opacity(0.3), lineWidth: 2)
                .frame(width: 52, height: 52)
            
            // Main icon background
            Circle()
                .fill(
                    LinearGradient(
                        colors: [
                            timePeriod?.color ?? accentColor,
                            (timePeriod?.color ?? accentColor).opacity(0.7)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 46, height: 46)
                .shadow(
                    color: (timePeriod?.color ?? accentColor).opacity(0.4),
                    radius: 4,
                    x: 0,
                    y: 2
                )
            
            // Icon content
            if let timePeriod = timePeriod {
                Image(systemName: timePeriod.icon)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(.white)
                    .symbolEffect(.pulse.wholeSymbol, options: .repeating.speed(0.6))
            } else {
                Text(String(medicationName.prefix(1).uppercased()))
                    .font(.system(size: 20, weight: .black))
                    .foregroundStyle(.white)
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
            // Enhanced medication name
            Text(medicationName)
                .font(.headline.weight(.bold))
                .foregroundStyle(.primary)
                .lineLimit(2)
                .multilineTextAlignment(.leading)
                .shadow(color: .black.opacity(0.05), radius: 1, x: 0, y: 1)
            
            // Enhanced dosage display
            if let dosage = dosage, !dosage.isEmpty {
                HStack(spacing: 4) {
                    Image(systemName: "scalemass.fill")
                        .font(.caption2)
                        .foregroundStyle(timePeriod?.color ?? accentColor)
                        .symbolEffect(.bounce, value: dosage)
                    
                    Text(dosage)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.primary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background((timePeriod?.color ?? accentColor).opacity(0.15))
                        .clipShape(Capsule())
                }
            }
        }
    }
    
    @ViewBuilder
    private var timingSection: some View {
        if let timing = timing, !timing.isEmpty {
            HStack(spacing: 6) {
                Image(systemName: "clock.fill")
                    .font(.caption)
                    .foregroundStyle(timePeriod?.color ?? accentColor)
                
                Text(timing)
                    .font(.caption.weight(.medium))
                    .foregroundStyle(timePeriod?.color ?? accentColor)
                
                Spacer()
                
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
        timePeriod: MealTime,
    ) -> MedicationCard {
        MedicationCard(
            medicationName: medicationName,
            dosage: dosage,
            timing: timing,
            timePeriod: timePeriod,
            accentColor: timePeriod.color,
            
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
            accentColor: accentColor,
        )
    }
}

// MARK: - Preview

#Preview("Single Rich Card") {
    VStack {
        MedicationCard.upcoming(
            medicationName: "Lisinopril",
            dosage: "10mg",
            timing: "Before Breakfast",
            timePeriod: .breakfast,
        )
        
        Spacer()
    }
    .padding()
    .background(Color(UIColor.systemGroupedBackground))
}

#Preview("Rich 2-Column Dynamic Grid") {
    ScrollView {
        VStack(alignment: .leading, spacing: Spacing.large) {
            
            Text("Rich Dynamic Medication Cards")
                .font(.title.weight(.bold))
                .frame(maxWidth: .infinity, alignment: .leading)
            
            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: Spacing.medium),
                GridItem(.flexible(), spacing: Spacing.medium)
            ], spacing: Spacing.medium) {
                
                MedicationCard.upcoming(
                    medicationName: "Lisinopril",
                    dosage: "10mg",
                    timing: "Before Breakfast",
                    timePeriod: .breakfast,
                )
                
                MedicationCard.upcoming(
                    medicationName: "Metformin",
                    dosage: "500mg",
                    timing: "After Dinner",
                    timePeriod: .dinner,
                )
                
                MedicationCard.upcoming(
                    medicationName: "Vitamin D3",
                    dosage: "2000 IU",
                    timing: "After Breakfast",
                    timePeriod: .breakfast,
                )
                
                MedicationCard.upcoming(
                    medicationName: "Atorvastatin",
                    dosage: "20mg",
                    timing: "At Bedtime",
                    timePeriod: .bedtime,
                )
                
                MedicationCard.upcoming(
                    medicationName: "Omeprazole",
                    dosage: "40mg",
                    timing: "Before Lunch",
                    timePeriod: .lunch,
                )
                
                MedicationCard.upcoming(
                    medicationName: "Aspirin",
                    dosage: "81mg",
                    timing: "After Breakfast",
                    timePeriod: .breakfast,
                )
                
            }
            
            Text("Display Mode Cards")
                .font(.title2.weight(.semibold))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, Spacing.large)
            
            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: Spacing.medium),
                GridItem(.flexible(), spacing: Spacing.medium)
            ], spacing: Spacing.medium) {
                
                MedicationCard.display(
                    medicationName: "Ibuprofen",
                    dosage: "200mg",
                    timing: "As needed",
                    accentColor: .red
                )
                
                MedicationCard.display(
                    medicationName: "Multivitamin",
                    dosage: "1 tablet",
                    timing: "Daily with breakfast",
                    accentColor: .green
                )
                
            }
        }
        .padding()
    }
    .background(Color(UIColor.systemGroupedBackground))
}
