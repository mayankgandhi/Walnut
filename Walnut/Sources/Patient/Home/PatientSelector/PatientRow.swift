//
//  PatientRow.swift
//  Walnut
//
//  Created by Mayank Gandhi on 07/06/25.
//  Copyright © 2025 m. All rights reserved.
//

import SwiftUI

// MARK: - Patient Row
struct PatientRow: View {
    let patient: Patient
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                Circle()
                    .fill(Color.healthBlue.opacity(0.2))
                    .frame(width: 40, height: 40)
                    .overlay(
                        Text("\(patient.firstName.prefix(1))\(patient.lastName.prefix(1))")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.healthBlue)
                    )
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("\(patient.firstName) \(patient.lastName)")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.textPrimary)
                    
                    if let dob = patient.dateOfBirth {
                        Text("Born \(dob, formatter: DateFormatter.mediumStyle)")
                            .font(.caption)
                            .foregroundColor(.textSecondary)
                    }
                }
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.healthBlue)
                        .font(.system(size: 20))
                }
            }
            .padding(.vertical, 4)
        }
        .buttonStyle(PlainButtonStyle())
    }
}
