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
            
            // Doses for this time slot in 2-column grid
            LazyVGrid(
                columns: [
                    GridItem(.flexible(), spacing: Spacing.small),
                    GridItem(.flexible(), spacing: Spacing.small)
                ],
                spacing: Spacing.small
            ) {
                ForEach(doses) { dose in
                    MedicationDoseCard(
                        dose: dose
                    )
                }
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
                .foregroundStyle(Color.white)
                .padding(.horizontal, Spacing.xs)
                .padding(.vertical, 4)
                .background(timeSlot.color)
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
        VStack(alignment: .leading, spacing: Spacing.small) {
            VStack(alignment: .leading) {
                Text(dose.medication.name ?? "Unknown")
                    .font(.system(.subheadline, design: .rounded, weight: .semibold))
                    .foregroundStyle(.primary)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                
                // Dosage information
                if let dosage = dose.medication.dosage {
                    Text(dosage)
                        .font(.caption.weight(.medium))
                        .foregroundStyle(Color.healthPrimary)
                        .padding(.horizontal, Spacing.xs)
                        .padding(.vertical, 2)
                        .background(
                            Color.healthPrimary.opacity(0.1),
                            in: Capsule()
                        )
                }
            }
            Text(dose.displayTime)
                .font(.caption2.weight(.medium))
                .foregroundStyle(.secondary)
            
            // Meal relation badge
            if let mealRelation = dose.mealRelation {
                MealRelationMarker(mealRelation: mealRelation)
            }
            
            // Instructions (compact)
            if let instructions = dose.medication.instructions, !instructions.isEmpty {
                Text(instructions.lowercased())
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .lineLimit(4)
                    .truncationMode(.tail)
            }
            Spacer()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .glassEffect(.clear, in: RoundedRectangle(cornerRadius: 12))
    }
    
    // MARK: - Computed Properties
    
    /// Status color based on dose state
    private var statusColor: Color {
        return .healthPrimary
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
}
