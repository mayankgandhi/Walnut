//
//  PrescriptionDetailView.swift
//  Walnut
//
//  Created by Mayank Gandhi on 12/07/25.
//  Copyright © 2025 m. All rights reserved.
//

import SwiftUI

struct PrescriptionDetailView: View {
    let prescription: Prescription
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 20) {
                    // Header Card
                    headerCard
                    
                    // Medications Card
                    medicationsCard
                    
                    // Follow-up Card
                    if prescription.followUpDate != nil || !prescription.followUpTests.isEmpty {
                        followUpCard
                    }
                    
                    // Notes Card
                    if let notes = prescription.notes, !notes.isEmpty {
                        notesCard
                    }
                    
                    // Document Card
                    if let document = prescription.document {
                        documentCard(document: document)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Prescription Details")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .fontWeight(.medium)
                }
            }
        }
    }
    
    // MARK: - Header Card
    private var headerCard: some View {
        VStack(spacing: 16) {
            // Doctor and Facility Info
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    if let doctorName = prescription.doctorName {
                        Text(doctorName)
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                    }
                    
                    if let facilityName = prescription.facilityName {
                        Text(facilityName)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                // Health Cross Icon
                Image(systemName: "cross.circle.fill")
                    .font(.system(size: 32))
                    .foregroundStyle(.white, .green)
            }
            
            Divider()
            
            // Date Information
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Issued Date")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .textCase(.uppercase)
                    
                    Text(prescription.dateIssued, style: .date)
                        .font(.headline)
                        .fontWeight(.medium)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("Total Medications")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .textCase(.uppercase)
                    
                    Text("\(prescription.medications.count)")
                        .font(.headline)
                        .fontWeight(.medium)
                }
            }
        }
        .padding(20)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
    
    // MARK: - Medications Card
    private var medicationsCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "pills.fill")
                    .font(.title2)
                    .foregroundColor(.blue)
                
                Text("Medications")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
            }
            
            LazyVStack(spacing: 12) {
                ForEach(Array(prescription.medications.enumerated()), id: \.element.id) { index, medication in
                    medicationRow(medication: medication, index: index)
                }
            }
        }
        .padding(20)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
    
    private func medicationRow(medication: Medication, index: Int) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                // Medication number badge
                Text("\(index + 1)")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .frame(width: 20, height: 20)
                    .background(Circle().fill(Color.blue))
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(medication.name)
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    if let dosage = medication.dosage {
                        Text(dosage)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 2) {
                    Text("\(medication.numberOfDays) days")
                        .font(.caption)
                        .fontWeight(.medium)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(Color.green.opacity(0.1))
                        .foregroundColor(.green)
                        .clipShape(Capsule())
                }
            }
            
            // Medication Schedule
            if !medication.frequency.isEmpty {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 8) {
                    ForEach(Array(medication.frequency.enumerated()), id: \.offset) { _, schedule in
                        scheduleChip(schedule: schedule)
                    }
                }
            }
            
            if let instructions = medication.instructions {
                Text(instructions)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.top, 4)
            }
        }
        .padding(12)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    
    private func scheduleChip(schedule: MedicationSchedule) -> some View {
        HStack(spacing: 4) {
            Image(systemName: mealTimeIcon(for: schedule.mealTime))
                .font(.caption2)
                .foregroundColor(.orange)
            
            Text(scheduleText(for: schedule))
                .font(.caption2)
                .fontWeight(.medium)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Color.orange.opacity(0.1))
        .foregroundColor(.orange)
        .clipShape(Capsule())
    }
    
    // MARK: - Follow-up Card
    private var followUpCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "calendar.badge.clock")
                    .font(.title2)
                    .foregroundColor(.purple)
                
                Text("Follow-up")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
            }
            
            if let followUpDate = prescription.followUpDate {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Next Appointment")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .textCase(.uppercase)
                        
                        Text(followUpDate, style: .date)
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
            
            if !prescription.followUpTests.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Required Tests")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .textCase(.uppercase)
                    
                    ForEach(prescription.followUpTests, id: \.self) { test in
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
        .padding(20)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
    
    // MARK: - Notes Card
    private var notesCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "note.text")
                    .font(.title2)
                    .foregroundColor(.indigo)
                
                Text("Notes")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
            }
            
            Text(prescription.notes ?? "")
                .font(.subheadline)
                .lineSpacing(4)
        }
        .padding(20)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
    
    // MARK: - Document Card
    private func documentCard(document: Document) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "doc.fill")
                    .font(.title2)
                    .foregroundColor(.red)
                
                Text("Document")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Button("View") {
                    // Handle document viewing
                }
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.red)
            }
            
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(document.fileName)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .lineLimit(2)
                    
                    Text("PDF Document • \(document.fileSize) KB")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "arrow.up.right.square")
                    .font(.title2)
                    .foregroundColor(.red)
            }
        }
        .padding(20)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
    
    // MARK: - Helper Functions
    private func mealTimeIcon(for mealTime: MedicationSchedule.MealTime) -> String {
        switch mealTime {
        case .breakfast: return "sunrise.fill"
        case .lunch: return "sun.max.fill"
        case .dinner: return "sunset.fill"
        case .bedtime: return "moon.fill"
        }
    }
    
    private func scheduleText(for schedule: MedicationSchedule) -> String {
        let mealText = schedule.mealTime.rawValue.capitalized
        if let timing = schedule.timing {
            return "\(timing.rawValue.capitalized) \(mealText)"
        }
        return mealText
    }
}
