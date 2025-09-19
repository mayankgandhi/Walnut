//
//  ActiveMedicationsView.swift
//  Walnut
//
//  Created by Mayank Gandhi on 19/09/25.
//  Copyright © 2025 m. All rights reserved.
//

import SwiftUI
import SwiftData
import WalnutDesignSystem

struct ActiveMedicationsView: View {

    // MARK: - Properties
    let patient: Patient
    let onAddMedication: () -> Void
    let onShowAllMedications: () -> Void
    let onEditMedication: (Medication) -> Void

    @State private var timelineViewModel: MedicationTimelineViewModel

    // MARK: - Initialization

    init(
        patient: Patient,
        onAddMedication: @escaping () -> Void,
        onShowAllMedications: @escaping () -> Void,
        onEditMedication: @escaping (Medication) -> Void,
        modelContext: ModelContext
    ) {
        self.patient = patient
        self.onAddMedication = onAddMedication
        self.onShowAllMedications = onShowAllMedications
        self.onEditMedication = onEditMedication
        self._timelineViewModel = State(initialValue: MedicationTimelineViewModel(patient: patient, modelContext: modelContext))
    }

    // MARK: - Body

    var body: some View {
        ScrollView {
            VStack(spacing: Spacing.medium) {
                headerView

                // Main medications content
                if !timelineViewModel.scheduledDoses.isEmpty {
                    MedicationTimelineView(scheduledDoses: timelineViewModel.scheduledDoses)
                } else {
                    MedicationEmptyState()
                }
            }
            .padding(.bottom, 100) // Extra padding for better scrolling
        }
        .background {
            ContentBackgroundView(color: .yellow)
        }
        .onAppear {
            timelineViewModel.refreshData()
        }
        .refreshable {
            timelineViewModel.refreshData()
        }
        .onReceive(NotificationCenter.default.publisher(for: .medicationDataChanged)) { _ in
            timelineViewModel.refreshData()
        }
    }

    // MARK: - Computed Properties

    private var totalDosesCount: Int {
        timelineViewModel.scheduledDoses.values.reduce(0) { $0 + $1.count }
    }

    // MARK: - Private Views

    private var headerView: some View {
        HStack {
            NavBarHeader(
                iconName: "pill-bottle",
                iconColor: .yellow,
                title: "Medications",
                subtitle: "\(totalDosesCount) Today"
            )

            HStack(spacing: Spacing.small) {
                Button(action: onShowAllMedications) {
                    Image(systemName: "list.bullet")
                }
                .buttonStyle(.glass)

                Button(action: onAddMedication) {
                    Image(systemName: "plus")
                }
                .buttonStyle(.glass)
            }
            .padding(.trailing, Spacing.medium)
        }
    }

}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Patient.self, configurations: config)
    let context = container.mainContext

    NavigationStack {
        ActiveMedicationsView(
            patient: .samplePatient,
            onAddMedication: { print("Add medication") },
            onShowAllMedications: { print("Show all medications") },
            onEditMedication: { _ in print("Edit medication") },
            modelContext: context
        )
    }
    .modelContainer(container)
}
