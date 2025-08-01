//
//  PatientListItem.swift
//  Walnut-Playground
//
//  Created by Mayank Gandhi on 29/06/25.
//  Copyright © 2025 m. All rights reserved.
//

import SwiftUI

struct PatientListItem: View {
    let patient: Patient
    
    var body: some View {
        HStack(spacing: 0) {
            // Leading accent bar
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: patient.isActive ? 
                        [patient.primaryColor, patient.primaryColor.opacity(0.7)] :
                        [Color.gray.opacity(0.3), Color.gray.opacity(0.1)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: 4)
                .clipShape(RoundedRectangle(cornerRadius: 2))
            
            HStack(alignment: .center, spacing: 16) {
                // Enhanced avatar with modern design
                ZStack {
                    // Soft shadow background
                    Circle()
                        .fill(patient.primaryColor.opacity(0.1))
                        .frame(width: 56, height: 56)
                        .blur(radius: 4)
                    
                    // Main avatar circle with enhanced gradient
                    Circle()
                        .fill(
                            patient.isActive ? 
                            LinearGradient(
                                colors: [
                                    patient.primaryColor,
                                    patient.primaryColor.opacity(0.8),
                                    patient.primaryColor.opacity(0.6)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ) :
                            LinearGradient(
                                colors: [Color.gray.opacity(0.6), Color.gray.opacity(0.4)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 52, height: 52)
                        .overlay(
                            Circle()
                                .stroke(
                                    LinearGradient(
                                        colors: [
                                            Color.white.opacity(patient.isActive ? 0.3 : 0.1),
                                            Color.clear
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 1
                                )
                        )
                    
                    Text(patient.initials)
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.2), radius: 1, x: 0, y: 1)
                }
                .shadow(
                    color: patient.isActive ? patient.primaryColor.opacity(0.25) : Color.clear,
                    radius: 8,
                    x: 0,
                    y: 4
                )
                
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text(patient.fullName)
                            .font(.system(size: 17, weight: .semibold, design: .default))
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        if !patient.isActive {
                            Text("Archived")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 3)
                                .background(
                                    Capsule()
                                        .fill(Color.gray.opacity(0.15))
                                        .overlay(
                                            Capsule()
                                                .stroke(Color.gray.opacity(0.3), lineWidth: 0.5)
                                        )
                                )
                                .foregroundColor(.secondary)
                        } else {
                            // Enhanced active indicator
                            HStack(spacing: 4) {
                                Circle()
                                    .fill(patient.primaryColor)
                                    .frame(width: 6, height: 6)
                                    .shadow(color: patient.primaryColor.opacity(0.4), radius: 2, x: 0, y: 1)
                                
                                Text("Active")
                                    .font(.caption2)
                                    .fontWeight(.medium)
                                    .foregroundColor(patient.primaryColor)
                            }
                        }
                    }
                    
                    HStack(spacing: 16) {
                        HStack(spacing: 4) {
                            Image(systemName: "calendar")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text("\(patient.age) years")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        
                        HStack(spacing: 4) {
                            Image(systemName: "drop.fill")
                                .font(.caption)
                                .foregroundColor(.red)
                            Text(patient.bloodType.isEmpty ? "Unknown" : patient.bloodType)
                                .font(.subheadline)
                                .foregroundColor(.red)
                        }
                    }
                    
                    if !patient.notes.isEmpty {
                        Text(patient.notes)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .lineLimit(2)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(patient.primaryColor.opacity(0.06))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(patient.primaryColor.opacity(0.15), lineWidth: 0.5)
                                    )
                            )
                            .padding(.top, 2)
                    }
                }
                
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(
                    patient.isActive ? 
                    patient.primaryColor.opacity(0.1) : 
                    Color.gray.opacity(0.05),
                    lineWidth: 1
                )
        )
        .shadow(
            color: patient.isActive ? 
            patient.primaryColor.opacity(0.08) : 
            Color.black.opacity(0.02),
            radius: patient.isActive ? 6 : 2,
            x: 0,
            y: patient.isActive ? 3 : 1
        )
        .padding(.horizontal, 16)
        .padding(.vertical, 4)
    }
}


// Preview
#Preview {
    NavigationView {
        List {
            ForEach([Patient.samplePatient]) { patient in
                PatientListItem(patient: patient)
            }
        }
        .navigationTitle("Patients")
    }
}
