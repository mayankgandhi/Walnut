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

#Preview("Prescription Medications Card") {
    ScrollView {
        VStack(spacing: 16) {
            PrescriptionMedicationsCard(medications: [
                Medication(
                    id: UUID(),
                    name: "Amoxicillin",
                    frequency: [
                        MedicationSchedule(
                            mealTime: .breakfast,
                            timing: .after,
                            dosage: "500mg"
                        ),
                        MedicationSchedule(
                            mealTime: .dinner,
                            timing: .after,
                            dosage: "500mg"
                        )
                    ],
                    numberOfDays: 7,
                    dosage: "500mg",
                    instructions: "Take with food. Complete the full course even if you feel better."
                ),
                Medication(
                    id: UUID(),
                    name: "Ibuprofen",
                    frequency: [
                        MedicationSchedule(
                            mealTime: .breakfast,
                            timing: .after,
                            dosage: "400mg"
                        ),
                        MedicationSchedule(
                            mealTime: .lunch,
                            timing: .after,
                            dosage: "400mg"
                        ),
                        MedicationSchedule(
                            mealTime: .dinner,
                            timing: .after,
                            dosage: "400mg"
                        )
                    ],
                    numberOfDays: 5,
                    dosage: "400mg",
                    instructions: "Take with food to avoid stomach upset. Do not exceed recommended dose."
                ),
                Medication(
                    id: UUID(),
                    name: "Vitamin D3",
                    frequency: [
                        MedicationSchedule(
                            mealTime: .breakfast,
                            timing: .after,
                            dosage: "1000 IU"
                        )
                    ],
                    numberOfDays: 30,
                    dosage: "1000 IU"
                )
            ])
            
            PrescriptionMedicationsCard(medications: [])
        }
        .padding()
        .background(Color(UIColor.systemGroupedBackground))
    }
}

