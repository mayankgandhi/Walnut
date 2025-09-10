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
    let onAction: (MedicationTimelineView.DoseAction) -> Void
    
    @State private var showingActionSheet = false
    
    var body: some View {
        HealthCard {
            HStack(spacing: Spacing.medium) {
                // Dose status indicator
                DoseStatusIndicator(status: dose.status)
                
                // Medication information
                medicationInfo
                
                Spacer()
                
                // Timing and actions
                VStack(alignment: .trailing, spacing: Spacing.xs) {
                    timingInfo
                    actionButton
                }
            }
            .padding(Spacing.medium)
        }
        .confirmationDialog(
            "Medication Actions",
            isPresented: $showingActionSheet,
            titleVisibility: .visible
        ) {
            actionSheetButtons
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
                    Image(systemName: "scalemass.fill")
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
                .foregroundStyle(dose.status.color)
            
            if dose.isOverdue {
                Text("Overdue")
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(.red)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(.red.opacity(0.15))
                    .clipShape(Capsule())
            }
        }
    }
    
    @ViewBuilder
    private var actionButton: some View {
        Button {
            if dose.status == .scheduled {
                // Quick mark as taken for scheduled doses
                onAction(.markTaken)
            } else {
                // Show action sheet for other statuses
                showingActionSheet = true
            }
        } label: {
            Image(systemName: dose.status == .scheduled ? "checkmark.circle" : "ellipsis.circle")
                .font(.system(size: 20, weight: .medium))
                .foregroundStyle(dose.status == .scheduled ? .green : .secondary)
        }
        .buttonStyle(.plain)
    }
    
    @ViewBuilder
    private var actionSheetButtons: some View {
        if dose.status == .scheduled {
            Button("Mark as Taken") {
                onAction(.markTaken)
            }
            
            Button("Mark as Missed") {
                onAction(.markMissed)
            }
            
            Button("Skip This Dose") {
                onAction(.markSkipped)
            }
        } else {
            Button("Mark as Taken") {
                onAction(.markTaken)
            }
            
            Button("Mark as Scheduled") {
                // Reset to scheduled status
                onAction(.markTaken) // Placeholder - should reset status
            }
        }
        
        Button("Edit Medication") {
            onAction(.edit)
        }
        
        Button("Cancel", role: .cancel) { }
    }
}

/// Component for displaying dose status with visual indicator
struct DoseStatusIndicator: View {
    let status: DoseStatus
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(status.color.opacity(0.3), lineWidth: 2)
                .frame(width: 40, height: 40)
            
            Circle()
                .fill(status.color.opacity(0.15))
                .frame(width: 36, height: 36)
            
            Image(systemName: status.icon)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(status.color)
        }
    }
}

/// Meal time marker component for showing meal reference points
struct MealTimeMarker: View {
    let mealTime: MealTime
    let isUpcoming: Bool
    
    var body: some View {
        HStack(spacing: Spacing.small) {
            Image(systemName: mealTime.icon)
                .font(.caption)
                .foregroundStyle(mealTime.color)
                .frame(width: 20, height: 20)
                .background(mealTime.color.opacity(0.15))
                .clipShape(Circle())
            
            Text(mealTime.displayName)
                .font(.caption.weight(.medium))
                .foregroundStyle(isUpcoming ? mealTime.color : .secondary)
            
            if isUpcoming {
                Text("upcoming")
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(mealTime.color)
                    .clipShape(Capsule())
            }
            
            Spacer()
        }
        .padding(.horizontal, Spacing.medium)
        .padding(.vertical, Spacing.small)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
}

// MARK: - Preview Support

#Preview("Timeline View") {
    NavigationView {
        ScrollView {
            MedicationTimelineView(
                scheduledDoses: sampleTimelineData(),
                onDoseAction: { dose, action in
                    print("Action \(action) for dose: \(dose.medication.name ?? "Unknown")")
                }
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
        status: .scheduled
    )
    
    let eveningDose = ScheduledDose(
        medication: Medication.complexMedication,
        scheduledTime: calendar.date(bySettingHour: 18, minute: 0, second: 0, of: today) ?? today,
        timeSlot: .evening,
        mealRelation: MealRelation(mealTime: .dinner, timing: .after, offsetMinutes: 30),
        status: .taken,
        actualTakenTime: calendar.date(bySettingHour: 18, minute: 15, second: 0, of: today)
    )
    
    return [
        .morning: [morningDose],
        .evening: [eveningDose]
    ]
}
