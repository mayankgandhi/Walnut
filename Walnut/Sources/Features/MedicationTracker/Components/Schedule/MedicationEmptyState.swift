//
//  MedicationEmptyState.swift
//  Walnut
//
//  Created by Mayank Gandhi on 10/09/25.
//  Copyright © 2025 m. All rights reserved.
//

import SwiftUI
import WalnutDesignSystem

/// Empty state view for when no medications are scheduled
struct MedicationEmptyState: View {
    
    // MARK: - Properties
    
    let onAddPrescription: (() -> Void)?
    
    // MARK: - Body
    
    var body: some View {
        VStack(spacing: Spacing.large) {
            ContentUnavailableView {
                Label("No Medications Scheduled", systemImage: "pills")
            } description: {
                Text("Add medications to your prescriptions to track dosages and schedules throughout the day.")
            } actions: {
                if let onAddPrescription = onAddPrescription {
                    Button("Add Prescription", action: onAddPrescription)
                        .buttonStyle(.borderedProminent)
                }
            }
            .padding(Spacing.large)
        }
    }
}

// MARK: - Preview

#Preview {
    MedicationEmptyState(onAddPrescription: {
        print("Add prescription tapped")
    })
    .background(Color(.systemGroupedBackground))
}