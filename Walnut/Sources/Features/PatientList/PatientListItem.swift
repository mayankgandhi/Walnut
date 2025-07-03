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
        HStack(alignment: .center,
               spacing: 12) {
            // Avatar circle with initials
            Circle()
                .fill(patient.isActive ? Color.blue.gradient : Color.gray.gradient)
                .frame(width: 50, height: 50)
                .overlay {
                    Text(patient.initials)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                }
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(patient.fullName)
                        .font(.headline)
                        .fontWeight(.medium)
                    
                    Spacer()
                    
                    if !patient.isActive {
                        Text("Archived")
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(Color.gray.opacity(0.2))
                            .foregroundColor(.secondary)
                            .clipShape(Capsule())
                    }
                }
                
                Label("\(patient.age) years", systemImage: "calendar")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Label(patient.bloodType, systemImage: "drop.fill")
                    .font(.subheadline)
                    .foregroundColor(.red)
                
                if !patient.notes.isEmpty {
                    Text(patient.notes)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                        .padding(.top, 2)
                }
            }
        }
    }
}

// Extension to get initials
extension Patient {
    var initials: String {
        let firstInitial = firstName.first?.uppercased() ?? ""
        let lastInitial = lastName.first?.uppercased() ?? ""
        return "\(firstInitial)\(lastInitial)"
    }
}

// Preview
#Preview {
    NavigationView {
        List {
            ForEach(Patient.sampleData) { patient in
                PatientListItem(patient: patient)
            }
        }
        .navigationTitle("Patients")
    }
}
