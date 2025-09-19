//
//  MedicationsView.swift
//  Walnut
//
//  Created by Mayank Gandhi on 19/09/25.
//  Copyright © 2025 m. All rights reserved.
//

import SwiftUI
import SwiftData
import WalnutDesignSystem

/// Parent container view for all medication-related functionality
struct MedicationsView: View {

    // MARK: - Properties
    let patient: Patient
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel: MedicationsViewModel

    // MARK: - Initialization

    init(patient: Patient, modelContext: ModelContext) {
        self.patient = patient
        // Initialize with a placeholder - will be properly set in onAppear
        self._viewModel = State(initialValue: MedicationsViewModel(patient: patient, modelContext: modelContext))
    }

    // MARK: - Body

    var body: some View {
        ActiveMedicationsView(
            patient: patient,
            todaysMedications: viewModel.todaysActiveMedications,
            onAddMedication: viewModel.showAddMedication,
            onShowAllMedications: viewModel.showMedicationsList,
            onEditMedication: viewModel.editMedication
        )
        .onAppear {
            viewModel.refreshData()
        }
        .refreshable {
            viewModel.refreshData()
        }
        .sheet(isPresented: $viewModel.showingAddMedication) {
            MedicationEditor(
                patient: patient,
                onSave: viewModel.handleNewMedicationSave
            )
        }
        .sheet(item: $viewModel.medicationToEdit) { medication in
            MedicationEditor(
                patient: patient,
                medication: medication,
                onSave: viewModel.handleMedicationSave
            )
        }
        .sheet(isPresented: $viewModel.showingMedicationsList) {
            NavigationView {
                ActiveMedicationsListView(
                    patient: patient,
                    medications: viewModel.activeMedications,
                    onEdit: viewModel.handleMedicationEdit
                )
            }
            .presentationDetents([.large])
            .presentationDragIndicator(.visible)
        }
        .alert("Medication Error", isPresented: $viewModel.showingError) {
            Button("OK") {
                viewModel.clearError()
            }
        } message: {
            Text(viewModel.errorMessage ?? "An unknown error occurred")
        }
    }
}

#Preview {
    let container = PreviewContainer.createModelContainer()

    NavigationStack {
        MedicationsView(patient: .samplePatient, modelContext: container.mainContext)
    }
    .modelContainer(for: Patient.self, inMemory: true)
}
