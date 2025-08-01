//
//  MedicalCaseListItem.swift
//  Walnut-Playground
//
//  Created by Mayank Gandhi on 30/06/25.
//  Copyright © 2025 m. All rights reserved.
//

import SwiftUI

struct EnhancedMedicalCaseListItem: View {
    let medicalCase: MedicalCase
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Header Row
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(medicalCase.title)
                        .font(.headline)
                        .lineLimit(2)
                    
                    Text(medicalCase.patient.fullName)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    StatusBadge(
                        isActive: medicalCase.isActive,
                        primaryColor: medicalCase.patient
                            .primaryColor)
                    
                    Text(medicalCase.createdAt.formatted(date: .abbreviated, time: .omitted))
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }
            }
            
            // Tags Row
            HStack(spacing: 8) {
                CaseTypeBadge(type: medicalCase.type)
                
                SpecialtyBadge(specialty: medicalCase.specialty)
                
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
                    .padding(.top, 4)
            }
        }
        .padding(.vertical, 4)
    }
}
