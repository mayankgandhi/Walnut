//
//  PrescriptionFollowUpCard.swift
//  Walnut
//
//  Created by Mayank Gandhi on 03/08/25.
//  Copyright © 2025 m. All rights reserved.
//

import SwiftUI

struct PrescriptionFollowUpCard: View {
    let followUpDate: Date?
    let followUpTests: [String]?
    
    init(prescription: Prescription) {
        self.followUpDate = prescription.followUpDate
        self.followUpTests = prescription.followUpTests
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            header
            
            if let followUpDate = followUpDate {
                appointmentSection(date: followUpDate)
            }
            
            if let followUpTests = followUpTests, !followUpTests.isEmpty {
                testsSection(tests: followUpTests)
            }
        }
        .padding(20)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
    
    private var header: some View {
        HStack {
            Image(systemName: "calendar.badge.clock")
                .font(.title2)
                .foregroundColor(.purple)
            
            Text("Follow-up")
                .font(.headline)
                .fontWeight(.semibold)
            
            Spacer()
        }
    }
    
    private func appointmentSection(date: Date) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Next Appointment")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .textCase(.uppercase)
                
                Text(date, style: .date)
                    .font(.subheadline)
                    .fontWeight(.medium)
            }
            
            Spacer()
            
            Image(systemName: "arrow.right.circle.fill")
                .font(.title2)
                .foregroundColor(.purple)
        }
        .padding(12)
        .background(Color.purple.opacity(0.05))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
    
    private func testsSection(tests: [String]) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Required Tests")
                .font(.caption)
                .foregroundColor(.secondary)
                .textCase(.uppercase)
            
            ForEach(tests, id: \.self) { test in
                HStack {
                    Image(systemName: "checkmark.circle")
                        .font(.caption)
                        .foregroundColor(.purple)
                    
                    Text(test)
                        .font(.subheadline)
                    
                    Spacer()
                }
            }
        }
    }
}

