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
                
                UpcomingMedicationsSection(patient: patient)
                
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


struct UpcomingMedicationsSection: View {
    let patient: Patient
    @Environment(\.modelContext) private var modelContext
    @State private var activeMedications: [Medication] = []
    @State private var medicationTracker = MedicationTracker()
    @State private var currentTime = Date()
    
    private var upcomingMedications: [MedicationTracker.MedicationScheduleInfo] {
        medicationTracker.getUpcomingMedications(activeMedications, withinHours: 6)
    }
    
    var body: some View {
        Section {
            if upcomingMedications.isEmpty {
                // Empty State
                VStack(spacing: 12) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 40))
                        .foregroundStyle(.linearGradient(colors: [.green, .mint], startPoint: .topLeading, endPoint: .bottomTrailing))
                        .apply { image in
                            if #available(iOS 17.0, *) {
                                image
                                    .symbolEffect(.pulse.byLayer, options: .repeat(.continuous))
                                    .symbolRenderingMode(.multicolor)
                            } else {
                                image
                            }
                        }
                    
                    Text("All caught up!")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                    
                    Text("No medications due in the next 6 hours")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
                .listRowBackground(Color.clear)
            } else {
                ForEach(Array(upcomingMedications.enumerated()), id: \.element.medication.id) { index, medicationInfo in
                    upcomingMedicationCard(medicationInfo: medicationInfo, index: index)
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                }
            }
        } header: {
            HStack {
                Image(systemName: "clock.badge.fill")
                    .foregroundStyle(.linearGradient(colors: [.orange, .red], startPoint: .topLeading, endPoint: .bottomTrailing))
                Text("Upcoming Medications")
                Spacer()
                if !upcomingMedications.isEmpty {
                    Text("Next 6 hours")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(Color.orange.opacity(0.1))
                        .clipShape(Capsule())
                }
            }
        }
        .onAppear {
            loadActiveMedications()
            startTimer()
        }
    }
    
    private func loadActiveMedications() {
        let activeCases = patient.medicalCases.filter { $0.isActive }
        let medications = activeCases.flatMap { $0.prescriptions.flatMap { $0.medications } }
        self.activeMedications = medications
    }
    
    private func upcomingMedicationCard(medicationInfo: MedicationTracker.MedicationScheduleInfo, index: Int) -> some View {
        HStack(spacing: 12) {
            // Time Indicator
            VStack(spacing: 4) {
                Image(systemName: medicationInfo.timePeriod.icon)
                    .font(.title3)
                    .foregroundStyle(.linearGradient(colors: medicationInfo.timePeriod.gradientColors, startPoint: .topLeading, endPoint: .bottomTrailing))
                
                if let timeUntilDue = medicationInfo.timeUntilDue {
                    Text(medicationTracker.formatTimeUntilDue(timeUntilDue))
                        .font(.caption2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(
                            Capsule()
                                .fill(.linearGradient(colors: [.orange, .red], startPoint: .topLeading, endPoint: .bottomTrailing))
                        )
                }
            }
            .frame(width: 50)
            
            // Medication Info
            VStack(alignment: .leading, spacing: 4) {
                Text(medicationInfo.medication.name)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                HStack(spacing: 6) {
                    Text(medicationInfo.dosageText)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("•")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text(medicationInfo.displayTime)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                if let instructions = medicationInfo.medication.instructions, !instructions.isEmpty {
                    Text(instructions)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                        .padding(.top, 1)
                }
            }
            
            Spacer()
            
            // Action Button
            Button(action: {
                markMedicationTaken(medicationInfo)
            }) {
                Image(systemName: "checkmark.circle")
                    .font(.title2)
                    .foregroundStyle(.linearGradient(colors: [.green, .mint], startPoint: .topLeading, endPoint: .bottomTrailing))
                    .apply { image in
                        if #available(iOS 17.0, *) {
                            image
                                .symbolEffect(.bounce, value: currentTime)
                                .contentTransition(.symbolEffect(.replace))
                        } else {
                            image
                        }
                    }
            }
            .buttonStyle(.borderless)
            .scaleEffect(1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: currentTime)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.thinMaterial)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(.linearGradient(colors: [medicationInfo.timePeriod.color.opacity(0.08), medicationInfo.timePeriod.color.opacity(0.03)], startPoint: .topLeading, endPoint: .bottomTrailing))
                )
                .shadow(
                    color: .white.opacity(0.3),
                    radius: 1, x: 0, y: 1)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(.linearGradient(colors: medicationInfo.timePeriod.gradientColors.map { $0.opacity(0.4) }, startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 1.5)
        )
        .overlay(alignment: .leading) {
            Rectangle()
                .fill(.linearGradient(colors: medicationInfo.timePeriod.gradientColors, startPoint: .top, endPoint: .bottom))
                .frame(width: 3)
                .clipShape(RoundedRectangle(cornerRadius: 1.5))
        }
    }
    
    private func startTimer() {
        Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { _ in
            currentTime = Date()
        }
    }
    
    private func markMedicationTaken(_ medicationInfo: MedicationTracker.MedicationScheduleInfo) {
        let impactFeedback = UIImpactFeedbackGenerator(style: .rigid)
        impactFeedback.prepare()
        impactFeedback.impactOccurred(intensity: 0.8)
        
        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
            currentTime = Date()
        }
        
        print("Marked \(medicationInfo.medication.name) as taken")
    }
}

struct ActiveMedicationsSection: View {
    let patient: Patient
    @Environment(\.modelContext) private var modelContext
    @State private var activeMedications: [Medication] = []
    @State private var medicationTracker = MedicationTracker()
    @State private var showingMedicationEditor = false
    
    private var groupedMedications: [MedicationTracker.TimePeriod: [MedicationTracker.MedicationScheduleInfo]] {
        medicationTracker.groupMedicationsByTimePeriod(activeMedications)
    }
    
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
                // Time Period Groups
                ForEach(MedicationTracker.TimePeriod.allCases, id: \.self) { timePeriod in
                    if let medicationsForPeriod = groupedMedications[timePeriod], !medicationsForPeriod.isEmpty {
                        timePeriodSection(timePeriod: timePeriod, medications: medicationsForPeriod)
                            .listRowBackground(Color.clear)
                            .listRowSeparator(.hidden)
                    }
                }
            }
        } header: {
            HStack {
                Image(systemName: "pills.fill")
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
                Text("Active Medications")
                Spacer()
                Button("Edit") {
                    showingMedicationEditor = true
                }
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.blue)
            }
        }
        .onAppear {
            loadActiveMedications()
        }
        .sheet(isPresented: $showingMedicationEditor) {
            // You can implement medication editor here if needed
            Text("Medication Editor")
        }
    }
    
    private func loadActiveMedications() {
        let activeCases = patient.medicalCases.filter { $0.isActive }
        let medications = activeCases.flatMap { $0.prescriptions.flatMap { $0.medications } }
        self.activeMedications = medications
    }
    
    private func timePeriodSection(timePeriod: MedicationTracker.TimePeriod, medications: [MedicationTracker.MedicationScheduleInfo]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            // Time Period Header
            HStack(spacing: 8) {
                Image(systemName: timePeriod.icon)
                    .font(.title3)
                    .foregroundStyle(.linearGradient(colors: timePeriod.gradientColors, startPoint: .topLeading, endPoint: .bottomTrailing))
                    .apply { image in
                        if #available(iOS 17.0, *) {
                            image
                                .symbolRenderingMode(.hierarchical)
                                .symbolEffect(.breathe.byLayer)
                        } else {
                            image
                        }
                    }
                
                Text(timePeriod.rawValue)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Text("\(medications.count)")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .frame(width: 20, height: 20)
                    .background(Circle().fill(.linearGradient(colors: timePeriod.gradientColors, startPoint: .topLeading, endPoint: .bottomTrailing)))
            }
            
            // Medications for this time period
            LazyVStack(spacing: 8) {
                ForEach(Array(medications.enumerated()), id: \.element.medication.id) { index, medicationInfo in
                    medicationCard(medicationInfo: medicationInfo, timePeriod: timePeriod)
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.thinMaterial)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(.linearGradient(colors: [timePeriod.color.opacity(0.08), timePeriod.color.opacity(0.03)], startPoint: .topLeading, endPoint: .bottomTrailing))
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(.linearGradient(colors: timePeriod.gradientColors.map { $0.opacity(0.4) }, startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 1.5)
        )
    }
    
    private func medicationCard(medicationInfo: MedicationTracker.MedicationScheduleInfo, timePeriod: MedicationTracker.TimePeriod) -> some View {
        HStack(spacing: 12) {
            // Medication Icon
            Circle()
                .fill(.linearGradient(colors: timePeriod.gradientColors, startPoint: .topLeading, endPoint: .bottomTrailing))
                .frame(width: 8, height: 8)
                .shadow(color: timePeriod.color.opacity(0.6),
                        radius: 2, x: 0, y: 1)
            
            VStack(alignment: .leading, spacing: 4) {
                // Medication Name
                Text(medicationInfo.medication.name)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                
                // Dosage and Timing
                HStack(spacing: 8) {
                    Text(medicationInfo.dosageText)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("•")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text(medicationInfo.displayTime)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                // Instructions (if available)
                if let instructions = medicationInfo.medication.instructions, !instructions.isEmpty {
                    Text(instructions)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                        .padding(.top, 2)
                }
            }
            
            Spacer()
            
            // Duration Badge
            VStack(alignment: .trailing, spacing: 4) {
                Text("\(medicationInfo.medication.numberOfDays) days")
                    .font(.caption2)
                    .fontWeight(.medium)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(
                        Capsule()
                            .fill(.linearGradient(colors: [.green.opacity(0.2), .green.opacity(0.1)], startPoint: .topLeading, endPoint: .bottomTrailing))
                    )
                    .foregroundColor(.green)
                    .overlay(
                        Capsule()
                            .stroke(.green.opacity(0.3), lineWidth: 0.5)
                    )
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(.ultraThinMaterial)
                .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(.quaternary, lineWidth: 0.5)
        )
    }
}


struct PatientHomeView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            PatientHomeView(patient: .constant(Patient.samplePatient))
        }
    }
}

// MARK: - View Extension for Conditional Modifiers
extension View {
    @ViewBuilder
    func apply<T: View>(@ViewBuilder _ transform: (Self) -> T) -> some View {
        transform(self)
    }
}

