//
//  PatientHeaderCard.swift
//  Walnut-Playground
//
//  Created by Mayank Gandhi on 29/06/25.
//  Copyright © 2025 m. All rights reserved.
//


import SwiftUI
import WalnutDesignSystem

struct PatientHeaderCard: View {
    let patient: Patient
    
    var body: some View {
        HealthCard {
            VStack(spacing: Spacing.large) {
                // Patient identity section
                HStack(spacing: Spacing.medium) {
                    PatientAvatar(
                        initials: patient.initials,
                        color: patient.primaryColor,
                        size: 64
                    )
                    
                    VStack(alignment: .leading, spacing: Spacing.xs) {
                        Text(patient.fullName)
                            .font(.title3)
                            .fontWeight(.semibold)
                        
                        Text("\(patient.age) years old • \(patient.gender)")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    
                    Spacer()
                }
                
                // Medical information grid
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: Spacing.medium) {
                    MedicalInfoRow(
                        icon: "drop.fill",
                        title: "Blood Type",
                        value: patient.bloodType.isEmpty ? "Unknown" : patient.bloodType,
                        color: .red
                    )
                    
                    MedicalInfoRow(
                        icon: "phone.fill",
                        title: "Emergency Contact",
                        value: patient.emergencyContactName.isEmpty ? "Not set" : patient.emergencyContactName,
                        color: .blue
                    )
                    
                    MedicalInfoRow(
                        icon: "calendar",
                        title: "Date of Birth",
                        value: patient.dateOfBirth.formatted(date: .abbreviated, time: .omitted),
                        color: .green
                    )
                    
                }
                
                // Notes section (if available)
                if !patient.notes.isEmpty && patient.notes != "No notes available" {
                    VStack(alignment: .leading, spacing: Spacing.xs) {
                        Text("Notes")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundStyle(.secondary)
                        
                        Text(patient.notes)
                            .font(.footnote)
                            .lineLimit(3)
                            .multilineTextAlignment(.leading)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        }
    }
}

struct MedicalInfoRow: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        HStack(spacing: Spacing.small) {
            Image(systemName: icon)
                .font(.footnote)
                .foregroundStyle(color)
                .frame(width: 16)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                Text(value)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .lineLimit(1)
            }
            
            Spacer()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// Preview
struct PatientHeaderCard_Previews: PreviewProvider {
    static var previews: some View {
        PatientHeaderCard(patient: .samplePatient)
            .previewLayout(.sizeThatFits)
            .padding()
    }
}
