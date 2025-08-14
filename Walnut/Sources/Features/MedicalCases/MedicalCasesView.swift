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
    @State private var sortOption: SortOption = .dateNewest
    @State private var filterType: MedicalCaseType? = nil
    @State private var filterSpecialty: MedicalSpecialty? = nil
    @State private var showActiveOnly = false
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
                medicalCase.treatmentPlan.localizedCaseInsensitiveContains(searchText) ||
                medicalCase.patient.fullName.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        // Apply type filter
        if let filterType = filterType {
            cases = cases.filter { $0.type == filterType }
        }
        
        // Apply specialty filter
        if let filterSpecialty = filterSpecialty {
            cases = cases.filter { $0.specialty == filterSpecialty }
        }
        
        // Apply active filter
        if showActiveOnly {
            cases = cases.filter { $0.isActive }
        }
        
        // Apply sorting
        switch sortOption {
        case .dateNewest:
            cases.sort { $0.createdAt > $1.createdAt }
        case .dateOldest:
            cases.sort { $0.createdAt < $1.createdAt }
        case .titleAZ:
            cases.sort { $0.title < $1.title }
        case .titleZA:
            cases.sort { $0.title > $1.title }
        }
        
        return cases
    }
    
    private var activeFiltersCount: Int {
        var count = 0
        if filterType != nil { count += 1 }
        if filterSpecialty != nil { count += 1 }
        if showActiveOnly { count += 1 }
        return count
    }
    
    // MARK: - Subviews
    
    private var emptyStateView: some View {
        HealthCard(padding: Spacing.xl) {
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
                    List {
                        ForEach(filteredAndSortedCases) { medicalCase in
                            Button {
                                selectedCase = medicalCase
                            } label: {
                                EnhancedMedicalCaseListItem(medicalCase: medicalCase)
                            }
                            .buttonStyle(.plain)
                            .listRowInsets(EdgeInsets(top: Spacing.xs, leading: Spacing.medium, bottom: Spacing.xs, trailing: Spacing.medium))
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color.clear)
                            .contextMenu {
                                contextMenuItems(for: medicalCase)
                            }
                        }
                    }
                    .listStyle(.plain)
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
        ToolbarItemGroup(placement: .secondaryAction) {
            filterMenu
            sortMenu
        }
        ToolbarItemGroup(placement: .primaryAction) {
            Button("Add Medical Case", systemImage: "plus") {
                showCreateView = true
            }
        }
    }
    
    // MARK: - Filter Menu
    
    @ViewBuilder
    private var filterMenu: some View {
        Menu {
            VStack {
                Button {
                    filterSpecialty = nil
                } label: {
                    HStack {
                        Text("All Specialties")
                        if filterSpecialty == nil {
                            Image(systemName: "checkmark")
                        }
                    }
                }
                Section("Status") {
                    Toggle("Active Cases Only", isOn: $showActiveOnly)
                }
                
                if activeFiltersCount > 0 {
                    Section {
                        Button("Clear All Filters", role: .destructive) {
                            filterType = nil
                            filterSpecialty = nil
                            showActiveOnly = false
                        }
                    }
                }
            }
        } label: {
            Label("Filter", systemImage: "line.3.horizontal.decrease.circle")
                .symbolVariant(activeFiltersCount > 0 ? .fill : .none)
        }
        
    }
    
    // MARK: - Sort Menu
    
    @ViewBuilder
    private var sortMenu: some View {
        Menu {
            ForEach(SortOption.allCases, id: \.self) { option in
                Button {
                    sortOption = option
                } label: {
                    HStack {
                        Label(option.displayName, systemImage: option.icon)
                        if sortOption == option {
                            Image(systemName: "checkmark")
                        }
                    }
                }
            }
        } label: {
            Label("Sort", systemImage: "arrow.up.arrow.down.circle")
        }
    }
    
    // MARK: - Context Menu
    
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
        // Implement deletion logic here
        print("Deleting medical case: \(medicalCase.title)")
    }
    
    private func toggleActiveStatus(for medicalCase: MedicalCase) {
        // Implement status toggle logic here
        medicalCase.isActive.toggle()
        medicalCase.updatedAt = Date()
    }
}

// MARK: - Enhanced List Item View


struct SpecialtyBadge: View {
    let specialty: MedicalSpecialty
    
    var body: some View {
        HStack(spacing: Spacing.xs) {
            Image(systemName: specialty.icon)
                .font(.caption2)
            Text(specialty.rawValue)
                .font(.caption.weight(.medium))
        }
        .padding(.horizontal, Spacing.small)
        .padding(.vertical, Spacing.xs)
        .background(specialty.color.opacity(0.1))
        .foregroundStyle(specialty.color)
        .clipShape(Capsule())
    }
}

// MARK: - Supporting Types

enum SortOption: String, CaseIterable {
    case dateNewest = "Date (Newest)"
    case dateOldest = "Date (Oldest)"
    case titleAZ = "Title (A-Z)"
    case titleZA = "Title (Z-A)"
    
    
    var displayName: String { rawValue }
    
    var icon: String {
        switch self {
        case .dateNewest: return "calendar.badge.clock"
        case .dateOldest: return "calendar.badge.clock"
        case .titleAZ: return "textformat.abc"
        case .titleZA: return "textformat.abc"
        }
    }
}

