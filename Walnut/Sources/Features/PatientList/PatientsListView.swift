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
    
    @State var search: String = ""
    @State var selectedPatient: Patient? = nil
    @State var showPatientEditor: Bool = false
    @Environment(\.modelContext) private var modelContext
    
    public init() {}
    
    public var body: some View {
        if selectedPatient != nil {
            PatientView(selectedPatient: $selectedPatient)
        } else {
            NavigationStack {
                PatientsList(searchText: search) { patient in
                    Button {
                        selectedPatient = patient
                    } label: {
                        PatientListItem(patient: patient)
                            .listRowSeparatorTint(.clear)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .searchable(text: $search, prompt: "Search patients...")
                .navigationTitle("Members")
                .listStyle(.plain)
                .toolbar {
                    ToolbarItem(placement: .primaryAction) {
                        Button("Add Patient", systemImage: "plus") {
                            showPatientEditor = true
                        }
                    }
                }
                .sheet(isPresented: $showPatientEditor) {
                    PatientEditor()
                }
                .refreshable {
                    try? modelContext.save()
                }
            }
        }
    }
}

// Separate view to handle the dynamic query
private struct PatientsList<Content: View>: View {
    let searchText: String
    let content: (Patient) -> Content
    
    // Dynamic query based on search text
    @Query private var patients: [Patient]
    
    init(searchText: String, @ViewBuilder content: @escaping (Patient) -> Content) {
        self.searchText = searchText
        self.content = content
        
        // Configure query based on search text
        let predicate: Predicate<Patient>
        let sortDescriptors = [
            SortDescriptor(\Patient.lastName),
            SortDescriptor(\Patient.firstName)
        ]
        
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
        List(patients) { patient in
            content(patient)
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
