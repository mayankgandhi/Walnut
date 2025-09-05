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
    private let medication: Medication?
    private let medicationName: String
    private let dosage: String?
    private let timing: String?
    private let duration: String?
    private let timePeriod: MealTime?
    private let accentColor: Color
    
    // Initializer for Medication model
    init(
        medication: Medication,
    ) {
        self.medication = medication
        self.medicationName = medication.name ?? "Unknown Medication"
        self.dosage = medication.dosage
        self.duration = medication.duration?.displayText
        
        self.timing = nil
        self.timePeriod = nil
                
        self.accentColor = self.timePeriod?.color ?? Color.healthPrimary
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
                    durationSection
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
    
    @ViewBuilder
    private var durationSection: some View {
        if let duration = duration, !duration.isEmpty {
            HStack(spacing: 6) {
                Image(systemName: "calendar.badge.clock")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                Text(duration)
                    .font(.caption.weight(.medium))
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(Color.secondary.opacity(0.1))
                    .clipShape(Capsule())
                
                Spacer()
            }
        }
    }
    
}
