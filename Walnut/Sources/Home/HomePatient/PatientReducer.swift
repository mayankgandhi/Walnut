//
//  PatientReducer.swift
//  Walnut
//
//  Created by Mayank Gandhi on 19/06/25.
//  Copyright © 2025 m. All rights reserved.
//

import ComposableArchitecture
import SwiftUI
import CoreData

// MARK: - Patient Home Feature
@Reducer
struct PatientReducer {
    
    @ObservableState
    struct State: Equatable {
        var patient: Patient
        var delete: PatientDeleteFeature.State
        
        init(patient: Patient) {
            self.patient = patient
            self.delete = PatientDeleteFeature.State(patient: patient)
        }
    }
    
    enum Action: BindableAction {
        case binding(BindingAction<State>)
        case onAppear
        
        case delete(PatientDeleteFeature.Action)
        case delegate(Delegate)
        
        enum Delegate {
            case dismiss
        }
    }
    
    // Dependency injection for the repository
    
    var body: some ReducerOf<Self> {
        BindingReducer()
        Scope(state: \.delete, action: \.delete) {
            PatientDeleteFeature()
        }
        Reduce { state, action in
            switch action {
                
            case .delete(.deleteCompleted):
                return .send(.delegate(.dismiss))
                
            default:
                return .none
            }
        }
        
    }
    
    
}

