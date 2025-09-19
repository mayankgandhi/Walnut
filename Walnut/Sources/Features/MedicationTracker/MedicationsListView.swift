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
        VStack(alignment: .leading, spacing: Spacing.medium) {
            
            NavBarHeader(
                iconName: "pills",
                iconColor: .yellow,
                title: "All Active Medications",
                subtitle: "\(viewModel.activeMedications.count) Medications"
            )
            
            ZStack {
                if viewModel.isLoading {
                    loadingView
                } else if viewModel.activeMedications.isEmpty {
                    emptyStateView
                } else {
                    medicationsContent
                }
            }
            
        }
        .onAppear {
            viewModel.loadActiveMedications()
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
                medicationsGroupedList
            }
            .padding(.horizontal, Spacing.medium)
            .padding(.bottom, Spacing.xl)
        }
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
            }
            
            LazyVGrid(
                columns: [
                    GridItem(.flexible(), spacing: Spacing.small),
                    GridItem(.flexible(), spacing: Spacing.small)
                ],
                spacing: Spacing.small
            ) {
                ForEach(medications, id: \.id) { medication in
                    medicationCard(medication)
                }
            }
        }
    }
    
    private func medicationCard(_ medication: Medication) -> some View {
        VStack(alignment: .leading, spacing: Spacing.small) {
            // Header with medication name and dosage
            VStack(alignment: .leading, spacing: Spacing.small) {
                VStack(alignment: .leading) {
                    Text(medication.name ?? "Unknown")
                        .font(.system(.subheadline, design: .rounded, weight: .semibold))
                        .foregroundStyle(.primary)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                    
                    // Dosage information
                    if let dosage = medication.dosage {
                        Text(dosage)
                            .font(.caption.weight(.medium))
                            .foregroundStyle(Color.healthPrimary)
                            .padding(.horizontal, Spacing.xs)
                            .padding(.vertical, 2)
                            .background(
                                Color.healthPrimary.opacity(0.1),
                                in: Capsule()
                            )
                    }
                }
            }
            
            // Frequency badges (compact)
            if let frequencies = medication.frequency, !frequencies.isEmpty {
                LazyVGrid(columns: [GridItem(.flexible())], spacing: 2) {
                    ForEach(Array(frequencies.enumerated()), id: \.offset) { _, frequency in
                        HStack(spacing: 4) {
                            Image(systemName: frequency.icon)
                                .font(.caption2)
                                .foregroundStyle(frequency.color)
                            
                            Text(frequency.displayText)
                                .font(.caption2.weight(.medium))
                                .foregroundStyle(.primary)
                                .lineLimit(1)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
            }
            
            // Instructions (compact)
            if let instructions = medication.instructions, !instructions.isEmpty {
                Text(instructions.lowercased())
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .lineLimit(3)
                    .truncationMode(.tail)
            }
            
            Spacer()
            
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(.thinMaterial)
        .cornerRadius(12)
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
    
}

#Preview {
    ActiveMedicationsListView(patient: .samplePatient, modelContext: ModelContext(try! ModelContainer(for: Patient.self)))
}
