//
//  TimelineView.swift
//  Walnut
//
//  Created by Mayank Gandhi on 10/09/25.
//  Copyright © 2025 m. All rights reserved.
//

import SwiftUI
import WalnutDesignSystem

/// Enhanced medication card for timeline usage with dose status tracking
struct TimelineMedicationCard: View {
    let dose: ScheduledDose
    
    @State private var showingActionSheet = false
    
    var body: some View {
        HealthCard {
            HStack(spacing: Spacing.medium) {
                medicationInfo
                Spacer()
                timingInfo                
            }
        }
        
    }
    
    @ViewBuilder
    private var medicationInfo: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            // Medication name
            Text(dose.medication.name ?? "Unknown Medication")
                .font(.headline.weight(.bold))
                .foregroundStyle(.primary)
                .lineLimit(2)
            
            // Dosage
            if let dosage = dose.medication.dosage, !dosage.isEmpty {
                HStack(spacing: 4) {
                    Image(systemName: "checkmark")
                        .font(.caption2)
                        .foregroundStyle(dose.timeSlot.color)
                    
                    Text(dosage)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.primary)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(dose.timeSlot.color.opacity(0.15))
                        .clipShape(Capsule())
                }
            }
            
            // Meal relation
            if let mealRelation = dose.mealRelation {
                HStack(spacing: 4) {
                    Image(systemName: mealRelation.mealTime.icon)
                        .font(.caption2)
                        .foregroundStyle(mealRelation.mealTime.color)
                    
                    Text(mealRelation.displayText)
                        .font(.caption.weight(.medium))
                        .foregroundStyle(.secondary)
                }
            }
        }
    }
    
    @ViewBuilder
    private var timingInfo: some View {
        VStack(alignment: .trailing, spacing: 2) {
            Text(dose.displayTime)
                .font(.subheadline.weight(.bold))
        }
    }
    
}

// MARK: - Preview Support

#Preview("Timeline View") {
    NavigationView {
        ScrollView {
            MedicationTimelineView(
                scheduledDoses: sampleTimelineData()
            )
        }
        .navigationTitle("Today's Schedule")
    }
}

private func sampleTimelineData() -> [TimeSlot: [ScheduledDose]] {
    let calendar = Calendar.current
    let today = Date()
    
    let morningDose = ScheduledDose(
        medication: Medication.sampleMedication,
        scheduledTime: calendar.date(bySettingHour: 8, minute: 0, second: 0, of: today) ?? today,
        timeSlot: .morning,
        mealRelation: MealRelation(mealTime: .breakfast, timing: .before, offsetMinutes: -15),
    )
    
    let eveningDose = ScheduledDose(
        medication: Medication.complexMedication,
        scheduledTime: calendar.date(bySettingHour: 18, minute: 0, second: 0, of: today) ?? today,
        timeSlot: .evening,
        mealRelation: MealRelation(mealTime: .dinner, timing: .after, offsetMinutes: 30),
    )
    
    return [
        .morning: [morningDose],
        .evening: [eveningDose]
    ]
}
