//
//  PatientsListView.swift (Alternative with Dynamic Query)
//  Walnut-Playground
//
//  Created by Mayank Gandhi on 29/06/25.
//  Copyright © 2025 m. All rights reserved.
//

import SwiftUI
import SwiftData

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
                        Button {
                            showSortOptions = true
                        } label: {
                            Image(systemName: selectedSortOption.systemImage)
                                .font(.system(size: 16, weight: .medium))
                        }
                        
                        Button {
                            showCreatePatient = true
                        } label: {
                            Image(systemName: "plus")
                                .font(.system(size: 16, weight: .semibold))
                        }
                    }
                }
                .sheet(isPresented: $showCreatePatient) {
                    CreatePatientView()
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
                    .foregroundStyle(.primary)
                
                Spacer()
            }
            .padding(.horizontal, 20)
            
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(.secondary)
                    .font(.system(size: 16))
                
                TextField("Search by name", text: $search)
                    .textFieldStyle(.plain)
                    .font(.system(size: 16))
                
                if !search.isEmpty {
                    Button {
                        search = ""
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.secondary)
                            .font(.system(size: 14))
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
            .padding(.horizontal, 20)
        }
        .padding(.vertical, 16)
        .background(.regularMaterial)
    }
    
    private var patientsList: some View {
        PatientsList(searchText: search, sortOption: selectedSortOption) { patient in
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
        .scrollContentBackground(.hidden)
        .listStyle(.plain)
    }
    
    private func remove(_ patient: Patient) {
        modelContext.delete(patient)
    }
    
    private func edit(_ patient: Patient) {
        editPatient = patient
    }
}

// Separate view to handle the dynamic query
private struct PatientsList<Content: View>: View {
    let searchText: String
    let sortOption: PatientsListView.SortOption
    let content: (Patient) -> Content
    
    // Dynamic query based on search text and sort option
    @Query private var patients: [Patient]
    
    init(searchText: String, sortOption: PatientsListView.SortOption, @ViewBuilder content: @escaping (Patient) -> Content) {
        self.searchText = searchText
        self.sortOption = sortOption
        self.content = content
        
        // Configure query based on search text and sort option
        let predicate: Predicate<Patient>
        let sortDescriptors: [SortDescriptor<Patient>]
        
        // Set up sort descriptors based on option
        switch sortOption {
        case .name:
            sortDescriptors = [
                SortDescriptor(\Patient.lastName),
                SortDescriptor(\Patient.firstName)
            ]
        case .recent:
            sortDescriptors = [
                SortDescriptor(\Patient.updatedAt, order: .reverse)
            ]
        case .age:
            sortDescriptors = [
                SortDescriptor(\Patient.dateOfBirth)
            ]
        }
        
        if searchText.isEmpty {
            predicate = #Predicate<Patient> { _ in true }
        } else {
            predicate = #Predicate<Patient> { patient in
                patient.firstName.localizedStandardContains(searchText) ||
                patient.lastName.localizedStandardContains(searchText)
            }
        }
        
        _patients = Query(filter: predicate, sort: sortDescriptors)
    }
    
    var body: some View {
        if patients.isEmpty {
            emptyStateView
        } else {
            List(patients) { patient in
                content(patient)
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets(top: 8, leading: 20, bottom: 8, trailing: 20))
            }
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: searchText.isEmpty ? "person.3" : "magnifyingglass")
                .font(.system(size: 60))
                .foregroundStyle(.tertiary)
            
            VStack(spacing: 8) {
                Text(searchText.isEmpty ? "No Patients Yet" : "No Results Found")
                    .font(.title2.weight(.semibold))
                    .foregroundStyle(.primary)
                
                Text(searchText.isEmpty ? 
                     "Add your first patient to get started with healthcare management." :
                     "Try adjusting your search terms or check the spelling.")
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.regularMaterial)
    }
}

struct PatientsListView_Previews: PreviewProvider {
    static var previews: some View {
        TabView {
            NavigationView {
                PatientsListView()
            }
        }
    }
}
