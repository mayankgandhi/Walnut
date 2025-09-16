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
        ContentUnavailableView {
            Label(viewModel.searchText.isEmpty ? "No Medical Cases" : "No Results",
                  systemImage: viewModel.searchText.isEmpty ? "doc.text" : "magnifyingglass")
        } description: {
            Text(viewModel.searchText.isEmpty ?
                 "Create your first medical case to get started" :
                 "No cases match your search criteria")
        } actions: {
            if viewModel.searchText.isEmpty {
                Button("Create Medical Case") {
                    viewModel.showCreateMedicalCase()
                }
                .buttonStyle(.borderedProminent)
            } else {
                Button("Clear Search") {
                    viewModel.clearSearch()
                }
                .buttonStyle(.bordered)
            }
        }
    }
    
    // MARK: - Body
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: Spacing.medium) {
                HStack {
                    NavBarHeader(
                        iconName: "folder",
                        iconColor: .red,
                        title: "Medical Cases",
                        subtitle: "\(viewModel.medicalCases.count) Cases"
                    )

                    Button(action: viewModel.showCreateMedicalCase) {
                        Image(systemName: "plus")
                    }
                    .buttonStyle(.glass)
                    .padding(.trailing, Spacing.medium)
                }

                // Search bar
                SearchBar(
                    searchText: Binding(
                        get: { viewModel.searchText },
                        set: { viewModel.updateSearchText($0) }
                    ),
                    placeholder: "Search cases...",
                    onClear: {
                        viewModel.clearSearch()
                    }
                )
                .padding(.bottom, Spacing.small)
                
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
                columns: [.init(), .init(), .init()],
                alignment: .leading,
                spacing: .zero
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

#Preview("Medical Cases with 4 Cases") {
    let schema = Schema([
        Patient.self,
        MedicalCase.self,
        Prescription.self,
        BloodReport.self,
        Document.self
    ])
    let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: schema, configurations: [modelConfiguration])
    
    let patient = Patient(
        id: UUID(),
        name: "Alice Johnson",
        dateOfBirth: Calendar.current.date(byAdding: .year, value: -28, to: Date()) ?? Date(),
        gender: "Female",
        bloodType: "B+",
        emergencyContactName: "Bob Johnson",
        emergencyContactPhone: "(555) 234-5678",
        notes: "No known allergies",
        createdAt: Date(),
        updatedAt: Date(),
        medicalCases: []
    )
    
    let medicalCase1 = MedicalCase(
        id: UUID(),
        title: "Annual Physical Exam",
        notes: "Routine annual check-up. All vitals normal, blood work pending. Patient reports feeling healthy with no concerns.",
        type: .healthCheckup,
        specialty: .generalPractitioner,
        isActive: true,
        createdAt: Date().addingTimeInterval(-86400 * 14),
        updatedAt: Date().addingTimeInterval(-86400 * 2),
        patient: patient
    )
    
    let medicalCase2 = MedicalCase(
        id: UUID(),
        title: "Skin Rash Consultation",
        notes: "Patient presents with persistent rash on arms. Diagnosed as contact dermatitis. Prescribed topical corticosteroid.",
        type: .consultation,
        specialty: .dermatologist,
        isActive: true,
        createdAt: Date().addingTimeInterval(-86400 * 7),
        updatedAt: Date().addingTimeInterval(-86400 * 1),
        patient: patient
    )
    
    let medicalCase3 = MedicalCase(
        id: UUID(),
        title: "Knee Injury Follow-up",
        notes: "Follow-up for previous knee injury from sports. Physical therapy progressing well. Patient reports 80% improvement.",
        type: .followUp,
        specialty: .orthopedicSurgeon,
        isActive: false,
        createdAt: Date().addingTimeInterval(-86400 * 30),
        updatedAt: Date().addingTimeInterval(-86400 * 5),
        patient: patient
    )
    
    let medicalCase4 = MedicalCase(
        id: UUID(),
        title: "COVID-19 Vaccination",
        notes: "Annual COVID-19 booster vaccination administered. No adverse reactions reported. Patient tolerated well.",
        type: .immunisation,
        specialty: .generalPractitioner,
        isActive: false,
        createdAt: Date().addingTimeInterval(-86400 * 21),
        updatedAt: Date().addingTimeInterval(-86400 * 21),
        patient: patient
    )
    
    patient.medicalCases = [medicalCase1, medicalCase2, medicalCase3, medicalCase4]
    
    container.mainContext.insert(patient)
    
    return NavigationStack {
        MedicalCasesView(viewModel: MedicalCasesViewModel(patient: patient, modelContext: container.mainContext))
    }
    .modelContainer(container)
}

