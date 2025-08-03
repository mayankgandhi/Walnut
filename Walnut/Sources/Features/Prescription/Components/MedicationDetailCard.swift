//
//  MedicationDetailCard.swift
//  Walnut
//
//  Created by Mayank Gandhi on 03/08/25.
//  Copyright © 2025 m. All rights reserved.
//

import SwiftUI

struct MedicationDetailCard: View {
    let medication: Medication
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            medicationHeader
            
            if !medication.frequency.isEmpty {
                scheduleSection
            }
            
            if let instructions = medication.instructions, !instructions.isEmpty {
                instructionsSection(instructions: instructions)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.secondarySystemGroupedBackground))
                .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
        )
    }
    
    private var medicationHeader: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(.green)
                .frame(width: 8, height: 8)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(medication.name)
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                    .lineLimit(2)
                
                if let dosage = medication.dosage, !dosage.isEmpty {
                    HStack(spacing: 4) {
                        Image(systemName: "pills.circle")
                            .font(.caption2)
                            .foregroundColor(.blue)
                        
                        Text(dosage)
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            Spacer()
            
            Text("\(medication.numberOfDays) days")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.green)
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(
                    Capsule()
                        .fill(.green.opacity(0.1))
                )
                .overlay(
                    Capsule()
                        .stroke(.green.opacity(0.3), lineWidth: 1)
                )
        }
    }
    
    private var scheduleSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "clock")
                    .font(.subheadline)
                    .foregroundColor(.orange)
                
                Text("Schedule")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                    .textCase(.uppercase)
                
                Spacer()
                
                Text("\(medication.frequency.count) times")
                    .font(.caption2)
                    .fontWeight(.medium)
                    .foregroundColor(.orange)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(
                        Capsule()
                            .fill(.orange.opacity(0.1))
                    )
            }
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: min(medication.frequency.count, 2)), spacing: 10) {
                ForEach(medication.frequency.indices, id: \.self) { index in
                    MedicationScheduleChip(
                        schedule: medication.frequency[index],
                        style: .premium
                    )
                }
            }
        }
    }
    
    private func instructionsSection(instructions: String) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Image(systemName: "doc.text")
                    .font(.subheadline)
                    .foregroundColor(.blue)
                
                Text("Instructions")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                    .textCase(.uppercase)
            }
            
            Text(instructions)
                .font(.caption)
                .foregroundColor(.primary)
                .lineSpacing(3)
                .padding(10)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(.blue.opacity(0.05))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(.blue.opacity(0.2), lineWidth: 1)
                )
        }
    }
}

#Preview {
    MedicationDetailCard(medication: Medication.sampleMedication)
        .padding()
        .background(Color(.systemGroupedBackground))
}