//
//  MedicationTimelineView.swift
//  Walnut
//
//  Created by Mayank Gandhi on 10/09/25.
//  Copyright © 2025 m. All rights reserved.
//

import SwiftUI
import WalnutDesignSystem

/// Main timeline view organizing medications by time slots throughout the day
struct MedicationTimelineView: View {
    
    // MARK: - Properties
    
    let scheduledDoses: [TimeSlot: [ScheduledDose]]
    
    // MARK: - Actions
    
    enum DoseAction {
        case markTaken
        case markMissed
        case markSkipped
        case edit
    }
    
    // MARK: - Body
    
    var body: some View {
        LazyVStack(spacing: Spacing.medium) {
            ForEach(TimeSlot.allCases) { timeSlot in
                if let doses = scheduledDoses[timeSlot], !doses.isEmpty {
                    TimeSlotSection(
                        timeSlot: timeSlot,
                        doses: doses,
                    )
                }
            }
        }
        .padding(.horizontal, Spacing.medium)
    }
}

// MARK: - Time Slot Section Component

/// Section displaying medications for a specific time slot (morning, afternoon, etc.)
struct TimeSlotSection: View {
    
    // MARK: - Properties
    
    let timeSlot: TimeSlot
    let doses: [ScheduledDose]
    
    // MARK: - Body
    
    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.small) {
            // Time slot header
            TimeSlotHeader(timeSlot: timeSlot, doseCount: doses.count)
            
            // Doses for this time slot
            ForEach(doses) { dose in
                MedicationDoseCard(
                    dose: dose
                )
            }
        }
    }
}

// MARK: - Time Slot Header Component

/// Header component for each time slot showing icon, name, and summary info
struct TimeSlotHeader: View {
    
    // MARK: - Properties
    
    let timeSlot: TimeSlot
    let doseCount: Int
    
    // MARK: - Body
    
    var body: some View {
        HStack {
            // Time slot icon and name
            HStack(spacing: Spacing.small) {
                Image(systemName: timeSlot.icon)
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(timeSlot.color)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(timeSlot.displayName)
                        .font(.headline.weight(.semibold))
                        .foregroundStyle(.primary)
                    
                    Text("\(doseCount) medication\(doseCount == 1 ? "" : "s")")
                        .font(.caption.weight(.medium))
                        .foregroundStyle(.secondary)
                }
            }
            
            Spacer()
            
            // Time range indicator
            Text(timeRangeText)
                .font(.caption.weight(.medium))
                .foregroundStyle(.tertiary)
                .padding(.horizontal, Spacing.xs)
                .padding(.vertical, 4)
                .background(.quaternary)
                .cornerRadius(6)
        }
        .padding(.bottom, Spacing.xs)
    }
    
    private var timeRangeText: String {
        let range = timeSlot.timeRange
        
        if timeSlot == .night {
            return "\(formatHour(range.start)) PM - \(formatHour(range.end)) AM"
        } else {
            let startPeriod = range.start < 12 ? "AM" : "PM"
            let endPeriod = range.end < 12 ? "AM" : "PM"
            return "\(formatHour(range.start)) \(startPeriod) - \(formatHour(range.end)) \(endPeriod)"
        }
    }
    
    private func formatHour(_ hour: Int) -> String {
        if hour == 0 { return "12" }
        if hour <= 12 { return "\(hour)" }
        return "\(hour - 12)"
    }
}

// MARK: - Medication Dose Card Component

/// Card component displaying individual medication dose with status and actions
struct MedicationDoseCard: View {
    
    // MARK: - Properties
    
    let dose: ScheduledDose
    
    @State private var showingActionSheet = false
    
    // MARK: - Body
    
    var body: some View {
        HealthCard {
            HStack(spacing: Spacing.medium) {
               // Medication info
                VStack(alignment: .leading, spacing: Spacing.xs) {
                    HStack {
                        Text(dose.medication.name ?? "Unknown Medication")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.primary)
                        
                        Spacer()
                        
                        Text(dose.displayTime)
                            .font(.caption.weight(.medium))
                            .foregroundStyle(.secondary)
                    }
                    
                    if let dosage = dose.medication.dosage {
                        Text(dosage)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    
                    // Meal relation info
                    if let mealRelation = dose.mealRelation {
                        MealRelationMarker(mealRelation: mealRelation)
                    }
                    
                    // Instructions (if available)
                    if let instructions = dose.medication.instructions, !instructions.isEmpty {
                        Text(instructions)
                            .font(.caption)
                            .foregroundStyle(.tertiary)
                            .lineLimit(2)
                    }
                }
                

            }
            .padding(Spacing.medium)
        }
    }
    
  
}

// MARK: - Meal Time Marker Component

/// Component showing medication's relationship to meal times
struct MealRelationMarker: View {
    
    // MARK: - Properties
    
    let mealRelation: MealRelation
    
    // MARK: - Body
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: mealRelation.mealTime.icon)
                .font(.caption.weight(.medium))
                .foregroundStyle(mealRelation.mealTime.color)
            
            Text(mealRelation.displayText)
                .font(.caption.weight(.medium))
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, Spacing.xs)
        .padding(.vertical, 2)
        .background(mealRelation.mealTime.color.opacity(0.1))
        .cornerRadius(8)
    }
}

// MARK: - Preview

#Preview {
    let sampleDoses: [TimeSlot: [ScheduledDose]] = [
        .morning: [
            ScheduledDose(
                medication: .sampleMedication,
                scheduledTime: Calendar.current.date(bySettingHour: 8, minute: 0, second: 0, of: Date()) ?? Date(),
                timeSlot: .morning,
                mealRelation: MealRelation(mealTime: .breakfast, timing: .before, offsetMinutes: -15),
            ),
            ScheduledDose(
                medication: .complexMedication,
                scheduledTime: Calendar.current.date(bySettingHour: 9, minute: 30, second: 0, of: Date()) ?? Date(),
                timeSlot: .morning,
                mealRelation: nil,
            )
        ],
        .evening: [
            ScheduledDose(
                medication: .hourlyMedication,
                scheduledTime: Calendar.current.date(bySettingHour: 18, minute: 0, second: 0, of: Date()) ?? Date(),
                timeSlot: .evening,
                mealRelation: MealRelation(mealTime: .dinner, timing: .after, offsetMinutes: 30),
            )
        ]
    ]
    
    ScrollView {
        MedicationTimelineView(
            scheduledDoses: sampleDoses,
        )
    }
    .background(Color(.systemGroupedBackground))
}
