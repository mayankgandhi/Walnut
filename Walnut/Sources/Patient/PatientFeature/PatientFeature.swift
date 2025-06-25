//
//  PatientFeature.swift
//  Walnut
//
//  Created by Mayank Gandhi on 22/06/25.
//  Copyright © 2025 m. All rights reserved.
//

import ComposableArchitecture
import SwiftUI

// MARK: - Patient Feature
@Reducer
struct PatientFeature {
    @ObservableState
    struct State: Equatable {
        let patient: Patient
        var medicalCases: [MedicalCase] = []
        var isLoadingCases = false
        var showingAddCase = false
        @Presents var addCase: AddMedicalCaseFeature.State?
        
        init(patient: Patient) {
            self.patient = patient
        }
    }
    
    enum Action {
        case onAppear
        case medicalCasesLoaded([MedicalCase])
        case showAddCase
        case hideAddCase
        case addCase(PresentationAction<AddMedicalCaseFeature.Action>)
    }
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                state.isLoadingCases = true
                return .none
                
            case let .medicalCasesLoaded(cases):
                state.medicalCases = cases
                state.isLoadingCases = false
                return .none
                
            case .showAddCase:
                state.addCase = AddMedicalCaseFeature.State(patientID: state.patient.id!)
                return .none
                
            case .hideAddCase:
                state.addCase = nil
                return .none
                
             case .addCase(.presented(.delegate(.caseCreated(let newCase)))):
                state.medicalCases.append(newCase)
                state.addCase = nil
                return .none
           
            default:
                return .none
            }
        }
        .ifLet(\.$addCase, action: \.addCase) {
            AddMedicalCaseFeature()
        }
    }
}

// MARK: - Patient View
struct PatientView: View {
    @Bindable var store: StoreOf<PatientFeature>
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 24) {
                PatientHeaderView(patient: store.patient)
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
        }
        .onAppear {
            store.send(.onAppear)
        }
        .sheet(item: $store.scope(state: \.addCase, action: \.addCase)) { addCaseStore in
            AddMedicalCaseView(store: addCaseStore)
        }
    }
}

// MARK: - Patient Header View
struct PatientHeaderView: View {
    let patient: Patient
    
    private var age: Int {
        Calendar.current.dateComponents([.year], from: patient.dateOfBirth ?? Date(), to: Date()).year ?? 0
    }
    
    private var initials: String {
        let first = patient.firstName?.prefix(1) ?? ""
        let last = patient.lastName?.prefix(1) ?? ""
        return "\(first)\(last)".uppercased()
    }
    
    var body: some View {
        VStack(spacing: 20) {
            // Profile Section
            HStack(spacing: 16) {
                // Avatar
                ZStack {
                    Circle()
                        .fill(LinearGradient(
                            colors: [.blue.opacity(0.8), .purple.opacity(0.6)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ))
                        .frame(width: 80, height: 80)
                    
                    Text(initials)
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("\(patient.firstName ?? "") \(patient.lastName ?? "")")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    HStack(spacing: 16) {
                        Label("\(age) years", systemImage: "calendar")
                        if let gender = patient.gender {
                            Label(gender, systemImage: "person")
                        }
                    }
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    
                    if let bloodType = patient.bloodType {
                        HStack {
                            Image(systemName: "drop.fill")
                                .foregroundColor(.red)
                            Text("Blood Type: \(bloodType)")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                Spacer()
            }
           
        }
        .padding(20)
        
    }
}
