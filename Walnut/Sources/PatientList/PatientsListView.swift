//
//  PatientsListView.swift
//  Walnut-Playground
//
//  Created by Mayank Gandhi on 29/06/25.
//  Copyright © 2025 m. All rights reserved.
//

import SwiftUI

public struct PatientsListView: View {
    
    @State var search: String = ""
    @State var patients: [Patient] = Patient.sampleData
    @State var selectedPatient: Patient? = nil
    
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
                .onChange(of: search) {
                    if search == "" {
                        patients = Patient.sampleData
                    } else {
                        patients = Patient.sampleData.filter {
                            $0.fullName.localizedCaseInsensitiveContains(search)
                        }
                    }
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
