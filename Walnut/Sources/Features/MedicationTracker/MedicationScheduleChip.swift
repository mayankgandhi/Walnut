//
//  MedicationScheduleChip.swift
//  Walnut
//
//  Created by Mayank Gandhi on 03/08/25.
//  Copyright © 2025 m. All rights reserved.
//

import SwiftUI

struct MedicationScheduleChip: View {
    let schedule: MedicationSchedule
    let style: ChipStyle
    
    enum ChipStyle {
        case premium
        case compact
    }
    
    var body: some View {
        switch style {
        case .premium:
            premiumChip
        case .compact:
            compactChip
        }
    }
    
    private var premiumChip: some View {
        let mealTimeColor: [Color] = {
            switch schedule.mealTime {
            case .breakfast: return [.orange, .yellow]
            case .lunch: return [.yellow, .orange]
            case .dinner: return [.purple, .pink]
            case .bedtime: return [.indigo, .purple]
            }
        }()
        
        return VStack(spacing: 6) {
            HStack(spacing: 6) {
                Image(systemName: schedule.mealTime.icon)
                    .font(.subheadline)
                    .foregroundColor(mealTimeColor[0])
                
                VStack(alignment: .leading, spacing: 1) {
                    Text(schedule.mealTime.rawValue.capitalized)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    if let timing = schedule.timing {
                        Text(timing.rawValue)
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
            }
            
            if let dosage = schedule.dosage, !dosage.isEmpty {
                Text(dosage)
                    .font(.caption2)
                    .fontWeight(.medium)
                    .foregroundColor(mealTimeColor[0])
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(mealTimeColor[0].opacity(0.08))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(mealTimeColor[0].opacity(0.2), lineWidth: 1)
        )
    }
    
    private var compactChip: some View {
        HStack(spacing: 4) {
            Image(systemName: schedule.mealTime.icon)
                .font(.caption2)
            
            VStack(alignment: .leading, spacing: 1) {
                Text(schedule.mealTime.rawValue.capitalized)
                    .font(.caption2)
                    .fontWeight(.medium)
                
                if let timing = schedule.timing {
                    Text(timing.rawValue)
                        .font(.system(size: 9))
                        .foregroundColor(.secondary)
                }
            }
            
            if let dosage = schedule.dosage {
                Text("• \(dosage)")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Color(.tertiarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 6))
    }
}

#Preview {
    VStack(spacing: 16) {
        MedicationScheduleChip(
            schedule: MedicationSchedule(
                mealTime: .breakfast,
                timing: .before,
                dosage: "1 tablet"
            ),
            style: .premium
        )
        
        MedicationScheduleChip(
            schedule: MedicationSchedule(
                mealTime: .dinner,
                timing: .after,
                dosage: "2 tablets"
            ),
            style: .compact
        )
    }
    .padding()
}
