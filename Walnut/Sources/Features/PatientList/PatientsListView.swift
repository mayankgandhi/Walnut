//
//  PatientsListView.swift
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
    
    @Query var patients: [Patient]
    @State var showPatientEditor: Bool = false
    public init() {}
    
    public var body: some View {
        if selectedPatient != nil {
                PatientView(selectedPatient: $selectedPatient)
        } else {
            NavigationStack {
                List(patients) { patient in
                    Button {
                        selectedPatient = patient
                    } label: {
                        PatientListItem(patient: patient)
                            .listRowSeparatorTint(.clear)
                    }
                }
                .searchable(text: $search)
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
            }
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
