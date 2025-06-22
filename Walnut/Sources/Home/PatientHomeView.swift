//
//  PatientHomeView.swift
//  Walnut
//
//  Created by Mayank Gandhi on 07/06/25.
//  Copyright © 2025 m. All rights reserved.
//

import ComposableArchitecture
import SwiftUI

// MARK: - Patient Home View
struct PatientHomeView: View {
    @Bindable var store: StoreOf<PatientHomeFeature>
    
    private var selectedPatientBinding: Binding<Patient?> {
        Binding(
            get: { store.selectedPatient?.patient },
            set: { newPatient in
                if let patient = newPatient {
                    store.send(.patientSelected(patient))
                }
            }
        )
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                
                
                if store.isLoading {
                    ProgressView("Loading patients...")
                        .foregroundColor(.textSecondary)
                } else if let selectedPatientStore = store.scope(state: \.selectedPatient, action: \.selectedPatient) {
                    PatientView(store: selectedPatientStore)
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    PatientSelector(selectedPatient: selectedPatientBinding,
                                    patients: store.patients,
                                    placeholder: "Select Patient")
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        store.send(.showAddPatientFlow)
                    } label: {
                        Image(systemName: "person.badge.plus")
                            .font(.system(size: 20, weight: .semibold))
                    }
                    .buttonStyle(.automatic)
                }
            }
            .sheet(item: $store.scope(state: \.addPatient, action: \.addPatient)) { addPatientStore in
                AddPatientView(store: addPatientStore)
            }
        }
        .onAppear {
            store.send(.onAppear)
        }
    }
}



