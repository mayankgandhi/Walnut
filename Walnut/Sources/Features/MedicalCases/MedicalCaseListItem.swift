//
//  MedicalCaseListItem.swift
//  Walnut-Playground
//
//  Created by Mayank Gandhi on 30/06/25.
//  Copyright © 2025 m. All rights reserved.
//

import SwiftUI
import WalnutDesignSystem

struct EnhancedMedicalCaseListItem: View {
    let medicalCase: MedicalCase
    
    var body: some View {
        HealthCard {
            HStack(spacing: Spacing.medium) {
                // Specialty Icon
                Circle()
                    .fill(medicalCase.specialty.color.opacity(0.15))
                    .frame(width: Size.avatarLarge, height: Size.avatarLarge)
                    .overlay {
                        Image(systemName: medicalCase.specialty.icon)
                            .font(.system(size: 24, weight: .semibold))
                            .foregroundStyle(medicalCase.specialty.color)
                    }
                
                // Content
                VStack(alignment: .leading, spacing: Spacing.small) {
                    // Header Row
                    HStack {
                        VStack(alignment: .leading, spacing: Spacing.xs) {
                            Text(medicalCase.title)
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(.primary)
                                .lineLimit(2)
                            
                            Text(medicalCase.patient.fullName)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .trailing, spacing: Spacing.xs) {
                            WalnutDesignSystem.StatusIndicator(
                                status: medicalCase.isActive ? .good : .warning,
                                showIcon: false
                            )
                            
                            Text(medicalCase.createdAt.formatted(date: .abbreviated, time: .omitted))
                                .font(.caption2)
                                .foregroundStyle(.tertiary)
                        }
                    }
                    
                    // Tags Row
                    HStack(spacing: Spacing.small) {
                        // Case Type Badge
                        Text(medicalCase.type.displayName)
                            .font(.caption2.weight(.medium))
                            .foregroundStyle(medicalCase.type.foregroundColor)
                            .padding(.horizontal, Spacing.small)
                            .padding(.vertical, 2)
                            .background(medicalCase.type.backgroundColor)
                            .clipShape(Capsule())
                        
                        // Specialty Badge
                        Text(medicalCase.specialty.rawValue)
                            .font(.caption2.weight(.medium))
                            .foregroundStyle(medicalCase.specialty.color)
                            .padding(.horizontal, Spacing.small)
                            .padding(.vertical, 2)
                            .background(medicalCase.specialty.color.opacity(0.1))
                            .clipShape(Capsule())
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundStyle(.tertiary)
                    }
                    
                    // Notes Preview
                    if !medicalCase.notes.isEmpty {
                        Text(medicalCase.notes)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .lineLimit(2)
                    }
                }
            }
        }
    }
}
