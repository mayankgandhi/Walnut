//
//  PatientHeaderView.swift
//  Walnut
//
//  Created by Mayank Gandhi on 19/06/25.
//  Copyright © 2025 m. All rights reserved.
//


import SwiftUI

struct PatientHeaderView: View {
    let patient: Patient
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 16) {
                // Patient Avatar
                ZStack {
                    Circle()
                        .fill(Color.healthBlue.opacity(0.1))
                        .frame(width: 64, height: 64)
                    
                    Text(patientInitials)
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.healthBlue)
                }
                
                // Patient Info
                VStack(alignment: .leading, spacing: 4) {
                    Text(patientFullName)
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.textPrimary)
                    
                    HStack(spacing: 16) {
                        if let age = patientAge {
                            InfoBadge(icon: "calendar", text: "\(age) years old")
                        }
                        
                        if let gender = patient.gender, !gender.isEmpty {
                            InfoBadge(icon: "person", text: gender)
                        }
                        
                        if let bloodType = patient.bloodType, !bloodType.isEmpty {
                            InfoBadge(icon: "drop.fill", text: bloodType, color: .healthCoral)
                        }
                    }
                    
                    if let lastUpdated = patient.updatedAt {
                        Text("Last updated \(lastUpdated, formatter: DateFormatter.mediumStyle)")
                            .font(.caption)
                            .foregroundColor(.textSecondary)
                    }
                }
                
                Spacer()
                
                // Status Indicator
                VStack(spacing: 4) {
                    Circle()
                        .fill(patient.isActive ? Color.healthGreen : Color.textSecondary)
                        .frame(width: 8, height: 8)
                    
                    Text(patient.isActive ? "Active" : "Inactive")
                        .font(.caption2)
                        .fontWeight(.medium)
                        .foregroundColor(patient.isActive ? .healthGreen : .textSecondary)
                }
            }
            .padding(20)
            
            // Emergency Contact Section (if available)
            if let emergencyName = patient.emergencyContactName,
               !emergencyName.isEmpty,
               let emergencyPhone = patient.emergencyContactPhone,
               !emergencyPhone.isEmpty {
                
                Divider()
                    .background(Color.borderColor)
                
                HStack(spacing: 12) {
                    Image(systemName: "phone.fill")
                        .foregroundColor(.healthCoral)
                        .font(.system(size: 14, weight: .medium))
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Emergency Contact")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.textSecondary)
                        
                        Text(emergencyName)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.textPrimary)
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        if let url = URL(string: "tel:\(emergencyPhone)") {
                            UIApplication.shared.open(url)
                        }
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: "phone")
                                .font(.system(size: 12, weight: .medium))
                            Text(emergencyPhone)
                                .font(.caption)
                                .fontWeight(.medium)
                        }
                        .foregroundColor(.healthBlue)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.healthBlue.opacity(0.1))
                        .cornerRadius(8)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
            }
        }
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .shadowColor.opacity(0.08), radius: 8, x: 0, y: 2)
    }
    
    // MARK: - Computed Properties
    
    private var patientFullName: String {
        let firstName = patient.firstName ?? ""
        let lastName = patient.lastName ?? ""
        return "\(firstName) \(lastName)".trimmingCharacters(in: .whitespaces)
    }
    
    private var patientInitials: String {
        let firstName = patient.firstName ?? ""
        let lastName = patient.lastName ?? ""
        let firstInitial = firstName.first?.uppercased() ?? ""
        let lastInitial = lastName.first?.uppercased() ?? ""
        return "\(firstInitial)\(lastInitial)"
    }
    
    private var patientAge: Int? {
        guard let dateOfBirth = patient.dateOfBirth else { return nil }
        let calendar = Calendar.current
        let now = Date()
        let ageComponents = calendar.dateComponents([.year], from: dateOfBirth, to: now)
        return ageComponents.year
    }
}

// MARK: - Supporting Views

struct InfoBadge: View {
    let icon: String
    let text: String
    var color: Color = .healthBlue
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(color)
            
            Text(text)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.textSecondary)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(color.opacity(0.1))
        .cornerRadius(6)
    }
}