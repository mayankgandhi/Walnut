//
//  PrescriptionMedicationsCard.swift
//  Walnut
//
//  Created by Mayank Gandhi on 03/08/25.
//  Copyright © 2025 m. All rights reserved.
//

import SwiftUI

struct PrescriptionMedicationsCard: View {
    let medications: [Medication]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            medicationsHeader
            
            LazyVStack(spacing: 12) {
                ForEach(medications, id: \.id) { medication in
                    MedicationDetailCard(medication: medication)
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.thinMaterial)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(.linearGradient(colors: [.blue.opacity(0.05), .purple.opacity(0.02)], startPoint: .topLeading, endPoint: .bottomTrailing))
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(.linearGradient(colors: [.blue.opacity(0.3), .purple.opacity(0.2)], startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.08), radius: 12, x: 0, y: 4)
    }
    
    private var medicationsHeader: some View {
        HStack(spacing: 12) {
            Image(systemName: "pills.fill")
                .font(.title2)
                .foregroundStyle(.linearGradient(colors: [.blue, .purple], startPoint: .topLeading, endPoint: .bottomTrailing))
                .apply { image in
                    if #available(iOS 17.0, *) {
                        image
                            .symbolRenderingMode(.multicolor)
                            .symbolEffect(.variableColor.iterative.dimInactiveLayers.nonReversing)
                    } else {
                        image
                    }
                }
            
            Text("Medications")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            Spacer()
            
            Text("\(medications.count)")
                .font(.subheadline)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .frame(width: 28, height: 20)
                .background(
                    Capsule()
                        .fill(.linearGradient(colors: [.blue, .purple], startPoint: .topLeading, endPoint: .bottomTrailing))
                )
                .shadow(color: .blue.opacity(0.3), radius: 2, x: 0, y: 1)
        }
    }
}

// MARK: - View Extension for Conditional Modifiers
extension View {
    @ViewBuilder
    func apply<T: View>(@ViewBuilder _ transform: (Self) -> T) -> some View {
        transform(self)
    }
}

#Preview {
    PrescriptionMedicationsCard(medications: [
        Medication.sampleMedication,
        Medication.sampleMedication
    ])
    .padding()
    .background(Color(.systemGroupedBackground))
}