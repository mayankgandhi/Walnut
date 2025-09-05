//
//  PrescriptionMedicationsCard.swift
//  Walnut
//
//  Created by Mayank Gandhi on 03/08/25.
//  Copyright © 2025 m. All rights reserved.
//

import SwiftUI
import WalnutDesignSystem

struct PrescriptionMedicationsCard: View {
    
    let medications: [Medication]
    @State private var isExpanded = true
    
    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.medium) {
            
            HealthCardHeader(
                iconName: "pill-bottle",
                iconColor: .healthSuccess,
                title: "Medications",
                subtitle: "\(medications.count) Medications"
            )
            
            if medications.isEmpty {
                // Empty state with design system styling
                ContentUnavailableView(
                    "No medications",
                    systemImage: "pills",
                    description: Text("Prescription medications will appear here")
                )
                
            } else {
                LazyVStack(spacing: Spacing.medium) {
                    ForEach(medications, id: \.id) { medication in
                        HealthCard {
                            MedicationListItem(medication: medication)
                        }
                    }
                }
            }
            
        }
    }
    
}
