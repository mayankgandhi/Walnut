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
                            Text(medicalCase.specialty.rawValue)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        } icon: {
                            Image(systemName: medicalCase.specialty.icon)
                                .font(.caption)
                                .foregroundColor(medicalCase.specialty.color)
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
    
   
}

