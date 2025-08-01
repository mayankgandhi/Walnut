//
//  UpcomingMedicationsView.swift
//  Walnut
//
//  Created by Mayank Gandhi on 01/08/25.
//  Copyright © 2025 m. All rights reserved.
//

import SwiftUI

struct UpcomingMedicationsView: View {
    let medications: [Medication]
    
    @State private var medicationTracker = MedicationTracker()
    @State private var currentTime = Date()
    
    private var upcomingMedications: [MedicationTracker.MedicationScheduleInfo] {
        medicationTracker.getUpcomingMedications(medications, withinHours: 6)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack(spacing: 8) {
                HStack(spacing: 8) {
                    Image(systemName: "clock.badge.fill")
                        .font(.title2)
                        .foregroundStyle(.linearGradient(colors: [.orange, .red], startPoint: .topLeading, endPoint: .bottomTrailing))
                    
                    Text("Upcoming Medications")
                        .font(.headline)
                        .fontWeight(.semibold)
                }
                
                Spacer()
                
                if !upcomingMedications.isEmpty {
                    Text("Next 6 hours")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(Color.orange.opacity(0.1))
                        .clipShape(Capsule())
                }
            }
            
            if upcomingMedications.isEmpty {
                // Empty State
                emptyStateView
            } else {
                // Upcoming Medications List
                LazyVStack(spacing: 12) {
                    ForEach(Array(upcomingMedications.enumerated()), id: \.element.medication.id) { index, medicationInfo in
                        upcomingMedicationCard(medicationInfo: medicationInfo, index: index)
                    }
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.regularMaterial)
                .shadow(.drop(color: .black.opacity(0.1), radius: 12, x: 0, y: 4))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(.linearGradient(colors: [.white.opacity(0.5), .clear], startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 1)
        )
        .onAppear {
            startTimer()
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 12) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 40))
                .foregroundStyle(.linearGradient(colors: [.green, .mint], startPoint: .topLeading, endPoint: .bottomTrailing))
                .apply { image in
                    if #available(iOS 17.0, *) {
                        image
                            .symbolEffect(.pulse.byLayer, options: .repeat(.continuous))
                            .symbolRenderingMode(.multicolor)
                    } else {
                        image
                    }
                }
            
            Text("All caught up!")
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.primary)
            
            Text("No medications due in the next 6 hours")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
    }
    
    private func upcomingMedicationCard(medicationInfo: MedicationTracker.MedicationScheduleInfo, index: Int) -> some View {
        HStack(spacing: 12) {
            // Time Indicator
            VStack(spacing: 4) {
                Image(systemName: medicationInfo.timePeriod.icon)
                    .font(.title3)
                    .foregroundStyle(.linearGradient(colors: medicationInfo.timePeriod.gradientColors, startPoint: .topLeading, endPoint: .bottomTrailing))
                
                if let timeUntilDue = medicationInfo.timeUntilDue {
                    Text(medicationTracker.formatTimeUntilDue(timeUntilDue))
                        .font(.caption2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(
                            Capsule()
                                .fill(.linearGradient(colors: [.orange, .red], startPoint: .topLeading, endPoint: .bottomTrailing))
                        )
                }
            }
            .frame(width: 50)
            
            // Medication Info
            VStack(alignment: .leading, spacing: 4) {
                Text(medicationInfo.medication.name)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                HStack(spacing: 6) {
                    Text(medicationInfo.dosageText)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("•")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text(medicationInfo.displayTime)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                if let instructions = medicationInfo.medication.instructions, !instructions.isEmpty {
                    Text(instructions)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                        .padding(.top, 1)
                }
            }
            
            Spacer()
            
            // Action Button
            Button(action: {
                // Handle medication taken action
                markMedicationTaken(medicationInfo)
            }) {
                Image(systemName: "checkmark.circle")
                    .font(.title2)
                    .foregroundStyle(.linearGradient(colors: [.green, .mint], startPoint: .topLeading, endPoint: .bottomTrailing))
                    .apply { image in
                        if #available(iOS 17.0, *) {
                            image
                                .symbolEffect(.bounce, value: currentTime)
                                .contentTransition(.symbolEffect(.replace))
                        } else {
                            image
                        }
                    }
            }
            .buttonStyle(.borderless)
            .scaleEffect(1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: currentTime)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.thinMaterial)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(.linearGradient(colors: [medicationInfo.timePeriod.color.opacity(0.08), medicationInfo.timePeriod.color.opacity(0.03)], startPoint: .topLeading, endPoint: .bottomTrailing))
                )
                .shadow(.inner(color: .white.opacity(0.3), radius: 1, x: 0, y: 1))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(.linearGradient(colors: medicationInfo.timePeriod.gradientColors.map { $0.opacity(0.4) }, startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 1.5)
        )
        .overlay(alignment: .leading) {
            Rectangle()
                .fill(.linearGradient(colors: medicationInfo.timePeriod.gradientColors, startPoint: .top, endPoint: .bottom))
                .frame(width: 3)
                .clipShape(RoundedRectangle(cornerRadius: 1.5))
        }
    }
    
    private func startTimer() {
        Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { _ in
            currentTime = Date()
        }
    }
    
    private func markMedicationTaken(_ medicationInfo: MedicationTracker.MedicationScheduleInfo) {
        // This would typically trigger some action to mark the medication as taken
        // For now, we'll just provide haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .rigid)
        impactFeedback.prepare()
        impactFeedback.impactOccurred(intensity: 0.8)
        
        // Update current time to trigger animation
        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
            currentTime = Date()
        }
        
        // You could implement medication tracking logic here
        print("Marked \(medicationInfo.medication.name) as taken")
    }
}

#Preview {
    let sampleMedications = [
        Medication(
            id: UUID(),
            name: "Paracetamol",
            frequency: [
                MedicationSchedule(mealTime: .lunch, timing: .after, dosage: "500mg"),
                MedicationSchedule(mealTime: .dinner, timing: .after, dosage: "500mg")
            ],
            numberOfDays: 5,
            dosage: "500mg",
            instructions: "Take with plenty of water"
        ),
        Medication(
            id: UUID(),
            name: "Vitamin B12",
            frequency: [
                MedicationSchedule(mealTime: .breakfast, timing: .after, dosage: "1000 mcg")
            ],
            numberOfDays: 30,
            dosage: "1000 mcg",
            instructions: "Take with food for better absorption"
        )
    ]
    
    return VStack(spacing: 20) {
        UpcomingMedicationsView(medications: sampleMedications)
        UpcomingMedicationsView(medications: []) // Empty state
    }
    .padding()
    .background(Color(.systemGroupedBackground))
}

// MARK: - View Extension for Conditional Modifiers
extension View {
    @ViewBuilder
    func apply<T: View>(@ViewBuilder _ transform: (Self) -> T) -> some View {
        transform(self)
    }
}