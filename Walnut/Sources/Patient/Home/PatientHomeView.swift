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
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.walnutBackground
                    .ignoresSafeArea()
                
                if store.isLoading {
                    ProgressView("Loading patients...")
                        .foregroundColor(.textSecondary)
                } else if let selectedPatient = store.selectedPatient {
                    ScrollView {
                        LazyVStack(spacing: 20) {
                            
                            PatientHeaderView(patient: selectedPatient)
                            
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 20)
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    PatientSelectorMenu(selectedPatient: $store.selectedPatient,
                                        patients: store.patients)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        store.send(.showAddPatientFlow)
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "plus")
                                .font(.system(size: 14, weight: .semibold))
                            Text("Add Patient")
                                .font(.system(size: 14, weight: .semibold))
                        }
                        .foregroundStyle(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.healthBlue)
                        )
                    }
                    .buttonStyle(.plain)
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



