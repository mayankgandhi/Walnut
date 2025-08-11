//
//  PatientListItem.swift
//  Walnut-Playground
//
//  Created by Mayank Gandhi on 29/06/25.
//  Copyright © 2025 m. All rights reserved.
//

import SwiftUI
import WalnutDesignSystem

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
        HStack(spacing: Spacing.medium) {
            // Enhanced Avatar with MenuListItem-style design
            ZStack {
                // Gradient background
                Circle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                patient.primaryColor.opacity(0.1),
                                patient.primaryColor.opacity(0.2)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 56, height: 56)
                
                // Subtle ring
                Circle()
                    .stroke(patient.primaryColor.opacity(0.15), lineWidth: 1)
                    .frame(width: 56, height: 56)
                
                Text(patient.initials)
                    .font(.system(size: 20, weight: .semibold, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                patient.primaryColor,
                                patient.primaryColor.opacity(0.8)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
            
            // Patient Information
            VStack(alignment: .leading, spacing: Spacing.xs) {
                // Header with name and status
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(patient.fullName)
                            .font(.system(.body, design: .rounded, weight: .semibold))
                            .foregroundStyle(.primary)
                        
                        Text("\(patient.age) years old • \(patient.gender)")
                            .font(.system(.caption, design: .rounded))
                            .foregroundStyle(.secondary)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        // Status indicator with badge-style design
                        statusBadge
                        
                        // Recent activity indicator
                        if hasRecentActivity {
                            recentActivityBadge
                        }
                    }
                }
                
                // Medical details with enhanced styling
                HStack(spacing: Spacing.medium) {
                    HStack(spacing: Spacing.xs) {
                        Image(systemName: "drop.circle.fill")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(.red)
                        
                        Text(patient.bloodType.isEmpty ? "Unknown" : patient.bloodType)
                            .font(.system(.caption, design: .rounded, weight: .medium))
                            .foregroundStyle(.primary)
                    }
                    
                    if !patient.medicalCases.isEmpty {
                        HStack(spacing: Spacing.xs) {
                            Image(systemName: "folder.circle.fill")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundStyle(.blue)
                            
                            Text("\(patient.medicalCases.count) case\(patient.medicalCases.count == 1 ? "" : "s")")
                                .font(.system(.caption, design: .rounded, weight: .medium))
                                .foregroundStyle(.primary)
                        }
                    }
                    
                    Spacer()
                }
                
                // Notes preview with enhanced styling
                if !patient.notes.isEmpty {
                    Text(patient.notes)
                        .font(.system(.caption, design: .rounded))
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                        .padding(.horizontal, Spacing.small)
                        .padding(.vertical, Spacing.xs)
                        .background(Color(.systemGray6), in: RoundedRectangle(cornerRadius: 8))
                }
            }
            
            // Enhanced chevron with MenuListItem styling
            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(.tertiary)
                .scaleEffect(isPressed ? 1.1 : 1.0)
                .animation(.easeInOut(duration: 0.1), value: isPressed)
        }
        .padding(.horizontal, Spacing.medium)
        .padding(.vertical, Spacing.small + 2)
        .background(backgroundView)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.clear, lineWidth: 1)
        )
        .scaleEffect(isPressed ? 0.98 : 1.0)
        .animation(.easeInOut(duration: 0.1), value: isPressed)
        .shadow(
            color: Color.black.opacity(0.05),
            radius: 2,
            x: 0,
            y: 1
        )
    }
    
    // MARK: - Helper Views
    
    private var statusBadge: some View {
        Text(patient.isActive ? "Active" : "Inactive")
            .font(.system(.caption2, design: .rounded, weight: .bold))
            .foregroundStyle(.white)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(
                Capsule()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                patient.isActive ? .green : .orange,
                                (patient.isActive ? Color.green : .orange).opacity(0.8)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            )
            .shadow(color: (patient.isActive ? Color.green : .orange).opacity(0.3), radius: 2, x: 0, y: 1)
    }
    
    private var recentActivityBadge: some View {
        HStack(spacing: 4) {
            Image(systemName: "clock.fill")
                .font(.system(size: 10, weight: .semibold))
                .foregroundStyle(.blue)
            
            Text("Recent")
                .font(.system(.caption2, design: .rounded, weight: .medium))
                .foregroundStyle(.blue)
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 2)
        .background(
            Capsule()
                .fill(Color.blue.opacity(0.1))
        )
    }
    
    private var backgroundView: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(isPressed ? Color(.systemGray6) : .clear)
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
        LazyVStack(spacing: Spacing.medium) {
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
                    .padding(.horizontal, Spacing.medium)
            }
        }
        .padding(.vertical, Spacing.medium)
    }
    .background(Color(.systemGroupedBackground))
}

#Preview {
    ModernPatientCard(
        patient: Patient(
            id: UUID(),
            firstName: "Mayank",
            lastName: "Gandhi",
            dateOfBirth: Date(),
            gender: "Male",
            bloodType: "AB+",
            emergencyContactName: "Vidhi",
            emergencyContactPhone: "1233456789",
            notes: "12",
            isActive: true,
            createdAt: Date(),
            updatedAt: Date(),
            medicalCases: []
        )
    )
}
