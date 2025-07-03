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
            // Main card content
            VStack(spacing: 16) {
                // Top section with photo and basic info
                HStack(spacing: 16) {
                    // Patient photo placeholder
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [Color.blue.opacity(0.8), Color.purple.opacity(0.6)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 80, height: 80)
                        
                        Text(patient.initials)
                            .font(.title)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                    }
                    .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
                    
                    
                    
                    VStack(alignment: .leading, spacing: 6) {
                        StatusBadge(isActive: patient.isActive)
                          
                        
                        Text(patient.fullName)
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                        
                        HStack(spacing: 4) {
                            Image(systemName: "calendar")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text("\(patient.age) years old")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        
                        HStack(spacing: 4) {
                            Image(systemName: "person.fill")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text(patient.gender)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Spacer()
                    
                    
                }
                
                // Medical info section
                HStack(spacing: 20) {
                    MedicalInfoItem(
                        icon: "drop.fill",
                        title: "Blood Type",
                        value: patient.bloodType,
                        color: .red
                    )
                    
                    Divider()
                        .frame(height: 40)
                    
                    MedicalInfoItem(
                        icon: "phone.fill",
                        title: "Emergency Contact",
                        value: patient.emergencyContactName,
                        color: .orange
                    )
                    
                    Spacer()
                }
                
                // Notes section (if available)
                if !patient.notes.isEmpty && patient.notes != "No notes available" {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: "note.text")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text("Notes")
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundColor(.secondary)
                            Spacer()
                        }
                        
                        Text(patient.notes)
                            .font(.footnote)
                            .foregroundColor(.primary)
                            .lineLimit(2)
                            .multilineTextAlignment(.leading)
                    }
                    .padding(.top, 8)
                }
            }
           
    }
}

struct StatusBadge: View {
    let isActive: Bool
    
    var body: some View {
        HStack(spacing: 4) {
            Circle()
                .fill(isActive ? Color.green : Color.gray)
                .frame(width: 6, height: 6)
            
            Text(isActive ? "Active" : "Inactive")
                .font(.caption2)
                .fontWeight(.medium)
                .foregroundColor(isActive ? .green : .gray)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(
            Capsule()
                .fill((isActive ? Color.green : Color.gray).opacity(0.1))
        )
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
        PatientHeaderCard(patient: samplePatient)
            .previewLayout(.sizeThatFits)
            .padding()
    }
    
    static let samplePatient = Patient(
        id: UUID(),
        firstName: "Sarah",
        lastName: "Johnson",
        dateOfBirth: Calendar.current.date(byAdding: .year, value: -34, to: Date()) ?? Date(),
        gender: "Female",
        bloodType: "O+",
        emergencyContactName: "Michael Johnson",
        emergencyContactPhone: "+1 (555) 123-4567",
        notes: "Patient has a history of allergies to penicillin. Regular check-ups recommended.",
        isActive: true,
        createdAt: Date(),
        updatedAt: Date()
    )
}
