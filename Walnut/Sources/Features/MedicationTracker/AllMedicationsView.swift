//
//  AllMedicationsView.swift
//  Walnut
//
//  Created by Mayank Gandhi on 11/08/25.
//  Copyright © 2025 m. All rights reserved.
//

import SwiftUI
import SwiftData
import WalnutDesignSystem
import UIKit
import Combine

/// Redesigned medication scheduling interface with timeline-based UI
struct AllMedicationsView: View {
    
    // MARK: - Properties
    
    let patient: Patient
    @Environment(\.modelContext) private var modelContext
    @Environment(\.medicationContainer) private var container
    
    // Services
    private let scheduleService: MedicationScheduleServiceProtocol
    
    // UI State
    @State private var selectedDate = Date()
    @State private var medicationToEdit: Medication? = nil
    @State private var showingDatePicker = false
    @State private var errorMessage: String? = nil
    @State private var showingError = false
    
    // SwiftData query for active prescriptions to automatically update UI
    @Query private var allPrescriptions: [Prescription]
    
    // MARK: - Initialization
    
    init(patient: Patient, container: MedicationDependencyContainer = .shared) {
        self.patient = patient
        self.scheduleService = container.resolveScheduleService()
    }
    
    // Computed property for active medications from prescriptions
    private var activeMedications: [Medication] {
        let activePrescriptions = allPrescriptions.filter { prescription in
            guard let medicalCase = prescription.medicalCase else { return false }
            return medicalCase.patient?.id == patient.id && (medicalCase.isActive ?? false)
        }
        
        return activePrescriptions.compactMap { $0.medications }.reduce([], +)
    }
    
    
    
    // MARK: - Body
    
    var body: some View {
    
        NavBarHeader(
            iconName: "pill-bottle",
            iconColor: .yellow,
            title: "Medications",
            subtitle: "\(scheduleService.todaysDoses.count) Medications"
        )
        
        ScrollView {
            VStack(spacing: Spacing.large) {
                // Main timeline content
                if !scheduleService.todaysDoses.isEmpty {
                    MedicationTimelineView(
                        scheduledDoses: scheduleService.timelineDoses
                    )
                } else {
                    MedicationEmptyState(onAddPrescription: handleAddPrescription)
                }
            }
            .padding(.top, Spacing.medium)
            .padding(.bottom, 100) // Extra padding for better scrolling
        }
        .sheet(item: $medicationToEdit) {
            MedicationEditor(
                medication: $0,
                onSave: handleMedicationSave
            )
        }
        .onAppear {
            setupScheduleService()
        }
        .onChange(of: selectedDate) { _, newDate in
            scheduleService.currentDate = newDate
        }
        .onChange(of: activeMedications) { _, medications in
            updateMedications(medications)
        }
        .alert("Schedule Error", isPresented: $showingError) {
            Button("OK") { errorMessage = nil }
        } message: {
            Text(errorMessage ?? "An unknown error occurred")
        }
    }
    
    
    private func handleMedicationSave(_ medication: Medication) {
        Task { @MainActor in
            // Find and update the prescription containing this medication
            let relevantPrescriptions = allPrescriptions.filter { prescription in
                prescription.medications?.contains(where: { $0.id == medication.id }) == true
            }
            
            for prescription in relevantPrescriptions {
                if let medicationIndex = prescription.medications?.firstIndex(where: { $0.id == medication.id }) {
                    prescription.medications?[medicationIndex] = medication
                    prescription.updatedAt = Date()
                    
                    do {
                        try modelContext.save()
                        // Refresh schedule after medication update
                        setupScheduleService()
                    } catch {
                        print("Error saving medication: \(error)")
                    }
                    return
                }
            }
        }
    }
    
    private func setupScheduleService() {
        // Initialize schedule service with current medications
        updateMedications(activeMedications)
        scheduleService.currentDate = selectedDate
    }
    
    private func updateMedications(_ medications: [Medication]) {
        let result = scheduleService.updateMedications(medications)
        
        if case .failure(let error) = result {
            errorMessage = error.localizedDescription
            showingError = true
        }
    }
    
    private func handleAddPrescription() {
        // Placeholder for add prescription navigation
        // In a real implementation, this would navigate to the prescription creation flow
        print("Navigate to add prescription")
    }
    
}

#Preview {
    NavigationStack {
        AllMedicationsView(patient: .samplePatient)
    }
    .modelContainer(for: Patient.self, inMemory: true)
}
