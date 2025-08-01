//
//  PatientHomeView.swift
//  Walnut-Playground
//
//  Created by Mayank Gandhi on 30/06/25.
//  Copyright © 2025 m. All rights reserved.
//

import SwiftUI
import SwiftData

struct PatientHomeView: View {
    
    @Binding var patient: Patient?
    @Environment(\.modelContext) private var modelContext
    
    init(patient: Binding<Patient?>) {
        self._patient =  patient
    }
    
    var body: some View {
        List {
            if let patient {
                PatientHeaderCard(patient: patient)
                
                ActiveMedicationsSection(patient: patient)
            } else {
                ContentUnavailableView(
                    "Select a Patient",
                    systemImage: "person.crop.circle.badge.xmark",
                    description: Text("Please select a patient by tapping on the menu botton at the top left corner of the screen.")
                )
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button("Menu", systemImage: "person.3.sequence") {
                    withAnimation {
                        self.patient = nil
                    }
                }
            }
        }
    }
}


struct ActiveMedicationsSection: View {
    let patient: Patient
    @Environment(\.modelContext) private var modelContext
    @State private var activeMedications: [Medication] = []
    
    var body: some View {
        Section {
            if activeMedications.isEmpty {
                ContentUnavailableView(
                    "No Active Medications",
                    systemImage: "pills.fill",
                    description: Text("This patient has no active medications.")
                )
                .listRowBackground(Color.clear)
            } else {
                ForEach(medicationsByTimeOfDay.keys.sorted(), id: \.self) { timeOfDay in
                    if let medications = medicationsByTimeOfDay[timeOfDay], !medications.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Image(systemName: iconForTimeOfDay(timeOfDay))
                                    .foregroundColor(.secondary)
                                Text(timeOfDay.capitalized)
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                Spacer()
                            }
                            
                            ForEach(medications, id: \.id) { medication in
                                MedicationRow(medication: medication)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
        } header: {
            HStack {
                Image(systemName: "pills.fill")
                Text("Active Medications")
            }
        }
        .onAppear {
            loadActiveMedications()
        }
    }
    
    private var medicationsByTimeOfDay: [String: [Medication]] {
        var grouped: [String: [Medication]] = [:]
        
        for medication in activeMedications {
            for schedule in medication.frequency {
                let timeOfDay = mapMealTimeToTimeOfDay(schedule.mealTime)
                if grouped[timeOfDay] == nil {
                    grouped[timeOfDay] = []
                }
                if !grouped[timeOfDay]!.contains(where: { $0.id == medication.id }) {
                    grouped[timeOfDay]!.append(medication)
                }
            }
        }
        
        return grouped
    }
    
    private func loadActiveMedications() {
        let activeCases = patient.medicalCases.filter { $0.isActive }
        let medications = activeCases.flatMap { $0.prescriptions.flatMap { $0.medications } }
        self.activeMedications = medications
    }
    
    private func mapMealTimeToTimeOfDay(_ mealTime: MedicationSchedule.MealTime) -> String {
        switch mealTime {
        case .breakfast:
            return "morning"
        case .lunch:
            return "afternoon"
        case .dinner:
            return "evening"
        case .bedtime:
            return "night"
        }
    }
    
    private func iconForTimeOfDay(_ timeOfDay: String) -> String {
        switch timeOfDay {
        case "morning":
            return "sunrise.fill"
        case "afternoon":
            return "sun.max.fill"
        case "evening":
            return "sunset.fill"
        case "night":
            return "moon.fill"
        default:
            return "pills.fill"
        }
    }
}

struct MedicationRow: View {
    let medication: Medication
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(medication.name)
                    .font(.body)
                    .fontWeight(.medium)
                
                if let dosage = medication.dosage {
                    Text(dosage)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                if let instructions = medication.instructions {
                    Text(instructions)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 2) {
                Text("\(medication.numberOfDays) days")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                if medication.frequency.count > 1 {
                    Text("\(medication.frequency.count)× daily")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Color(.secondarySystemFill))
        .cornerRadius(8)
    }
}

struct PatientHomeView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            PatientHomeView(patient: .constant(Patient.samplePatient))
        }
    }
}



