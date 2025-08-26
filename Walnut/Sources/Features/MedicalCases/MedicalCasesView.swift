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
    
    @Environment(\.modelContext) private var modelContext
    
    @Query private var medicalCases: [MedicalCase]
    
    private let patient: Patient
    
    @State private var selectedCase: MedicalCase? = nil
    @State private var searchText = ""
    
    @State private var showCreateView = false
    @State private var caseToEdit: MedicalCase? = nil
    @State private var showDeleteAlert = false
    @State private var caseToDelete: MedicalCase? = nil
    
    init(patient: Patient) {
        self.patient = patient
        self._medicalCases = Query(filter: MedicalCase.predicate(patientID: patient.id),
                                   sort: \.updatedAt,
                                   order: .reverse)
    }
    
    // MARK: - Computed Properties
    
    private var filteredAndSortedCases: [MedicalCase] {
        var cases = medicalCases
        
        // Apply search filter
        if !searchText.isEmpty {
            cases = cases.filter { medicalCase in
                medicalCase.title.localizedCaseInsensitiveContains(searchText) ||
                medicalCase.notes.localizedCaseInsensitiveContains(searchText) ||
                medicalCase.patient.fullName.localizedCaseInsensitiveContains(searchText)
            }
        }
        return cases
    }
    
    // MARK: - Subviews
    
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
                    
                    Text(medicalCases.isEmpty ?
                         "Create your first medical case to get started" :
                            "No cases match your search or filter criteria")
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                }
                
                if medicalCases.isEmpty {
                    Button("Create Medical Case") {
                        showCreateView = true
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
                if filteredAndSortedCases.isEmpty {
                    emptyStateView
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                } else {
                    ScrollView {
                        LazyVGrid(
                            columns: [.init(), .init(), .init()],
                            alignment: .leading,
                            spacing: Spacing.xs
                        ) {
                            ForEach(filteredAndSortedCases) { medicalCase in
                                Button {
                                    selectedCase = medicalCase
                                } label: {
                                    EnhancedMedicalCaseListItem(medicalCase: medicalCase)
                                }
                                .buttonStyle(.plain)
                                .contextMenu {
                                    contextMenuItems(for: medicalCase)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Medical Cases")
            .navigationBarTitleDisplayMode(.large)
            .searchable(text: $searchText, prompt: "Search cases, patients, or notes")
            .toolbar {
                toolbarContent
            }
            .navigationDestination(item: $selectedCase) { medicalCase in
                MedicalCaseDetailView(
                    medicalCase: medicalCase
                )
            }
            .sheet(isPresented: $showCreateView, content: {
                MedicalCaseEditor(patient: patient)
            })
            .sheet(item: $caseToEdit) { medicalCase in
                MedicalCaseEditor(medicalCase: medicalCase, patient: medicalCase.patient)
            }
            .alert("Delete Medical Case", isPresented: $showDeleteAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Delete", role: .destructive) {
                    // Handle deletion
                    if let caseToDelete = caseToDelete {
                        deleteMedicalCase(caseToDelete)
                    }
                }
            } message: {
                Text("Are you sure you want to delete this medical case? This action cannot be undone.")
            }
        }
    }
    
    // MARK: - Toolbar Content
    
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItemGroup(placement: .primaryAction) {
            Button("Add Medical Case", systemImage: "plus") {
                showCreateView = true
            }
        }
    }
    
    @ViewBuilder
    private func contextMenuItems(for medicalCase: MedicalCase) -> some View {
        Button {
            selectedCase = medicalCase
        } label: {
            Label("View Details", systemImage: "doc.text")
        }
        
        Button {
            caseToEdit = medicalCase
        } label: {
            Label("Edit", systemImage: "pencil")
        }
        
        Button {
            // Toggle active status
            toggleActiveStatus(for: medicalCase)
        } label: {
            Label(
                medicalCase.isActive ? "Mark as Inactive" : "Mark as Active",
                systemImage: medicalCase.isActive ? "xmark.circle" : "checkmark.circle"
            )
        }
        
        Divider()
        
        Button(role: .destructive) {
            caseToDelete = medicalCase
            showDeleteAlert = true
        } label: {
            Label("Delete", systemImage: "trash")
        }
    }
    
    // MARK: - Actions
    
    private func deleteMedicalCase(_ medicalCase: MedicalCase) {
        // TODO: Implement deletion logic here
    }
    
    private func toggleActiveStatus(for medicalCase: MedicalCase) {
        // Implement status toggle logic here
        medicalCase.isActive.toggle()
        medicalCase.updatedAt = Date()
    }
}
