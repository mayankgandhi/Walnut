//
//  MedicalCaseDetailsView.swift
//  Walnut
//
//  Created by Mayank Gandhi on 22/06/25.
//  Copyright © 2025 m. All rights reserved.
//

import SwiftUI
import ComposableArchitecture

// MARK: - Medical Case Details View
struct MedicalCaseDetailsView: View {
    @Bindable var store: StoreOf<MedicalCaseDetailsFeature>
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Tab Picker
                Picker("Detail Tab", selection: $store.selectedTab.sending(\.tabSelected)) {
                    ForEach(MedicalCaseDetailsFeature.State.DetailTab.allCases, id: \.self) { tab in
                        Text(tab.rawValue).tag(tab)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, 16)
                .padding(.bottom, 16)
                
                // Content
                if store.isLoading {
                    ProgressView("Loading case details...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    TabView(selection: $store.selectedTab.sending(\.tabSelected)) {
                        OverviewTabView(medicalCase: store.medicalCase)
                            .tag(MedicalCaseDetailsFeature.State.DetailTab.overview)
                        
                        MedicalRecordsTabView(records: store.medicalRecords)
                            .tag(MedicalCaseDetailsFeature.State.DetailTab.records)
                        
                        LabResultsTabView(labResults: store.labResults)
                            .tag(MedicalCaseDetailsFeature.State.DetailTab.labs)
                        
                        DocumentsTabView(documents: store.documents)
                            .tag(MedicalCaseDetailsFeature.State.DetailTab.documents)
                        
                        CalendarTabView(events: store.calendarEvents)
                            .tag(MedicalCaseDetailsFeature.State.DetailTab.calendar)
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))
                }
            }
            .navigationTitle(store.medicalCase.title ?? "Medical Case")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Edit") {
                        store.send(.showEditCase)
                    }
                }
            }
        }
        .onAppear {
            store.send(.onAppear)
        }
        .sheet(item: $store.scope(state: \.editCase, action: \.editCase)) { editStore in
            EditMedicalCaseView(store: editStore)
        }
    }
}
