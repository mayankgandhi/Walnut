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
    @State private var showingMedicationEditor = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 20) {
                    // Header Card
                    headerCard
                    
                    // Medications Card
                    if !prescription.medications.isEmpty {
                        medicationsCard
                    }
                    
                    // Follow-up Card
                    if prescription.followUpDate != nil || !(prescription.followUpTests?.isEmpty ?? false) {
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
            .sheet(isPresented: $showingMedicationEditor) {
                PrescriptionMedicationEditor(prescription: prescription)
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
            // Enhanced Header with Gradient Icons and Dynamic Effects
            HStack(spacing: 12) {
                Image(systemName: "pills.fill")
                    .font(.title2)
                    .foregroundStyle(.linearGradient(colors: [.blue, .purple], startPoint: .topLeading, endPoint: .bottomTrailing))
                    .apply { image in
                        if #available(iOS 17.0, *) {
                            image
                                .symbolRenderingMode(.multicolor)
                                .symbolEffect(.variableColor.iterative.dimInactiveLayers.nonReversing)
                        } else {
                            image
                        }
                    }
                
                Text("Medications")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Text("\(prescription.medications.count)")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .frame(width: 28, height: 20)
                    .background(
                        Capsule()
                            .fill(.linearGradient(colors: [.blue, .purple], startPoint: .topLeading, endPoint: .bottomTrailing))
                    )
                    .shadow(color: .blue.opacity(0.3), radius: 2, x: 0, y: 1)
            }
            
            // Enhanced Medication Cards with Rich Design
            LazyVStack(spacing: 12) {
                ForEach(prescription.medications, id: \.id) { medication in
                    enhancedMedicationCard(medication: medication)
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.thinMaterial)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(.linearGradient(colors: [.blue.opacity(0.05), .purple.opacity(0.02)], startPoint: .topLeading, endPoint: .bottomTrailing))
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(.linearGradient(colors: [.blue.opacity(0.3), .purple.opacity(0.2)], startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.08), radius: 12, x: 0, y: 4)
    }
    
    private func enhancedMedicationCard(medication: Medication) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            // Enhanced Header with Rich Design
            HStack(spacing: 12) {
                // Status Indicator
                Circle()
                    .fill(.green)
                    .frame(width: 8, height: 8)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(medication.name)
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                        .lineLimit(2)
                    
                    if let dosage = medication.dosage, !dosage.isEmpty {
                        HStack(spacing: 4) {
                            Image(systemName: "pills.circle")
                                .font(.caption2)
                                .foregroundColor(.blue)
                            
                            Text(dosage)
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                Spacer()
                
                // Duration Badge
                Text("\(medication.numberOfDays) days")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.green)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill(.green.opacity(0.1))
                    )
                    .overlay(
                        Capsule()
                            .stroke(.green.opacity(0.3), lineWidth: 1)
                    )
            }
            
            // Rich Schedule Section with Enhanced Design
            if !medication.frequency.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    HStack(spacing: 8) {
                        Image(systemName: "clock")
                            .font(.subheadline)
                            .foregroundColor(.orange)
                        
                        Text("Schedule")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                            .textCase(.uppercase)
                        
                        Spacer()
                        
                        Text("\(medication.frequency.count) times")
                            .font(.caption2)
                            .fontWeight(.medium)
                            .foregroundColor(.orange)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(
                                Capsule()
                                    .fill(.orange.opacity(0.1))
                            )
                    }
                    
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: min(medication.frequency.count, 2)), spacing: 10) {
                        ForEach(medication.frequency.indices, id: \.self) { index in
                            premiumScheduleChip(schedule: medication.frequency[index])
                        }
                    }
                }
            }
            
            // Premium Instructions Section
            if let instructions = medication.instructions, !instructions.isEmpty {
                VStack(alignment: .leading, spacing: 10) {
                    HStack(spacing: 8) {
                        Image(systemName: "doc.text")
                            .font(.subheadline)
                            .foregroundColor(.blue)
                        
                        Text("Instructions")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                            .textCase(.uppercase)
                    }
                    
                    Text(instructions)
                        .font(.caption)
                        .foregroundColor(.primary)
                        .lineSpacing(3)
                        .padding(10)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(.blue.opacity(0.05))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(.blue.opacity(0.2), lineWidth: 1)
                        )
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.secondarySystemGroupedBackground))
                .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
        )
    }
    
    private func medicationRow(medication: Medication) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            // Medication name and dosage
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(medication.name)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    if let dosage = medication.dosage, !dosage.isEmpty {
                        Text(dosage)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                // Duration badge
                HStack(spacing: 4) {
                    Image(systemName: "calendar")
                        .font(.caption2)
                    Text("\(medication.numberOfDays) days")
                        .font(.caption)
                        .fontWeight(.medium)
                }
                .foregroundColor(.blue)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.blue.opacity(0.1))
                .clipShape(Capsule())
            }
            
            // Frequency schedule
            if !medication.frequency.isEmpty {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Schedule")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .textCase(.uppercase)
                    
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: min(medication.frequency.count, 3)), spacing: 6) {
                        ForEach(medication.frequency.indices, id: \.self) { index in
                            scheduleChip(schedule: medication.frequency[index])
                        }
                    }
                }
            }
            
            // Instructions
            if let instructions = medication.instructions, !instructions.isEmpty {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Instructions")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .textCase(.uppercase)
                    
                    Text(instructions)
                        .font(.caption)
                        .foregroundColor(.primary)
                        .lineSpacing(2)
                }
            }
        }
        .padding(12)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    
    private func premiumScheduleChip(schedule: MedicationSchedule) -> some View {
        let mealTimeColor: [Color] = {
            switch schedule.mealTime {
            case .breakfast: return [.orange, .yellow]
            case .lunch: return [.yellow, .orange]
            case .dinner: return [.purple, .pink]
            case .bedtime: return [.indigo, .purple]
            }
        }()
        
        return VStack(spacing: 6) {
            // Meal time icon and info
            HStack(spacing: 6) {
                Image(systemName: mealIcon(for: schedule.mealTime))
                    .font(.subheadline)
                    .foregroundColor(mealTimeColor[0])
                
                VStack(alignment: .leading, spacing: 1) {
                    Text(schedule.mealTime.rawValue.capitalized)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    if let timing = schedule.timing {
                        Text(timing.rawValue)
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
            }
            
            // Dosage
            if let dosage = schedule.dosage, !dosage.isEmpty {
                Text(dosage)
                    .font(.caption2)
                    .fontWeight(.medium)
                    .foregroundColor(mealTimeColor[0])
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(mealTimeColor[0].opacity(0.08))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(mealTimeColor[0].opacity(0.2), lineWidth: 1)
        )
    }
    private func scheduleChip(schedule: MedicationSchedule) -> some View {
        HStack(spacing: 4) {
            // Meal icon
            Image(systemName: mealIcon(for: schedule.mealTime))
                .font(.caption2)
            
            VStack(alignment: .leading, spacing: 1) {
                Text(schedule.mealTime.rawValue.capitalized)
                    .font(.caption2)
                    .fontWeight(.medium)
                
                if let timing = schedule.timing {
                    Text(timing.rawValue)
                        .font(.system(size: 9))
                        .foregroundColor(.secondary)
                }
            }
            
            if let dosage = schedule.dosage {
                Text("• \(dosage)")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Color(.tertiarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 6))
    }
    
    private func mealIcon(for mealTime: MedicationSchedule.MealTime) -> String {
        switch mealTime {
        case .breakfast:
            return "sun.rise"
        case .lunch:
            return "sun.max"
        case .dinner:
            return "moon"
        case .bedtime:
            return "bed.double"
        }
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
            
            if let followUpTests = prescription.followUpTests {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Required Tests")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .textCase(.uppercase)
                    
                    ForEach(followUpTests, id: \.self) { test in
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
}


// MARK: - View Extension for Conditional Modifiers
extension View {
    @ViewBuilder
    func apply<T: View>(@ViewBuilder _ transform: (Self) -> T) -> some View {
        transform(self)
    }
}
