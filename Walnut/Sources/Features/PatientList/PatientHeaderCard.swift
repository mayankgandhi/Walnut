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
            VStack(spacing: 0) {
                // Header section with gradient background
                VStack(spacing: Spacing.medium) {
                    // Top section with photo and basic info
                    HStack(spacing: Spacing.medium) {
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
                                .font(.healthMetricMedium)
                                .foregroundColor(.white)
                                .shadow(color: .black.opacity(0.2), radius: 2, x: 0, y: 1)
                        }
                    
                        VStack(alignment: .leading, spacing: Spacing.small) {
                            StatusBadge(isActive: patient.isActive, primaryColor: patient.primaryColor)
                            
                            Text(patient.fullName)
                                .font(.healthMetricMedium)
                                .foregroundColor(.white)
                                .shadow(color: .black.opacity(0.3), radius: 1, x: 0, y: 1)
                            
                            HStack(spacing: Spacing.small) {
                                HStack(spacing: Spacing.xs) {
                                    Image(systemName: "calendar")
                                        .font(.caption)
                                        .foregroundColor(.white.opacity(0.8))
                                    Text("\(patient.age) years old")
                                        .font(.subheadline)
                                        .foregroundColor(.white.opacity(0.9))
                                }
                                
                                HStack(spacing: Spacing.xs) {
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
                .padding(Spacing.large)
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
                VStack(spacing: Spacing.medium) {
                    // Medical info section
                    HStack(spacing: Spacing.large) {
                        MedicalInfoItem(
                            icon: "drop.fill",
                            title: "Blood Type",
                            value: patient.bloodType.isEmpty ? "Unknown" : patient.bloodType,
                            color: .healthError
                        )
                        
                        Divider()
                            .frame(height: 40)
                            .foregroundColor(patient.primaryColor.opacity(0.3))
                        
                        MedicalInfoItem(
                            icon: "phone.fill",
                            title: "Emergency Contact",
                            value: patient.emergencyContactName.isEmpty ? "Not set" : patient.emergencyContactName,
                            color: .healthPrimary
                        )
                        
                        Spacer()
                    }
                
                    // Notes section (if available)
                    if !patient.notes.isEmpty && patient.notes != "No notes available" {
                        VStack(alignment: .leading, spacing: Spacing.small) {
                            HStack {
                                Image(systemName: "note.text")
                                    .font(.caption)
                                    .foregroundColor(.healthPrimary)
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
                                .padding(.horizontal, Spacing.small)
                                .padding(.vertical, Spacing.small)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.healthPrimary.opacity(0.08))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(Color.healthPrimary.opacity(0.2), lineWidth: 1)
                                        )
                                )
                        }
                    }
                }
                .padding(Spacing.large)
                .background(Color(.systemBackground))
            }
        }
    }
}

struct StatusBadge: View {
    let isActive: Bool
    let primaryColor: Color
    
    var body: some View {
        HStack(spacing: Spacing.xs) {
            Circle()
                .fill(isActive ? Color.white : Color.white.opacity(0.6))
                .frame(width: 6, height: 6)
                .shadow(color: .black.opacity(0.2), radius: 1, x: 0, y: 0.5)
            
            Text(isActive ? "Active" : "Inactive")
                .font(.caption2)
                .fontWeight(.semibold)
                .foregroundColor(.white)
        }
        .padding(.horizontal, Spacing.small)
        .padding(.vertical, Spacing.xs)
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
        VStack(alignment: .leading, spacing: Spacing.xs) {
            HStack(spacing: Spacing.xs) {
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
