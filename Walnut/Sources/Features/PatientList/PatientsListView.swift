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
    @State private var editPatient: Patient? = nil
    @State private var showPatientEditor: Bool = false
    @State private var showCreatePatient: Bool = false
    @State private var navigationPath = NavigationPath()
    
    @Environment(\.modelContext) private var modelContext
    
    public init() {}
        
    public var body: some View {
        NavigationStack(path: $navigationPath) {
            patientsList
                .navigationTitle("Patients")
                .navigationBarTitleDisplayMode(.large)
                .navigationDestination(for: Patient.self) { patient in
                    PatientTabView(patient: patient)
                }
                .searchable(text: $search, prompt: "Search patients")
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
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
                .refreshable {
                    try? modelContext.save()
                }
        }
    }
    private var patientsList: some View {
        PatientsList(
            searchText: search,
            showCreatePatient: $showCreatePatient,
            onPatientsChanged: handlePatientsChanged
        ) { patient in
            NavigationLink(value: patient) {
                ModernPatientCard(patient: patient)
            }
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
    
    private func handlePatientsChanged(_ patients: [Patient]) {
        // Only auto-navigate if there's exactly 1 patient and no search is active and navigation path is empty
        if patients.count == 1 && search.isEmpty && navigationPath.isEmpty {
            navigationPath.append(patients[0])
        }
        // Clear navigation if we have multiple patients or are searching
        else if (patients.count != 1 || !search.isEmpty) && !navigationPath.isEmpty {
            navigationPath.removeLast(navigationPath.count)
        }
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
