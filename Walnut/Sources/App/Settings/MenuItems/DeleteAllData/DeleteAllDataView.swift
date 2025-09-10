//
//  DeleteAllDataView.swift
//  Walnut
//
//  Created by Claude Code on 10/09/25.
//  Copyright © 2025 m. All rights reserved.
//

import SwiftUI
import SwiftData
import WalnutDesignSystem

struct DeleteAllDataView: View {
    @State private var viewModel: DeleteAllDataViewModel
    private let patient: Patient
    
    init(patient: Patient, modelContext: ModelContext) {
        self.patient = patient
        self._viewModel = State(wrappedValue: DeleteAllDataViewModel(patient: patient, modelContext: modelContext))
    }
    
    var body: some View {
        MenuListItem(
            icon: viewModel.menuItem.icon,
            title: viewModel.menuItem.title,
            subtitle: viewModel.menuItem.subtitle,
            iconColor: viewModel.menuItem.iconColor
        ) {
            viewModel.presentDeleteConfirmation()
        }
        .sheet(isPresented: $viewModel.showDeleteConfirmation, onDismiss: {
            viewModel.dismissDeleteConfirmation()
        }) {
            DSBottomSheet(
                title: "Delete All Data",
                subtitle: "This action cannot be undone",
                onDismiss: {
                    viewModel.dismissDeleteConfirmation()
                }
            ) {
                DeleteConfirmationContent(viewModel: viewModel)
            }
            .presentationDetents([.height(400)])
            .presentationDragIndicator(.visible)
        }
        .alert("Data Deleted", isPresented: $viewModel.showDeleteSuccess) {
            Button("OK") {
                viewModel.dismissDeleteSuccess()
            }
        } message: {
            Text("All patient data has been permanently deleted.")
        }
    }
}

private struct DeleteConfirmationContent: View {
    let viewModel: DeleteAllDataViewModel
    
    var body: some View {
        VStack(spacing: Spacing.large) {
            HealthCard {
                HStack(spacing: Spacing.medium) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.title2)
                        .foregroundStyle(Color.healthError)
                    
                    VStack(alignment: .leading, spacing: Spacing.xs) {
                        Text("Warning")
                            .font(.headline.weight(.semibold))
                            .foregroundStyle(.primary)
                        
                        Text("This will permanently delete all medical data for this patient")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    
                    Spacer()
                }
                
            }
            
            VStack(spacing: Spacing.medium) {
                DSButton(
                    "Delete All Data",
                    style: .destructive,
                    icon: "trash.fill",
                ) {
                    viewModel.confirmDelete()
                }
                .disabled(viewModel.isDeleting)
                
                DSButton(
                    "Cancel",
                    style: .secondary
                ) {
                    viewModel.dismissDeleteConfirmation()
                }
                .disabled(viewModel.isDeleting)
            }
        }
    }
}

#Preview {
    DeleteAllDataView(
        patient: .samplePatient,
        modelContext: ModelContext(try! ModelContainer(for: Patient.self))
    )
}
