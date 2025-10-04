//
//  MedicalCaseListItem.swift
//  Walnut-Playground
//
//  Created by Mayank Gandhi on 30/06/25.
//  Copyright © 2025 m. All rights reserved.
//

import SwiftUI
import WalnutDesignSystem

struct MedicalCaseListItem: View {
    
    let medicalCase: MedicalCase
    
    var body: some View {
        VStack(alignment: .center, spacing: Spacing.small) {
            
            if let specialty = medicalCase.specialty,
               let type = medicalCase.type {
                FolderSpecialtyIcon(
                    specialty: specialty,
                    type: type
                )
            }
            
            Text(medicalCase.title ?? "Case")
                .font(.system(.subheadline, design: .rounded, weight: .semibold))
                .foregroundStyle(.primary)
                .lineLimit(2)
            
                OptionalView(medicalCase.type) { medicalCaseType in
                    Text(medicalCaseType.displayName)
                        .font(
                            .system(.caption2, design: .rounded, weight: .medium)
                        )
                        .foregroundStyle(medicalCaseType.foregroundColor)
                        .padding(.horizontal, Spacing.small)
                        .padding(.vertical, 2)
                        .background(medicalCaseType.backgroundColor)
                        .clipShape(Capsule())
                }
                
                OptionalView(medicalCase.createdAt) { createdAt in
                    Text(createdAt.formatted(date: .abbreviated, time: .omitted))
                        .font(.system(.caption2, design: .default, weight: .regular))
                        .foregroundStyle(.tertiary)
                }
            
        }
        .padding(.vertical, Spacing.small)
        .padding(.horizontal, Spacing.medium)
        .frame(minHeight: 120)
        .glassEffect(.regular, in: RoundedRectangle(cornerRadius: 12))
    }
}


#Preview {
    ScrollView {
        LazyVGrid(
            columns: [.init(), .init()],
            alignment: .leading,
            spacing: Spacing.xs
        ) {
            MedicalCaseListItem(medicalCase: MedicalCase.sampleCase)
            MedicalCaseListItem(medicalCase: MedicalCase.sampleCase)
            MedicalCaseListItem(medicalCase: MedicalCase.sampleCase)
            MedicalCaseListItem(medicalCase: MedicalCase.sampleCase)
            MedicalCaseListItem(medicalCase: MedicalCase.sampleCase)
            MedicalCaseListItem(medicalCase: MedicalCase.sampleCase)
            
        }
    }
    .padding()
}

