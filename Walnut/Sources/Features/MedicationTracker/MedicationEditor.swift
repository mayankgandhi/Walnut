//
//  MedicationEditor.swift
//  Walnut
//
//  Created by Mayank Gandhi on 01/08/25.
//  Copyright © 2025 m. All rights reserved.
//

import SwiftUI
import SwiftData

struct MedicationEditor: View {
    let medication: Medication?
    let prescription: Prescription?
    
    init(medication: Medication? = nil, prescription: Prescription? = nil) {
        self.medication = medication
        self.prescription = prescription
    }
    
    private var editorTitle: String {
        medication == nil ? "Add Medication" : "Edit Medication"
    }
    
    @State private var name = ""
    @State private var dosage = ""
    @State private var instructions = ""
    @State private var numberOfDays = 7
    @State private var medicationSchedules: [MedicationScheduleItem] = []
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    private var isFormValid: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        numberOfDays > 0 &&
        !medicationSchedules.isEmpty
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Medication Information") {
                    HStack {
                        Image(systemName: "pills.fill")
                            .foregroundColor(.blue)
                            .font(.title2)
                        
                        TextField("Medication Name", text: $name)
                            .autocorrectionDisabled()
                    }
                    
                    HStack {
                        Image(systemName: "drop.fill")
                            .foregroundColor(.green)
                            .font(.title2)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Dosage")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            TextField("e.g. 500mg, 1 tablet", text: $dosage)
                                .autocorrectionDisabled()
                        }
                    }
                    .padding(.vertical, 4)
                    
                    HStack {
                        Image(systemName: "calendar.badge.clock")
                            .foregroundColor(.orange)
                            .font(.title2)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Duration")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            HStack {
                                Stepper(
                                    value: $numberOfDays,
                                    in: 1...365,
                                    step: 1
                                ) {
                                    Text("\(numberOfDays) days")
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                }
                            }
                        }
                    }
                    .padding(.vertical, 4)
                }
                
                Section("Schedule") {
                    ForEach(medicationSchedules.indices, id: \.self) { index in
                        medicationScheduleRow(for: $medicationSchedules[index], index: index)
                    }
                    .onDelete(perform: deleteSchedule)
                    
                    Button(action: addSchedule) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                                .foregroundColor(.blue)
                                .font(.title2)
                            
                            Text("Add Schedule")
                                .font(.subheadline)
                                .fontWeight(.medium)
                        }
                    }
                    .padding(.vertical, 4)
                }
                
                Section("Instructions") {
                    HStack {
                        Image(systemName: "note.text")
                            .foregroundColor(.purple)
                            .font(.title2)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Special Instructions")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            TextField("e.g. Take with food, avoid alcohol", text: $instructions, axis: .vertical)
                                .lineLimit(2...4)
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
            .navigationTitle(editorTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            save()
                            dismiss()
                        }
                    }
                    .disabled(!isFormValid)
                    .font(.system(size: 16, weight: .semibold))
                }
                
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", role: .cancel) {
                        dismiss()
                    }
                    .font(.system(size: 16, weight: .medium))
                }
            }
            .onAppear {
                setupInitialData()
            }
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
    }
    
    // MARK: - Schedule Row
    private func medicationScheduleRow(for schedule: Binding<MedicationScheduleItem>, index: Int) -> some View {
        VStack(spacing: 8) {
            HStack {
                Text("\(index + 1)")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .frame(width: 20, height: 20)
                    .background(Circle().fill(Color.orange))
                
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Picker("Meal", selection: schedule.mealTime) {
                            ForEach(MedicationSchedule.MealTime.allCases, id: \.self) { mealTime in
                                Text(mealTime.rawValue.capitalized)
                                    .tag(mealTime)
                            }
                        }
                        .pickerStyle(.menu)
                        
                        Spacer()
                        
                        Picker("Timing", selection: schedule.timing) {
                            Text("At").tag(nil as MedicationSchedule.MedicationTime?)
                            ForEach(MedicationSchedule.MedicationTime.allCases, id: \.self) { timing in
                                Text(timing.rawValue.capitalized)
                                    .tag(timing as MedicationSchedule.MedicationTime?)
                            }
                        }
                        .pickerStyle(.menu)
                    }
                    
                    TextField("Dosage for this time", text: schedule.dosage)
                        .font(.caption)
                }
                
                Spacer()
            }
        }
        .padding(.vertical, 4)
    }
    
    // MARK: - Actions
    private func addSchedule() {
        withAnimation(.easeIn(duration: 0.2)) {
            medicationSchedules.append(MedicationScheduleItem())
        }
    }
    
    private func deleteSchedule(at offsets: IndexSet) {
        withAnimation(.easeOut(duration: 0.2)) {
            medicationSchedules.remove(atOffsets: offsets)
        }
    }
    
    private func setupInitialData() {
        if let medication {
            loadMedicationData(medication)
        } else {
            // Add one default schedule for new medications
            medicationSchedules.append(MedicationScheduleItem())
        }
    }
    
    private func loadMedicationData(_ medication: Medication) {
        name = medication.name
        dosage = medication.dosage ?? ""
        instructions = medication.instructions ?? ""
        numberOfDays = medication.numberOfDays
        
        medicationSchedules = medication.frequency.map { schedule in
            MedicationScheduleItem(
                mealTime: schedule.mealTime,
                timing: schedule.timing,
                dosage: schedule.dosage ?? ""
            )
        }
        
        // Ensure at least one schedule exists
        if medicationSchedules.isEmpty {
            medicationSchedules.append(MedicationScheduleItem())
        }
    }
    
    private func save() {
        let now = Date()
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedDosage = dosage.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedInstructions = instructions.trimmingCharacters(in: .whitespacesAndNewlines)
        
        let frequency = medicationSchedules.map { item in
            MedicationSchedule(
                mealTime: item.mealTime,
                timing: item.timing,
                dosage: item.dosage.isEmpty ? nil : item.dosage
            )
        }
        
        if let medication {
            // Edit existing medication
            medication.name = trimmedName
            medication.dosage = trimmedDosage.isEmpty ? nil : trimmedDosage
            medication.instructions = trimmedInstructions.isEmpty ? nil : trimmedInstructions
            medication.numberOfDays = numberOfDays
            medication.frequency = frequency
            medication.updatedAt = now
        } else if let prescription {
            // Create new medication
            let newMedication = Medication(
                id: UUID(),
                name: trimmedName,
                frequency: frequency,
                numberOfDays: numberOfDays,
                dosage: trimmedDosage.isEmpty ? nil : trimmedDosage,
                instructions: trimmedInstructions.isEmpty ? nil : trimmedInstructions,
                createdAt: now,
                updatedAt: now,
                prescription: prescription
            )
            modelContext.insert(newMedication)
            prescription.medications.append(newMedication)
            prescription.updatedAt = now
        }
    }
}

// MARK: - Supporting Types
private struct MedicationScheduleItem {
    var mealTime: MedicationSchedule.MealTime = .breakfast
    var timing: MedicationSchedule.MedicationTime? = .after
    var dosage: String = ""
}

// MARK: - Previews
#Preview("Add Medication") {
    MedicationEditor(medication: nil, prescription: nil)
        .modelContainer(for: Medication.self, inMemory: true)
}

#Preview("Edit Medication") {
    let medication = Medication(
        id: UUID(),
        name: "Paracetamol",
        frequency: [
            MedicationSchedule(mealTime: .breakfast, timing: .after, dosage: "1 tablet"),
            MedicationSchedule(mealTime: .dinner, timing: .after, dosage: "1 tablet")
        ],
        numberOfDays: 7,
        dosage: "500mg",
        instructions: "Take with plenty of water"
    )
    
    return MedicationEditor(medication: medication, prescription: nil)
        .modelContainer(for: Medication.self, inMemory: true)
}