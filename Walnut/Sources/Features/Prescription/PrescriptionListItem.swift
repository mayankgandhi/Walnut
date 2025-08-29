//
//  PrescriptionListItem.swift
//  Walnut
//
//  Created by Mayank Gandhi on 12/07/25.
//  Copyright © 2025 m. All rights reserved.
//

import SwiftUI

struct PrescriptionListItem: View {
    let prescription: Prescription
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header with date and doctor
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    if let dateIssued = prescription.dateIssued {
                        Text(dateIssued, style: .date)
                            .font(.headline)
                            .foregroundColor(.primary)
                    }
                    
                    if let doctorName = prescription.doctorName {
                        Text(doctorName)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                // Status indicator
                Image(systemName: "doc.text.fill")
                    .foregroundColor(.blue)
                    .font(.title2)
            }
            
            if let facilityName = prescription.facilityName {
                Text(facilityName)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
            
            // Follow-up indicator if exists
            if let followUpDate = prescription.followUpDate {
                HStack {
                    Image(systemName: "calendar")
                        .foregroundColor(.green)
                        .font(.caption)
                    
                    Text("Follow-up: \(followUpDate, style: .date)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(16)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
}
