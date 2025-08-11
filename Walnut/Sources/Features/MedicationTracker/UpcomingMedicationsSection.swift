//
//  UpcomingMedicationsSection.swift
//  Walnut
//
//  Created by Mayank Gandhi on 01/08/25.
//  Copyright © 2025 m. All rights reserved.
//

import SwiftUI
import WalnutDesignSystem

struct UpcomingMedicationsSection: View {
    
    let patient: Patient
    @Environment(\.modelContext) private var modelContext
    @State private var activeMedications: [Medication] = []
    @State private var medicationTracker = MedicationTracker()
    @State private var currentTime = Date()
    
    private var upcomingMedications: [MedicationTracker.MedicationScheduleInfo] {
        medicationTracker.getUpcomingMedications(activeMedications, withinHours: 6)
    }
    
    var body: some View {
        Section {
            if upcomingMedications.isEmpty {
                emptyStateView
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
            } else {
                ForEach(Array(upcomingMedications.enumerated()), id: \.element.medication.id) { index, medicationInfo in
                    medicationCardView(medicationInfo: medicationInfo)
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                        .listRowInsets(EdgeInsets(top: Spacing.xs, leading: 0, bottom: Spacing.xs, trailing: 0))
                }
            }
        } header: {
            sectionHeaderView
        }
        .onAppear {
            loadActiveMedications()
            startTimer()
        }
    }
    
    // MARK: - Subviews
    
    private var sectionHeaderView: some View {
        HStack(spacing: Spacing.small) {
            Image(systemName: "clock.badge.fill")
                .font(.headline)
                .foregroundStyle(Color.healthWarning)
            
            Text("Upcoming Medications")
                .font(.headline.weight(.semibold))
            
            Spacer()
            
            if !upcomingMedications.isEmpty {
                Text("Next 6 hours")
                    .font(.caption.weight(.medium))
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, Spacing.small)
                    .padding(.vertical, Spacing.xs)
                    .background(Color.healthWarning.opacity(0.1))
                    .clipShape(Capsule())
            }
        }
    }
    
    private var emptyStateView: some View {
        HealthCard(padding: Spacing.large) {
            VStack(spacing: Spacing.medium) {
                WalnutDesignSystem.StatusIndicator(status: HealthStatus.good, showIcon: true)
                    .scaleEffect(2.0)
                
                VStack(spacing: Spacing.xs) {
                    Text("All caught up!")
                        .font(.headline.weight(.semibold))
                        .foregroundStyle(.primary)
                    
                    Text("No medications due in the next 6 hours")
                        .font(.body)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
            }
            .frame(maxWidth: .infinity)
        }
    }
    
    private func loadActiveMedications() {
        let activeCases = patient.medicalCases.filter { $0.isActive }
        let medications = activeCases.flatMap { $0.prescriptions.flatMap { $0.medications } }
        self.activeMedications = medications
    }
    
    private func medicationCardView(medicationInfo: MedicationTracker.MedicationScheduleInfo) -> some View {
        HealthCard {
            HStack(spacing: Spacing.medium) {
                // Time Period Indicator
                timePeriodIndicator(for: medicationInfo)
                
                // Medication Details
                medicationDetails(for: medicationInfo)
                
                Spacer()
                
                // Action Button
                actionButton(for: medicationInfo)
            }
        }
        .overlay(alignment: .leading) {
            // Time period accent
            Rectangle()
                .fill(medicationInfo.timePeriod.color)
                .frame(width: 4)
                .clipShape(RoundedRectangle(cornerRadius: 2))
        }
    }
    
    @ViewBuilder
    private func timePeriodIndicator(for medicationInfo: MedicationTracker.MedicationScheduleInfo) -> some View {
        VStack(spacing: Spacing.xs) {
            // Time period icon with background
            Circle()
                .fill(medicationInfo.timePeriod.color.opacity(0.15))
                .frame(width: Size.avatarMedium, height: Size.avatarMedium)
                .overlay {
                    Image(systemName: medicationInfo.timePeriod.icon)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(medicationInfo.timePeriod.color)
                }
            
            // Time until due badge
            if let timeUntilDue = medicationInfo.timeUntilDue {
                Text(medicationTracker.formatTimeUntilDue(timeUntilDue))
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, Spacing.small)
                    .padding(.vertical, 2)
                    .background(Color.healthWarning, in: Capsule())
            }
        }
    }
    
    @ViewBuilder
    private func medicationDetails(for medicationInfo: MedicationTracker.MedicationScheduleInfo) -> some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            // Medication name
            Text(medicationInfo.medication.name)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.primary)
            
            // Dosage and timing
            HStack(spacing: Spacing.xs) {
                Text(medicationInfo.dosageText)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                Text("•")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
                
                Text(medicationInfo.displayTime)
                    .font(.caption)
                    .foregroundStyle(medicationInfo.timePeriod.color)
            }
            
            // Instructions if available
            if let instructions = medicationInfo.medication.instructions, !instructions.isEmpty {
                Text(instructions)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
        }
    }
    
    @ViewBuilder
    private func actionButton(for medicationInfo: MedicationTracker.MedicationScheduleInfo) -> some View {
        Button {
            markMedicationTaken(medicationInfo)
        } label: {
            WalnutDesignSystem.StatusIndicator(status: HealthStatus.good, showIcon: true)
                .scaleEffect(1.5)
        }
        .buttonStyle(.borderless)
        .touchTarget()
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: currentTime)
    }
    
    private func startTimer() {
        Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { _ in
            currentTime = Date()
        }
    }
    
    private func markMedicationTaken(_ medicationInfo: MedicationTracker.MedicationScheduleInfo) {
        let impactFeedback = UIImpactFeedbackGenerator(style: .rigid)
        impactFeedback.prepare()
        impactFeedback.impactOccurred(intensity: 0.8)
        
        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
            currentTime = Date()
        }
        
        print("Marked \(medicationInfo.medication.name) as taken")
    }
}


