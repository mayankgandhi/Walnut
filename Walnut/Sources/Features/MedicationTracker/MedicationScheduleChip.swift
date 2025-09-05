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
        let frequencyColor: [Color] = {
            switch schedule.frequency {
            case .mealBased(let mealTime, _):
                switch mealTime {
                case .breakfast: return [.orange, .yellow]
                case .lunch: return [.yellow, .orange]
                case .dinner: return [.purple, .pink]
                case .bedtime: return [.indigo, .purple]
                }
            case .daily:
                return [.blue, .cyan]
            case .hourly:
                return [.green, .mint]
            case .weekly, .biweekly:
                return [.orange, .yellow]
            case .monthly:
                return [.purple, .pink]
            }
        }()
        
        return VStack(spacing: 6) {
            HStack(spacing: 6) {
                Image(systemName: schedule.icon)
                    .font(.subheadline)
                    .foregroundColor(frequencyColor[0])
                
                VStack(alignment: .leading, spacing: 1) {
                    Text(schedule.displayText)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    // Show additional timing information for meal-based schedules
                    if case .mealBased(_, let timing) = schedule.frequency, let timing = timing {
                        Text(timing.displayName)
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
                    .foregroundColor(frequencyColor[0])
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(frequencyColor[0].opacity(0.08))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(frequencyColor[0].opacity(0.2), lineWidth: 1)
        )
    }
    
    private var compactChip: some View {
        HStack(spacing: 4) {
            Image(systemName: schedule.icon)
                .font(.caption2)
                .foregroundColor(schedule.frequency.color)
            
            VStack(alignment: .leading, spacing: 1) {
                Text(schedule.displayText)
                    .font(.caption2)
                    .fontWeight(.medium)
                
                // Show additional timing information for meal-based schedules
                if case .mealBased(_, let timing) = schedule.frequency, let timing = timing {
                    Text(timing.displayName)
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
        .background(schedule.frequency.color.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 6))
    }
}
