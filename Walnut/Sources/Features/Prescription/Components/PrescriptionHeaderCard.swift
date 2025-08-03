//
//  PrescriptionHeaderCard.swift
//  Walnut
//
//  Created by Mayank Gandhi on 03/08/25.
//  Copyright © 2025 m. All rights reserved.
//

import SwiftUI

struct PrescriptionHeaderCard: View {
    let prescription: Prescription
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    if let doctorName = prescription.doctorName {
                        Text(doctorName)
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                    }
                    
                    if let facilityName = prescription.facilityName {
                        Text(facilityName)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                Image(systemName: "cross.circle.fill")
                    .font(.system(size: 32))
                    .foregroundStyle(.white, .green)
            }
            
            Divider()
            
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Issued Date")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .textCase(.uppercase)
                    
                    Text(prescription.dateIssued, style: .date)
                        .font(.headline)
                        .fontWeight(.medium)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("Total Medications")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .textCase(.uppercase)
                    
                    Text("\(prescription.medications.count)")
                        .font(.headline)
                        .fontWeight(.medium)
                }
            }
        }
        .padding(20)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
}

#Preview {
    PrescriptionHeaderCard(prescription: Prescription.samplePrescription)
        .padding()
        .background(Color(.systemGroupedBackground))
}