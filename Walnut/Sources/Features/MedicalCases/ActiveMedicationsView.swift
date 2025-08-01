//
//  ActiveMedicationsView.swift
//  Walnut
//
//  Created by Mayank Gandhi on 01/08/25.
//  Copyright © 2025 m. All rights reserved.
//

import SwiftUI

struct ActiveMedicationsView: View {
    let medications: [Medication]
    let onEditTapped: () -> Void
    
    @State private var medicationTracker = MedicationTracker()
    
    private var groupedMedications: [MedicationTracker.TimePeriod: [MedicationTracker.MedicationScheduleInfo]] {
        medicationTracker.groupMedicationsByTimePeriod(medications)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Header
            HStack {
                HStack(spacing: 8) {
                    Image(systemName: "pills.fill")
                        .font(.title2)
                        .foregroundStyle(.linearGradient(colors: [.blue, .purple], startPoint: .topLeading, endPoint: .bottomTrailing))
                        .apply { image in
                            if #available(iOS 17.0, *) {
                                image
                                    .symbolRenderingMode(.multicolor)
                                    .symbolEffect(.variableColor.iterative.dimInactiveLayers.nonReversing)
                            } else {
                                image
                            }
                        }
                    
                    Text("Active Medications")
                        .font(.headline)
                        .fontWeight(.semibold)
                }
                
                Spacer()
                
                Button("Edit") {
                    onEditTapped()
                }
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.blue)
            }
            
            // Time Period Groups
            LazyVStack(spacing: 16) {
                ForEach(MedicationTracker.TimePeriod.allCases, id: \.self) { timePeriod in
                    if let medicationsForPeriod = groupedMedications[timePeriod], !medicationsForPeriod.isEmpty {
                        timePeriodSection(timePeriod: timePeriod, medications: medicationsForPeriod)
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
    }
    
    private func timePeriodSection(timePeriod: MedicationTracker.TimePeriod, medications: [MedicationTracker.MedicationScheduleInfo]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            // Time Period Header
            HStack(spacing: 8) {
                Image(systemName: timePeriod.icon)
                    .font(.title3)
                    .foregroundStyle(.linearGradient(colors: timePeriod.gradientColors, startPoint: .topLeading, endPoint: .bottomTrailing))
                    .apply { image in
                        if #available(iOS 17.0, *) {
                            image
                                .symbolRenderingMode(.hierarchical)
                                .symbolEffect(.breathe.byLayer)
                        } else {
                            image
                        }
                    }
                
                Text(timePeriod.rawValue)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Text("\(medications.count)")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .frame(width: 20, height: 20)
                    .background(Circle().fill(.linearGradient(colors: timePeriod.gradientColors, startPoint: .topLeading, endPoint: .bottomTrailing)))
            }
            
            // Medications for this time period
            LazyVStack(spacing: 8) {
                ForEach(Array(medications.enumerated()), id: \.element.medication.id) { index, medicationInfo in
                    medicationCard(medicationInfo: medicationInfo, timePeriod: timePeriod)
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.thinMaterial)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(.linearGradient(colors: [timePeriod.color.opacity(0.08), timePeriod.color.opacity(0.03)], startPoint: .topLeading, endPoint: .bottomTrailing))
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(.linearGradient(colors: timePeriod.gradientColors.map { $0.opacity(0.4) }, startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 1.5)
        )
    }
    
    private func medicationCard(medicationInfo: MedicationTracker.MedicationScheduleInfo, timePeriod: MedicationTracker.TimePeriod) -> some View {
        HStack(spacing: 12) {
            // Medication Icon
            Circle()
                .fill(.linearGradient(colors: timePeriod.gradientColors, startPoint: .topLeading, endPoint: .bottomTrailing))
                .frame(width: 8, height: 8)
                .shadow(.drop(color: timePeriod.color.opacity(0.6), radius: 2, x: 0, y: 1))
            
            VStack(alignment: .leading, spacing: 4) {
                // Medication Name
                Text(medicationInfo.medication.name)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                
                // Dosage and Timing
                HStack(spacing: 8) {
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
                
                // Instructions (if available)
                if let instructions = medicationInfo.medication.instructions, !instructions.isEmpty {
                    Text(instructions)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                        .padding(.top, 2)
                }
            }
            
            Spacer()
            
            // Duration Badge
            VStack(alignment: .trailing, spacing: 4) {
                Text("\(medicationInfo.medication.numberOfDays) days")
                    .font(.caption2)
                    .fontWeight(.medium)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(
                        Capsule()
                            .fill(.linearGradient(colors: [.green.opacity(0.2), .green.opacity(0.1)], startPoint: .topLeading, endPoint: .bottomTrailing))
                    )
                    .foregroundColor(.green)
                    .overlay(
                        Capsule()
                            .stroke(.green.opacity(0.3), lineWidth: 0.5)
                    )
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(.ultraThinMaterial)
                .shadow(.inner(color: .black.opacity(0.05), radius: 2, x: 0, y: 1))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(.quaternary, lineWidth: 0.5)
        )
    }
}

#Preview {
    let sampleMedications = [
        Medication(
            id: UUID(),
            name: "Paracetamol",
            frequency: [
                MedicationSchedule(mealTime: .breakfast, timing: .after, dosage: "500mg"),
                MedicationSchedule(mealTime: .dinner, timing: .after, dosage: "500mg")
            ],
            numberOfDays: 5,
            dosage: "500mg",
            instructions: "Take with plenty of water"
        ),
        Medication(
            id: UUID(),
            name: "Vitamin D",
            frequency: [
                MedicationSchedule(mealTime: .breakfast, timing: .after, dosage: "1000 IU")
            ],
            numberOfDays: 30,
            dosage: "1000 IU",
            instructions: "Take with food"
        ),
        Medication(
            id: UUID(),
            name: "Melatonin",
            frequency: [
                MedicationSchedule(mealTime: .bedtime, timing: nil, dosage: "3mg")
            ],
            numberOfDays: 7,
            dosage: "3mg",
            instructions: "Take 30 minutes before bed"
        )
    ]
    
    return ScrollView {
        ActiveMedicationsView(medications: sampleMedications) {
            print("Edit tapped")
        }
        .padding()
    }
    .background(Color(.systemGroupedBackground))
}

// MARK: - View Extension for Conditional Modifiers
extension View {
    @ViewBuilder
    func apply<T: View>(@ViewBuilder _ transform: (Self) -> T) -> some View {
        transform(self)
    }
}