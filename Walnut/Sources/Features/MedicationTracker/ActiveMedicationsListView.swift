//
//  ActiveMedicationsListView.swift
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
            
            HStack(spacing: Spacing.small) {
                NavBarHeader(
                    iconName: "pills",
                    iconColor: .yellow,
                    title: "All Active Medications",
                    subtitle: "\(viewModel.activeMedications.count) Medications"
                )
                
                Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "xmark")
                }
                .buttonStyle(.glass)
            }
            .padding(.top, Spacing.medium)
            .padding(.trailing, Spacing.medium)
            
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
            
            ForEach(Array(groupedMeds.keys), id: \.self) { key in
                medicationGroupSection(
                    key: key,
                    medications: groupedMeds[key] ?? []
                )
            }
        }
    }
    
    private func medicationGroupSection(key: ActiveMedicationsListViewModel.MedicationKey, medications: [Medication]) -> some View {
        VStack(alignment: .leading, spacing: Spacing.medium) {
            HStack(alignment: .center, spacing: Spacing.medium) {
                
                if let icon = key.medicationSpecialty?.icon {
                    Image(icon)
                        .resizable()
                        .frame(width: 64, height: 64 )
                }
                
                VStack(alignment: .leading, spacing: Spacing.xs) {
                    Text(key.medicalCaseName)
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
                    ActiveMedicationCard(medication: medication)
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
    
}

#Preview {
    ActiveMedicationsListView(patient: .samplePatient, modelContext: ModelContext(try! ModelContainer(for: Patient.self)))
}
