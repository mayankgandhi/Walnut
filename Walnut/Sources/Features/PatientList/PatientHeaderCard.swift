//
//  PatientHeaderCard.swift
//  Walnut-Playground
//
//  Created by Mayank Gandhi on 29/06/25.
//  Copyright © 2025 m. All rights reserved.
//


import SwiftUI

struct PatientHeaderCard: View {
    let patient: Patient
    
    var body: some View {
        // Main card content with gradient background
        VStack(spacing: 0) {
            // Header section with gradient background
            VStack(spacing: 16) {
                // Top section with photo and basic info
                HStack(spacing: 16) {
                    // Enhanced patient avatar with glassmorphism effect
                    ZStack {
                        // Outer glow
                        Circle()
                            .fill(patient.primaryColor.opacity(0.2))
                            .frame(width: 90, height: 90)
                            .blur(radius: 10)
                        
                        // Main avatar circle
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        patient.primaryColor,
                                        patient.primaryColor.opacity(0.8),
                                        patient.primaryColor.opacity(0.6)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 80, height: 80)
                            .overlay(
                                Circle()
                                    .stroke(
                                        LinearGradient(
                                            colors: [
                                                Color.white.opacity(0.4),
                                                Color.white.opacity(0.1),
                                                Color.clear
                                            ],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ),
                                        lineWidth: 1.5
                                    )
                            )
                        
                        Text(patient.initials)
                            .font(.system(size: 26, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .shadow(color: .black.opacity(0.2), radius: 2, x: 0, y: 1)
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        StatusBadge(isActive: patient.isActive, primaryColor: patient.primaryColor)
                        
                        Text(patient.fullName)
                            .font(.system(size: 22, weight: .bold, design: .default))
                            .foregroundColor(.white)
                            .shadow(color: .black.opacity(0.3), radius: 1, x: 0, y: 1)
                        
                        HStack(spacing: 12) {
                            HStack(spacing: 4) {
                                Image(systemName: "calendar")
                                    .font(.caption)
                                    .foregroundColor(.white.opacity(0.8))
                                Text("\(patient.age) years old")
                                    .font(.subheadline)
                                    .foregroundColor(.white.opacity(0.9))
                            }
                            
                            HStack(spacing: 4) {
                                Image(systemName: "person.fill")
                                    .font(.caption)
                                    .foregroundColor(.white.opacity(0.8))
                                Text(patient.gender)
                                    .font(.subheadline)
                                    .foregroundColor(.white.opacity(0.9))
                            }
                        }
                    }
                    
                    Spacer()
                }
            }
            .padding(20)
            .background(
                // Beautiful gradient background
                LinearGradient(
                    colors: [
                        patient.primaryColor,
                        patient.primaryColor.opacity(0.8),
                        patient.primaryColor.opacity(0.6)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            
            // Content section with clean background
            VStack(spacing: 16) {
                // Medical info section
                HStack(spacing: 20) {
                    MedicalInfoItem(
                        icon: "drop.fill",
                        title: "Blood Type",
                        value: patient.bloodType.isEmpty ? "Unknown" : patient.bloodType,
                        color: .red
                    )
                    
                    Divider()
                        .frame(height: 40)
                        .foregroundColor(patient.primaryColor.opacity(0.3))
                    
                    MedicalInfoItem(
                        icon: "phone.fill",
                        title: "Emergency Contact",
                        value: patient.emergencyContactName.isEmpty ? "Not set" : patient.emergencyContactName,
                        color: patient.primaryColor
                    )
                    
                    Spacer()
                }
                
                // Notes section (if available)
                if !patient.notes.isEmpty && patient.notes != "No notes available" {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: "note.text")
                                .font(.caption)
                                .foregroundColor(patient.primaryColor)
                            Text("Notes")
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundColor(.secondary)
                            Spacer()
                        }
                        
                        Text(patient.notes)
                            .font(.footnote)
                            .foregroundColor(.primary)
                            .lineLimit(3)
                            .multilineTextAlignment(.leading)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 10)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(patient.primaryColor.opacity(0.08))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(patient.primaryColor.opacity(0.2), lineWidth: 1)
                                    )
                            )
                    }
                }
            }
            .padding(20)
            .background(Color(.systemBackground))
        }
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: patient.primaryColor.opacity(0.2), radius: 20, x: 0, y: 10)
    }
}

struct StatusBadge: View {
    let isActive: Bool
    let primaryColor: Color
    
    var body: some View {
        HStack(spacing: 4) {
            Circle()
                .fill(isActive ? Color.white : Color.white.opacity(0.6))
                .frame(width: 6, height: 6)
                .shadow(color: .black.opacity(0.2), radius: 1, x: 0, y: 0.5)
            
            Text(isActive ? "Active" : "Inactive")
                .font(.caption2)
                .fontWeight(.semibold)
                .foregroundColor(.white)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(
            Capsule()
                .fill(Color.white.opacity(isActive ? 0.25 : 0.15))
                .overlay(
                    Capsule()
                        .stroke(Color.white.opacity(0.3), lineWidth: 0.5)
                )
        )
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
}

struct MedicalInfoItem: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.caption)
                    .foregroundColor(color)
                
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
            }
            
            Text(value)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
        }
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
