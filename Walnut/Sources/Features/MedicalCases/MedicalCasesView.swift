//
//  Patient+MedicalCasesView.swift
//  Walnut-Playground
//
//  Created by Mayank Gandhi on 29/06/25.
//  Copyright © 2025 m. All rights reserved.
//

import SwiftUI
import SwiftData
import WalnutDesignSystem

struct MedicalCasesView: View {
    
    @State private var viewModel: MedicalCasesViewModel
    
    init(viewModel: MedicalCasesViewModel) {
        self.viewModel = viewModel
    }
    
    private var emptyStateView: some View {
        HealthCard {
            VStack(spacing: Spacing.large) {
                Circle()
                    .fill(Color.healthPrimary.opacity(0.15))
                    .frame(width: 80, height: 80)
                    .overlay {
                        Image(systemName: "doc.text.magnifyingglass")
                            .font(.system(size: 32, weight: .semibold))
                            .foregroundStyle(Color.healthPrimary)
                    }
                
                VStack(spacing: Spacing.small) {
                    Text("No Medical Cases")
                        .font(.title2.weight(.semibold))
                        .foregroundStyle(.primary)
                    
                    Text(viewModel.isEmpty == true ?
                         "Create your first medical case to get started" :
                            "No cases match your search or filter criteria")
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                }
                
                if viewModel.isEmpty == true {
                    Button("Create Medical Case") {
                        viewModel.showCreateMedicalCase()
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                }
            }
            .frame(maxWidth: .infinity)
        }
        .padding(.horizontal, Spacing.medium)
    }
    
    // MARK: - Body
    
    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading {
                    loadingView
                } else if !viewModel.hasFilteredResults {
                    emptyStateView
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                } else {
                    medicalCasesList(viewModel: viewModel)
                }
            }
            .navigationTitle("Medical Cases")
            .navigationBarTitleDisplayMode(.large)
            .searchable(text: Binding(
                get: { viewModel.searchText ?? "" },
                set: { viewModel.updateSearchText($0) }
            ), prompt: "Search cases, patients, or notes")
            .toolbar {
                toolbarContent
            }
            .navigationDestination(item: $viewModel.selectedCase) { medicalCase in
                MedicalCaseDetailView(medicalCase: medicalCase)
            }
            .sheet(isPresented: $viewModel.showCreateView, onDismiss: {
                viewModel.dismissCreateSheet()
            }) {
                MedicalCaseEditor(patient: viewModel.patient)
            }
            .sheet(item: $viewModel.caseToEdit, onDismiss: {
                viewModel.dismissEditSheet()
            }) { medicalCase in
                MedicalCaseEditor(
                    medicalCase: medicalCase,
                    patient: medicalCase.patient
                )
            }
            .alert("Delete Medical Case", isPresented: $viewModel.showDeleteAlert) {
                Button("Cancel", role: .cancel) {
                    viewModel.cancelDelete()
                }
                Button("Delete", role: .destructive) {
                    Task {
                        await viewModel.deleteCase()
                    }
                }
            } message: {
                Text("Are you sure you want to delete this medical case? This action cannot be undone.")
            }
            .task {
                await viewModel.refreshData()
            }
            .refreshable {
                await viewModel.refreshData()
            }
        }
    }
    
    // MARK: - View Components
    
    private var loadingView: some View {
        VStack(spacing: Spacing.medium) {
            ProgressView()
                .scaleEffect(1.2)
            
            Text("Loading medical cases...")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private func medicalCasesList(viewModel: MedicalCasesViewModel) -> some View {
        ScrollView {
            LazyVGrid(
                columns: [.init(), .init()],
                alignment: .leading,
                spacing: Spacing.xs
            ) {
                ForEach(viewModel.filteredAndSortedCases) { medicalCase in
                    Button {
                        viewModel.selectCase(medicalCase)
                    } label: {
                        MedicalCaseListItem(medicalCase: medicalCase)
                    }
                    .buttonStyle(.plain)
                    .contextMenu {
                        contextMenuItems(for: medicalCase, viewModel: viewModel)
                    }
                }
            }
            .padding(.horizontal, Spacing.medium)
        }
    }
    
    // MARK: - Toolbar Content
    
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItemGroup(placement: .primaryAction) {
            Button("Add Medical Case", systemImage: "plus") {
                viewModel.showCreateMedicalCase()
            }
        }
    }
    
    @ViewBuilder
    private func contextMenuItems(for medicalCase: MedicalCase, viewModel: MedicalCasesViewModel) -> some View {
        Button {
            viewModel.selectCase(medicalCase)
        } label: {
            Label("View Details", systemImage: "doc.text")
        }
        Button {
            viewModel.editCase(medicalCase)
        } label: {
            Label("Edit", systemImage: "pencil")
        }
        Divider()
        Button(role: .destructive) {
            viewModel.confirmDeleteCase(medicalCase)
        } label: {
            Label("Delete", systemImage: "trash")
        }
    }
}
