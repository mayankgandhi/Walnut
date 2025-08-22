//
//  EnhancedPrescriptionListItem.swift
//  Walnut
//
//  Created by Mayank Gandhi on 21/08/25.
//  Copyright © 2025 m. All rights reserved.
//

import WalnutDesignSystem
import SwiftUI

struct EnhancedPrescriptionListItem: View {
    
    let prescription: Prescription
    @State private var isPressed = false
    
    var body: some View {
        HStack(spacing: Spacing.medium) {
            // Enhanced icon with background
            Circle()
                .fill(Color.healthPrimary.opacity(0.15))
                .frame(width: 44, height: 44)
                .overlay {
                    Image(systemName: "pills.fill")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundStyle(Color.healthPrimary)
                }
            
            // Content with enhanced typography
            VStack(alignment: .leading, spacing: Spacing.xs) {
                HStack {
                    Text(prescription.dateIssued, style: .date)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.primary)
                    
                    Spacer()
                    
                    if prescription.followUpDate != nil {
                        HStack(spacing: 2) {
                            Circle()
                                .fill(Color.healthSuccess)
                                .frame(width: 4, height: 4)
                            
                            Text("Follow-up")
                                .font(.caption2.weight(.medium))
                                .foregroundStyle(Color.healthSuccess)
                        }
                    }
                }
                
                if let doctorName = prescription.doctorName {
                    Text("Dr. \(doctorName)")
                        .font(.caption.weight(.medium))
                        .foregroundStyle(.secondary)
                }
                
                if let facilityName = prescription.facilityName {
                    Text(facilityName)
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                        .lineLimit(1)
                }
            }
            
            // Chevron indicator
            Image(systemName: "chevron.right")
                .font(.caption.weight(.medium))
                .foregroundStyle(.quaternary)
        }
        .padding(Spacing.medium)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(UIColor.secondarySystemGroupedBackground))
                .stroke(Color.healthPrimary.opacity(0.2), lineWidth: 0.5)
                .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
        )
        .scaleEffect(isPressed ? 0.98 : 1.0)
        .animation(.easeInOut(duration: 0.1), value: isPressed)
        
    }
}

#Preview {
    EnhancedPrescriptionListItem(
        prescription: Prescription.samplePrescription(for: .sampleCase)
    )
}
