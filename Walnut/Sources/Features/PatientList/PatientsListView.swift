//
//  PatientsListView.swift (Alternative with Dynamic Query)
//  Walnut-Playground
//
//  Created by Mayank Gandhi on 29/06/25.
//  Copyright © 2025 m. All rights reserved.
//

import SwiftUI
import SwiftData
import WalnutDesignSystem

public struct PatientsListView: View {
    
    @State private var search: String = ""
    @State private var selectedPatient: Patient? = nil
    @State private var editPatient: Patient? = nil
    @State private var showPatientEditor: Bool = false
    @State private var showCreatePatient: Bool = false
    @State private var selectedSortOption: SortOption = .name
    @State private var showSortOptions: Bool = false
    
    @Environment(\.modelContext) private var modelContext
    
    public init() {}
    
    enum SortOption: String, CaseIterable {
        case name = "Name"
        case recent = "Recent"
        case age = "Age"
        
        var systemImage: String {
            switch self {
            case .name: return "textformat.abc"
            case .recent: return "clock"
            case .age: return "calendar"
            }
        }
    }
    
    public var body: some View {
        if selectedPatient != nil {
            PatientView(selectedPatient: $selectedPatient)
        } else {
            NavigationStack {
                VStack(spacing: 0) {
                    headerView
                    patientsList
                }
                .navigationTitle("Patients")
                .navigationBarTitleDisplayMode(.large)
                .toolbar {
                    ToolbarItemGroup(placement: .topBarTrailing) {
                        HealthIconButton(
                            icon: selectedSortOption.systemImage,
                            style: .secondary
                        ) {
                            showSortOptions = true
                        }
                        
                        HealthIconButton(
                            icon: "plus",
                            style: .primary
                        ) {
                            showCreatePatient = true
                        }
                    }
                }
                .sheet(isPresented: $showCreatePatient) {
                    PatientEditor(patient: nil)
                }
                .sheet(item: $editPatient) { patient in
                    PatientEditor(patient: patient)
                }
                .confirmationDialog("Sort by", isPresented: $showSortOptions) {
                    ForEach(SortOption.allCases, id: \.self) { option in
                        Button(option.rawValue) {
                            selectedSortOption = option
                        }
                    }
                }
                .refreshable {
                    try? modelContext.save()
                }
            }
        }
    }
    
    private var headerView: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Healthcare Members")
                    .font(.title2.weight(.semibold))
                    .foregroundStyle(Color.healthPrimary)
                
                Spacer()
            }
            .padding(.horizontal, Spacing.medium)
            
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(.secondary)
                    .font(.system(size: 16))
                
                TextField("Search by name", text: $search)
                    .textFieldStyle(.plain)
                    .font(.system(size: 16))
                
                if !search.isEmpty {
                    HealthIconButton(
                        icon: "xmark.circle.fill",
                        style: .secondary
                    ) {
                        search = ""
                    }
                }
            }
            .padding(.horizontal, Spacing.medium)
            .padding(.vertical, Spacing.small + 4)
            .subtleCardStyle()
            .padding(.horizontal, Spacing.medium)
        }
        .padding(.vertical, Spacing.medium)
        .cardStyle()
    }
    
    private var patientsList: some View {
        PatientsList(
            searchText: search,
            sortOption: selectedSortOption,
            showCreatePatient: $showCreatePatient
        ) { patient in
            Button {
                withAnimation(.easeInOut(duration: 0.2)) {
                    selectedPatient = patient
                }
            } label: {
                ModernPatientCard(patient: patient)
            }
            .buttonStyle(.plain)
            .contextMenu {
                Button {
                    edit(patient)
                } label: {
                    Label("Edit Patient", systemImage: "pencil")
                }
                
                Divider()
                
                Button(role: .destructive) {
                    remove(patient)
                } label: {
                    Label("Delete Patient", systemImage: "trash")
                }
            }
        }
        
    }
    
    private func remove(_ patient: Patient) {
        modelContext.delete(patient)
    }
    
    private func edit(_ patient: Patient) {
        editPatient = patient
    }
}

