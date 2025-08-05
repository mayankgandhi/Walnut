//
//  PatientListItem.swift
//  Walnut-Playground
//
//  Created by Mayank Gandhi on 29/06/25.
//  Copyright © 2025 m. All rights reserved.
//

import SwiftUI

struct ModernPatientCard: View {
    let patient: Patient
    @State private var isPressed = false
    
    var hasRecentActivity: Bool {
        !patient.medicalCases.isEmpty && 
        patient.medicalCases.contains { 
            Calendar.current.isDate($0.createdAt, inSameDayAs: Date()) ||
            Calendar.current.dateComponents([.day], from: $0.createdAt, to: Date()).day! <= 7
        }
    }
    
    var body: some View {
        HStack(spacing: 16) {
            // Modern Avatar
            ZStack {
                Circle()
                    .fill(patient.primaryColor.opacity(0.15))
                    .frame(width: 56, height: 56)
                
                Text(patient.initials)
                    .font(.system(size: 20, weight: .semibold, design: .rounded))
                    .foregroundStyle(patient.primaryColor)
            }
            .overlay(
                Circle()
                    .stroke(patient.primaryColor.opacity(0.3), lineWidth: 1.5)
            )
            
            // Patient Information
            VStack(alignment: .leading, spacing: 8) {
                // Header with name and status
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(patient.fullName)
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundStyle(.primary)
                        
                        Text("\(patient.age) years old • \(patient.gender)")
                            .font(.system(size: 14))
                            .foregroundStyle(.secondary)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        // Status indicator
                        HStack(spacing: 6) {
                            Circle()
                                .fill(patient.isActive ? .green : .orange)
                                .frame(width: 8, height: 8)
                            
                            Text(patient.isActive ? "Active" : "Inactive")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundStyle(patient.isActive ? .green : .orange)
                        }
                        
                        // Recent activity indicator
                        if hasRecentActivity {
                            HStack(spacing: 4) {
                                Image(systemName: "clock.fill")
                                    .font(.system(size: 10))
                                    .foregroundStyle(.blue)
                                
                                Text("Recent")
                                    .font(.system(size: 10, weight: .medium))
                                    .foregroundStyle(.blue)
                            }
                        }
                    }
                }
                
                // Medical details
                HStack(spacing: 20) {
                    HStack(spacing: 6) {
                        Image(systemName: "drop.circle.fill")
                            .font(.system(size: 14))
                            .foregroundStyle(.red)
                        
                        Text(patient.bloodType.isEmpty ? "Unknown" : patient.bloodType)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(.primary)
                    }
                    
                    if !patient.medicalCases.isEmpty {
                        HStack(spacing: 6) {
                            Image(systemName: "folder.circle.fill")
                                .font(.system(size: 14))
                                .foregroundStyle(.blue)
                            
                            Text("\(patient.medicalCases.count) case\(patient.medicalCases.count == 1 ? "" : "s")")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundStyle(.primary)
                        }
                    }
                    
                    Spacer()
                }
                
                // Notes preview
                if !patient.notes.isEmpty {
                    Text(patient.notes)
                        .font(.system(size: 13))
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 8))
                }
            }
            
            // Arrow indicator
            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(.tertiary)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.regularMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(.quaternary, lineWidth: 0.5)
                )
        )
        .scaleEffect(isPressed ? 0.98 : 1.0)
        .animation(.easeInOut(duration: 0.15), value: isPressed)
    }
}

// Legacy struct for compatibility
struct PatientListItem: View {
    let patient: Patient
    
    var body: some View {
        ModernPatientCard(patient: patient)
    }
}


// Preview
#Preview {
    ScrollView {
        LazyVStack(spacing: 16) {
            ForEach([
                Patient.samplePatient,
                Patient(
                    id: UUID(),
                    firstName: "Sarah",
                    lastName: "Johnson",
                    dateOfBirth: Calendar.current.date(byAdding: .year, value: -28, to: Date()) ?? Date(),
                    gender: "Female",
                    bloodType: "O-",
                    emergencyContactName: "Mike Johnson",
                    emergencyContactPhone: "(555) 987-6543",
                    notes: "Allergic to shellfish and has a history of migraines. Regular checkups recommended.",
                    isActive: true,
                    primaryColorHex: "#45B7D1",
                    createdAt: Date(),
                    updatedAt: Date(),
                    medicalCases: []
                ),
                Patient(
                    id: UUID(),
                    firstName: "Robert",
                    lastName: "Williams",
                    dateOfBirth: Calendar.current.date(byAdding: .year, value: -65, to: Date()) ?? Date(),
                    gender: "Male",
                    bloodType: "B+",
                    emergencyContactName: "Linda Williams",
                    emergencyContactPhone: "(555) 456-7890",
                    notes: "",
                    isActive: false,
                    primaryColorHex: "#96CEB4",
                    createdAt: Date(),
                    updatedAt: Date(),
                    medicalCases: []
                )
            ]) { patient in
                ModernPatientCard(patient: patient)
                    .padding(.horizontal, 20)
            }
        }
        .padding(.vertical, 20)
    }
    .background(.regularMaterial)
}
