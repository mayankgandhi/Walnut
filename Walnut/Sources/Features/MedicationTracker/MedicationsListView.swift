//
//  MedicationsListView.swift
//  Walnut
//
//  Created by Mayank Gandhi on 19/09/25.
//  Copyright © 2025 m. All rights reserved.
//

import Foundation
import SwiftUI
import SwiftData
import WalnutDesignSystem

struct ActiveMedicationsListView: View {

    let patient: Patient
    @State private var viewModel: ActiveMedicationsListViewModel
    @Environment(\.dismiss) private var dismiss

    init(patient: Patient, modelContext: ModelContext) {
        self.patient = patient
        self._viewModel = State(initialValue: ActiveMedicationsListViewModel(modelContext: modelContext, patient: patient))
    }

    var body: some View {
        NavigationView {
            ZStack {
                if viewModel.isLoading {
                    loadingView
                } else if viewModel.activeMedications.isEmpty {
                    emptyStateView
                } else {
                    medicationsContent
                }
            }
            .navigationTitle("Active Medications")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundStyle(Color.healthPrimary)
                }
            }
            .onAppear {
                viewModel.loadActiveMedications()
            }
        }
    }

    private var loadingView: some View {
        VStack(spacing: Spacing.large) {
            ProgressView()
                .scaleEffect(1.2)
                .progressViewStyle(CircularProgressViewStyle(tint: Color.healthPrimary))

            Text("Loading medications...")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }

    private var emptyStateView: some View {
        ContentUnavailableView {
            Label("No Active Medications", systemImage: "pills")
                .symbolRenderingMode(.multicolor)
        } description: {
            Text("This patient currently has no active medications from ongoing medical cases.")
                .multilineTextAlignment(.center)
        } actions: {
            Button("Close") {
                dismiss()
            }
            .buttonStyle(.borderedProminent)
            .tint(Color.healthPrimary)
        }
    }

    private var medicationsContent: some View {
        ScrollView {
            LazyVStack(spacing: Spacing.large) {
                headerSection

                if viewModel.activeMedications.count > 1 {
                    medicationsSummary
                }

                medicationsGroupedList
            }
            .padding(.horizontal, Spacing.medium)
            .padding(.bottom, Spacing.xl)
        }
    }

    private var headerSection: some View {
        HealthCard {
            VStack(alignment: .leading, spacing: Spacing.small) {
                HStack {
                    PatientAvatar(name: patient.name?.prefix(2).map(String.init).joined() ?? "?")

                    VStack(alignment: .leading, spacing: Spacing.xs) {
                        Text(patient.name ?? "Unknown Patient")
                            .font(.headline.weight(.semibold))

                        Text("\(viewModel.activeMedications.count) active medication\(viewModel.activeMedications.count == 1 ? "" : "s")")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }

                    Spacer()

                    Image(systemName: "pills")
                        .foregroundStyle(Color.red)
                        .font(.title2)
                }
            }
        }
    }

    private var medicationsSummary: some View {
        HealthCard {
            VStack(alignment: .leading, spacing: Spacing.medium) {
                Label("Summary", systemImage: "chart.bar.doc.horizontal")
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(Color.healthPrimary)

                let groupedMeds = viewModel.groupedMedications()
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: Spacing.small) {
                    ForEach(Array(groupedMeds.keys.sorted()), id: \.self) { caseTitle in
                        summaryCard(title: caseTitle, count: groupedMeds[caseTitle]?.count ?? 0)
                    }
                }
            }
        }
    }

    private func summaryCard(title: String, count: Int) -> some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            Text("\(count)")
                .font(.title2.weight(.bold))
                .foregroundStyle(Color.healthPrimary)

            Text(title)
                .font(.caption.weight(.medium))
                .foregroundStyle(.secondary)
                .lineLimit(2)
                .multilineTextAlignment(.leading)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(Spacing.small)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 8))
    }

    private var medicationsGroupedList: some View {
        LazyVStack(spacing: Spacing.large) {
            let groupedMeds = viewModel.groupedMedications()

            ForEach(Array(groupedMeds.keys.sorted()), id: \.self) { caseTitle in
                medicationGroupSection(
                    title: caseTitle,
                    medications: groupedMeds[caseTitle] ?? []
                )
            }
        }
    }

    private func medicationGroupSection(title: String, medications: [Medication]) -> some View {
        VStack(alignment: .leading, spacing: Spacing.medium) {
            HStack {
                VStack(alignment: .leading, spacing: Spacing.xs) {
                    Text(title)
                        .font(.title3.weight(.semibold))
                        .foregroundStyle(.primary)

                    Text("\(medications.count) medication\(medications.count == 1 ? "" : "s")")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Image(systemName: "folder.badge.plus")
                    .foregroundStyle(Color.healthSuccess)
                    .font(.title3)
            }

            LazyVStack(spacing: Spacing.medium) {
                ForEach(medications, id: \.id) { medication in
                    medicationCard(medication)
                }
            }
        }
    }

    private func medicationCard(_ medication: Medication) -> some View {
        HealthCard {
            VStack(alignment: .leading, spacing: Spacing.medium) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: Spacing.xs) {
                        HStack {
                            Text(medication.name ?? "Unknown Medication")
                                .font(.headline.weight(.semibold))
                                .foregroundStyle(.primary)

                            if let dosage = medication.dosage, !dosage.isEmpty {
                                Text(dosage)
                                    .font(.caption.weight(.medium))
                                    .foregroundStyle(Color.healthSuccess)
                                    .padding(.horizontal, Spacing.small)
                                    .padding(.vertical, Spacing.xs)
                                    .background(Color.healthSuccess.opacity(0.1))
                                    .clipShape(Capsule())
                            }
                        }

                        if let duration = medication.duration {
                            HStack(spacing: Spacing.xs) {
                                Image(systemName: "calendar")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)

                                Text(duration.displayText)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }

                    Spacer()

                    statusBadge(for: medication)
                }

                if let frequencies = medication.frequency, !frequencies.isEmpty {
                    frequencySection(frequencies)
                }

                if let instructions = medication.instructions, !instructions.isEmpty {
                    instructionsSection(instructions)
                }
            }
        }
    }

    private func statusBadge(for medication: Medication) -> some View {
        let status = viewModel.medicationStatus(for: medication)

        return HStack(spacing: Spacing.xs) {
            Circle()
                .fill(status.color)
                .frame(width: 8, height: 8)

            Text(status.displayText)
                .font(.caption.weight(.medium))
                .foregroundStyle(status.color)
        }
        .padding(.horizontal, Spacing.small)
        .padding(.vertical, Spacing.xs)
        .background(status.color.opacity(0.1))
        .clipShape(Capsule())
    }

    private func frequencySection(_ frequencies: [MedicationFrequency]) -> some View {
        VStack(alignment: .leading, spacing: Spacing.small) {
            Label("Schedule", systemImage: "clock")
                .font(.caption.weight(.medium))
                .foregroundStyle(Color.healthPrimary)

            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: Spacing.small) {
                ForEach(Array(frequencies.enumerated()), id: \.offset) { _, frequency in
                    HStack(spacing: Spacing.xs) {
                        Image(systemName: frequency.icon)
                            .foregroundStyle(frequency.color)
                            .font(.caption)

                        Text(frequency.displayText)
                            .font(.caption.weight(.medium))
                            .foregroundStyle(.primary)
                            .lineLimit(2)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(Spacing.small)
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 6))
                }
            }
        }
        .padding(Spacing.small)
        .background(Color.healthWarning.opacity(0.05))
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.healthWarning.opacity(0.2), lineWidth: 1)
        )
    }

    private func instructionsSection(_ instructions: String) -> some View {
        VStack(alignment: .leading, spacing: Spacing.small) {
            Label("Instructions", systemImage: "doc.text")
                .font(.caption.weight(.medium))
                .foregroundStyle(Color.healthPrimary)

            Text(instructions)
                .font(.caption)
                .foregroundStyle(.primary)
                .lineSpacing(2)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(Spacing.small)
        .background(Color.healthSuccess.opacity(0.05))
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.healthSuccess.opacity(0.2), lineWidth: 1)
        )
    }
}

#Preview {
    ActiveMedicationsListView(patient: .samplePatient, modelContext: ModelContext(try! ModelContainer(for: Patient.self)))
}
