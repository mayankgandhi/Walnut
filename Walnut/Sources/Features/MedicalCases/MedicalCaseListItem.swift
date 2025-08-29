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
        VStack(alignment: .center, spacing: Spacing.small) {
            // Medical Case Icon
            Image(systemName: "folder.fill")
                .renderingMode(.template)
                .resizable()
                .scaledToFit()
                .foregroundStyle(
                    medicalCase.type?.backgroundColor ?? Color.blue
                )
                .overlay {
                    Image(systemName: medicalCase.specialty?.icon ?? "stethoscope")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 25, height: 25)
                        .foregroundStyle(
                            medicalCase.specialty?.color ?? Color.green
                        )
                        .padding(Spacing.small)
                        .background(
                            medicalCase.specialty?.color
                                .opacity(0.20) ?? Color.green
                        )
                        .clipShape(Circle())
                        .offset(y: 15)
                }
            
            Text(medicalCase.title ?? "Medical Case")
                .font(
                    .system(
                        .subheadline,
                        design: .rounded,
                        weight: .semibold
                    )
                )
                .foregroundStyle(.primary)
                .lineLimit(2)
            
            VStack(alignment: .leading, spacing: Spacing.xs) {
                
                Text(medicalCase.type.displayName)
                    .font(
                        .system(.caption2, design: .rounded, weight: .medium)
                    )
                    .foregroundStyle(medicalCase.type.foregroundColor)
                    .padding(.horizontal, Spacing.small)
                    .padding(.vertical, 2)
                    .background(medicalCase.type.backgroundColor)
                    .clipShape(Capsule())
                
                Text(medicalCase.createdAt.formatted(date: .abbreviated, time: .omitted))
                    .font(
                        .system(.caption2, design: .default, weight: .regular)
                    )
                    .foregroundStyle(.tertiary)
            }
        }
        .padding(Spacing.medium)
    }
}


#Preview {
    ScrollView {
        LazyVGrid(
            columns: [.init(), .init()],
            alignment: .leading,
            spacing: Spacing.xs
        ) {
            EnhancedMedicalCaseListItem(medicalCase: MedicalCase.sampleCase)
            EnhancedMedicalCaseListItem(medicalCase: MedicalCase.sampleCase)
            EnhancedMedicalCaseListItem(medicalCase: MedicalCase.sampleCase)
            EnhancedMedicalCaseListItem(medicalCase: MedicalCase.sampleCase)
            EnhancedMedicalCaseListItem(medicalCase: MedicalCase.sampleCase)
            EnhancedMedicalCaseListItem(medicalCase: MedicalCase.sampleCase)
            
        }
    }
    .padding()
}

