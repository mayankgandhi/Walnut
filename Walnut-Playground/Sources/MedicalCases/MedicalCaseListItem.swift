//
//  MedicalCaseListItem.swift
//  Walnut-Playground
//
//  Created by Mayank Gandhi on 30/06/25.
//  Copyright © 2025 m. All rights reserved.
//


import SwiftUI

struct MedicalCaseListItem: View {
    let medicalCase: MedicalCaseData
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Header row with title and status
            HStack {
                Text(medicalCase.title)
                    .font(.headline)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                    .lineLimit(2)
                
                Spacer()
                
                // Active status indicator
                if medicalCase.isActive {
                    Circle()
                        .fill(Color.green)
                        .frame(width: 8, height: 8)
                }
            }
            
            // Specialty and type tags
            HStack(spacing: 8) {
                // Specialty tag
                Text(medicalCase.specialty)
                    .font(.caption)
                    .fontWeight(.medium)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.blue.opacity(0.1))
                    .foregroundColor(.blue)
                    .cornerRadius(12)
                
                // Case type tag
                Text(medicalCase.type.capitalized)
                    .font(.caption)
                    .fontWeight(.medium)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(caseTypeColor.opacity(0.1))
                    .foregroundColor(caseTypeColor)
                    .cornerRadius(12)
                
                Spacer()
            }
            
            // Notes preview
            Text(medicalCase.notes)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .lineLimit(2)
                .multilineTextAlignment(.leading)
            
            // Footer with dates
            HStack {
                Text("Created: \(formattedDate(medicalCase.createdAt))")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text("Updated: \(relativeDate(medicalCase.updatedAt))")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
    
    // MARK: - Computed Properties
    
    private var caseTypeColor: Color {
        switch medicalCase.type.lowercased() {
        case "surgery":
            return .red
        case "immunisation":
            return .green
        case "health-checkup":
            return .blue
        case "consultation":
            return .purple
        case "follow-up":
            return .orange
        case "treatment":
            return .indigo
        case "diagnosis":
            return .teal
        default:
            return .gray
        }
    }
    
    // MARK: - Helper Methods
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter.string(from: date)
    }
    
    private func relativeDate(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.dateTimeStyle = .named
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

// MARK: - Preview
struct MedicalCaseListItem_Previews: PreviewProvider {
    static var previews: some View {
        List {
            ForEach(MedicalCaseData.sampleCases.prefix(3), id: \.id) { medicalCase in
                MedicalCaseListItem(medicalCase: medicalCase)
            }
        }
        .previewDisplayName("Medical Case List")
    }
}
