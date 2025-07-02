//
//  MedicalCaseHeaderCard.swift
//  Walnut-Playground
//
//  Created by Mayank Gandhi on 02/07/25.
//  Copyright © 2025 m. All rights reserved.
//


import SwiftUI

struct MedicalCaseHeaderCard: View {
    let medicalCase: MedicalCaseData
    @State private var isExpanded = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header Section
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 8) {
                    // Title
                    Text(medicalCase.title)
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                        .lineLimit(2)
                    
                    // Type and Specialty Row
                    HStack(spacing: 12) {
                        // Case Type Badge
                        CaseTypeBadge(type: medicalCase.type)
                        
                        // Specialty
                        Label {
                            Text(medicalCase.specialty)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        } icon: {
                            Image(systemName: specialtyIcon)
                                .font(.caption)
                                .foregroundColor(specialtyColor)
                        }
                    }
                }
                
                Spacer()
                
                // Status Indicator
                StatusIndicator(isActive: medicalCase.isActive)
            }
            
            // Divider
            Rectangle()
                .fill(Color.gray.opacity(0.2))
                .frame(height: 1)
            
            // Treatment Plan Preview
            if !medicalCase.treatmentPlan.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Label("Treatment Plan", systemImage: "list.clipboard")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Button(action: { withAnimation { isExpanded.toggle() } }) {
                            Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    if isExpanded {
                        Text(medicalCase.treatmentPlan)
                            .font(.subheadline)
                            .foregroundColor(.primary)
                            .fixedSize(horizontal: false, vertical: true)
                            .transition(.opacity.combined(with: .move(edge: .top)))
                    } else {
                        Text(medicalCase.treatmentPlan)
                            .font(.subheadline)
                            .foregroundColor(.primary)
                            .lineLimit(2)
                            .truncationMode(.tail)
                    }
                }
            }
            
            // Footer with dates
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Created")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text(medicalCase.createdAt, style: .date)
                        .font(.caption)
                        .fontWeight(.medium)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("Last Updated")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text(medicalCase.updatedAt, style: .relative)
                        .font(.caption)
                        .fontWeight(.medium)
                }
            }
        }
        .padding(20)
        .background(Color(UIColor.systemBackground))
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 4)
    }
    
    // Helper computed properties
    private var specialtyIcon: String {
        switch medicalCase.specialty.lowercased() {
        case let s where s.contains("cardio"):
            return "heart.fill"
        case let s where s.contains("endo"):
            return "leaf.fill"
        case let s where s.contains("neuro"):
            return "brain"
        case let s where s.contains("ortho"):
            return "figure.walk"
        case let s where s.contains("pediatr"):
            return "figure.2.and.child.holdinghands"
        default:
            return "stethoscope"
        }
    }
    
    private var specialtyColor: Color {
        switch medicalCase.specialty.lowercased() {
        case let s where s.contains("cardio"):
            return .red
        case let s where s.contains("endo"):
            return .green
        case let s where s.contains("neuro"):
            return .purple
        case let s where s.contains("ortho"):
            return .orange
        case let s where s.contains("pediatr"):
            return .pink
        default:
            return .blue
        }
    }
}

// Case Type Badge Component
struct CaseTypeBadge: View {
    let type: String
    
    var body: some View {
        Text(type.capitalized)
            .font(.caption)
            .fontWeight(.semibold)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(backgroundColor)
            .foregroundColor(foregroundColor)
            .cornerRadius(12)
    }
    
    private var backgroundColor: Color {
        switch type.lowercased() {
        case "immunisation":
            return Color.blue.opacity(0.15)
        case "surgery":
            return Color.red.opacity(0.15)
        case "health-checkup":
            return Color.green.opacity(0.15)
        case "follow-up":
            return Color.orange.opacity(0.15)
        case "treatment":
            return Color.purple.opacity(0.15)
        case "diagnosis":
            return Color.indigo.opacity(0.15)
        default:
            return Color.gray.opacity(0.15)
        }
    }
    
    private var foregroundColor: Color {
        switch type.lowercased() {
        case "immunisation":
            return .blue
        case "surgery":
            return .red
        case "health-checkup":
            return .green
        case "follow-up":
            return .orange
        case "treatment":
            return .purple
        case "diagnosis":
            return .indigo
        default:
            return .gray
        }
    }
}

// Status Indicator Component
struct StatusIndicator: View {
    let isActive: Bool
    
    var body: some View {
        VStack(spacing: 4) {
            Circle()
                .fill(isActive ? Color.green : Color.gray)
                .frame(width: 12, height: 12)
                .overlay(
                    Circle()
                        .stroke(isActive ? Color.green.opacity(0.3) : Color.gray.opacity(0.3), lineWidth: 3)
                )
                .scaleEffect(isActive ? 1.0 : 0.8)
                .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: isActive)
            
            Text(isActive ? "Active" : "Closed")
                .font(.caption2)
                .fontWeight(.medium)
                .foregroundColor(isActive ? .green : .gray)
        }
    }
}

// Preview
struct MedicalCaseHeaderCard_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            MedicalCaseHeaderCard(
                medicalCase: MedicalCaseData(
                    id: UUID(),
                    title: "Annual Cardiac Checkup with ECG",
                    notes: "Patient reported occasional chest discomfort during exercise",
                    treatmentPlan: "Continue current medication regimen. Monitor blood pressure daily. Follow up with cardiologist in 3 months. Maintain low-sodium diet and regular exercise routine.",
                    type: "health-checkup",
                    specialty: "Cardiologist",
                    isActive: true,
                    createdAt: Date().addingTimeInterval(-86400 * 30),
                    updatedAt: Date().addingTimeInterval(-86400 * 2)
                )
            )
            
            MedicalCaseHeaderCard(
                medicalCase: MedicalCaseData(
                    id: UUID(),
                    title: "Post-Surgery Recovery",
                    notes: "Knee replacement surgery successful",
                    treatmentPlan: "Physical therapy 3x per week. Pain management as needed.",
                    type: "surgery",
                    specialty: "Orthopedic Surgeon",
                    isActive: false,
                    createdAt: Date().addingTimeInterval(-86400 * 90),
                    updatedAt: Date().addingTimeInterval(-86400 * 45)
                )
            )
        }
        .padding()
        .background(Color(UIColor.systemGroupedBackground))
    }
}