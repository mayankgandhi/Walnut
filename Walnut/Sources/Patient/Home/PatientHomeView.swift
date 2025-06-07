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
                } else {
                    ScrollView {
                        LazyVStack(spacing: 20) {
                            if store.selectedPatient != nil {
                                // Quick Actions Section
                                QuickActionsView(
                                    store: store.scope(
                                        state: \.quickActionsState,
                                        action: \.quickActions
                                    )
                                )
                                
                                // Health Metrics Section
                                HealthMetricsView(
                                    store: store.scope(
                                        state: \.healthMetricsState,
                                        action: \.healthMetrics
                                    )
                                )
                                
                                // Recent Lab Results Section
                                LabResultsView(
                                    store: store.scope(
                                        state: \.labResultsState,
                                        action: \.labResults
                                    )
                                )
                                
                                // Medical Records Section
                                MedicalRecordsListView(
                                    store: store.scope(
                                        state: \.medicalRecordsState,
                                        action: \.medicalRecords
                                    )
                                )
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 20)
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    PatientSelectorButton(
                        selectedPatientName: store.selectedPatientName,
                        isExpanded: store.showingPatientSelector,
                        onTap: { store.send(.togglePatientSelector) }
                    )
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        store.send(.showAddPatientFlow)
                    } label: {
                        Image(systemName: "plus.app.fill")
                            .foregroundStyle(Color.walnutBrown)
                    }
                    .buttonStyle(.plain)
                }
            }
            .sheet(isPresented: $store.showingPatientSelector) {
                PatientSelectorSheet(
                    patients: store.patients,
                    selectedPatient: store.selectedPatient,
                    onPatientSelected: { patient in
                        store.send(.patientSelected(patient))
                    }
                )
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

// MARK: - Patient Selector Button
struct PatientSelectorButton: View {
    let selectedPatientName: String
    let isExpanded: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 8) {
                Image(systemName: "person.circle.fill")
                    .foregroundColor(.healthBlue)
                    .font(.system(size: 16))
                
                Text(selectedPatientName)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.textPrimary)
                
                Image(systemName: "chevron.down")
                    .foregroundColor(.textSecondary)
                    .font(.system(size: 12, weight: .medium))
                    .rotationEffect(.degrees(isExpanded ? 180 : 0))
                    .animation(.easeInOut(duration: 0.2), value: isExpanded)
            }
        }
    }
}

