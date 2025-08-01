//
//  PrescriptionMedicationEditor.swift
//  Walnut
//
//  Created by Mayank Gandhi on 01/08/25.
//  Copyright © 2025 m. All rights reserved.
//

import SwiftUI
import SwiftData

struct PrescriptionMedicationEditor: View {
    let prescription: Prescription
    
    @State private var showingMedicationEditor = false
    @State private var selectedMedication: Medication?
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    ForEach(prescription.medications, id: \.id) { medication in
                        medicationRow(medication: medication)
                    }
                    .onDelete(perform: deleteMedications)
                    
                    Button(action: addNewMedication) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                                .foregroundColor(.blue)
                                .font(.title2)
                            
                            Text("Add Medication")
                                .font(.subheadline)
                                .fontWeight(.medium)
                        }
                        .padding(.vertical, 8)
                    }
                } header: {
                    HStack {
                        Text("Medications")
                        Spacer()
                        Text("\(prescription.medications.count) total")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                if !prescription.medications.isEmpty {
                    Section("Quick Actions") {
                        Button(action: duplicateLastMedication) {
                            HStack {
                                Image(systemName: "doc.on.doc.fill")
                                    .foregroundColor(.orange)
                                    .font(.title2)
                                
                                Text("Duplicate Last Medication")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }
            }
            .navigationTitle("Edit Medications")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .font(.system(size: 16, weight: .semibold))
                }
            }
            .sheet(isPresented: $showingMedicationEditor) {
                MedicationEditor(
                    medication: selectedMedication,
                    prescription: selectedMedication == nil ? prescription : nil
                )
            }
        }
    }
    
    // MARK: - Medication Row
    private func medicationRow(medication: Medication) -> some View {
        Button(action: {
            selectedMedication = medication
            showingMedicationEditor = true
        }) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(medication.name)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.primary)
                        
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
                        
                        Text("\(medication.frequency.count) times/day")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                    
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                // Quick schedule preview
                if !medication.frequency.isEmpty {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: min(medication.frequency.count, 4)), spacing: 4) {
                        ForEach(Array(medication.frequency.prefix(4).enumerated()), id: \.offset) { _, schedule in
                            schedulePreviewChip(schedule: schedule)
                        }
                        
                        if medication.frequency.count > 4 {
                            Text("+\(medication.frequency.count - 4) more")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.gray.opacity(0.1))
                                .clipShape(Capsule())
                        }
                    }
                }
                
                if let instructions = medication.instructions, !instructions.isEmpty {
                    Text(instructions)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                        .padding(.top, 2)
                }
            }
            .padding(.vertical, 4)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func schedulePreviewChip(schedule: MedicationSchedule) -> some View {
        HStack(spacing: 2) {
            Image(systemName: mealTimeIcon(for: schedule.mealTime))
                .font(.caption2)
                .foregroundColor(.orange)
            
            Text(schedule.mealTime.rawValue.prefix(1).capitalized)
                .font(.caption2)
                .fontWeight(.medium)
        }
        .padding(.horizontal, 4)
        .padding(.vertical, 2)
        .background(Color.orange.opacity(0.1))
        .foregroundColor(.orange)
        .clipShape(Capsule())
    }
    
    // MARK: - Actions
    private func addNewMedication() {
        selectedMedication = nil
        showingMedicationEditor = true
    }
    
    private func deleteMedications(at offsets: IndexSet) {
        withAnimation(.easeOut(duration: 0.3)) {
            for index in offsets {
                let medicationToDelete = prescription.medications[index]
                modelContext.delete(medicationToDelete)
            }
            prescription.updatedAt = Date()
        }
    }
    
    private func duplicateLastMedication() {
        guard let lastMedication = prescription.medications.last else { return }
        
        let duplicatedMedication = Medication(
            id: UUID(),
            name: lastMedication.name,
            frequency: lastMedication.frequency,
            numberOfDays: lastMedication.numberOfDays,
            dosage: lastMedication.dosage,
            instructions: lastMedication.instructions,
            prescription: prescription
        )
        
        withAnimation(.easeIn(duration: 0.3)) {
            modelContext.insert(duplicatedMedication)
            prescription.medications.append(duplicatedMedication)
            prescription.updatedAt = Date()
        }
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
}
