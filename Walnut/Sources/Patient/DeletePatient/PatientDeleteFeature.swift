//
//  PatientDeleteFeature.swift
//  Walnut
//
//  Created by Mayank Gandhi on 19/06/25.
//  Copyright © 2025 m. All rights reserved.
//

import SwiftUI
import ComposableArchitecture

// MARK: - Feature
@Reducer
struct PatientDeleteFeature {
    
    @ObservableState
    struct State: Equatable {
        let patient: Patient
        var isShowingDeleteAlert = false
        var isDeleting = false
        
        init(patient: Patient) {
            self.patient = patient
        }
    }
    
    enum Action: BindableAction, Equatable {
        case binding(BindingAction<State>)
        case deleteButtonTapped
        case deleteAlertDismissed
        case deleteConfirmed
        case deleteCompleted
        case deleteFailed(String)
    }
    
    @Dependency(\.patientRepository) var patientRepository
    @Dependency(\.dismiss) var dismiss
    
    var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
                
            case .deleteButtonTapped:
                state.isShowingDeleteAlert = true
                return .none
                
            case .deleteAlertDismissed:
                state.isShowingDeleteAlert = false
                return .none
                
            case .deleteConfirmed:
                state.isShowingDeleteAlert = false
                state.isDeleting = true
                return .run { [patient = state.patient] send in
                    do {
                        try patientRepository.deletePatient(patient)
                        await send(.deleteCompleted)
                    } catch {
                        await send(.deleteFailed(error.localizedDescription))
                    }
                }
                
            case .deleteCompleted:
                state.isDeleting = false
                return .run { _ in
                    await dismiss()
                }
                
            case .deleteFailed(let error):
                state.isDeleting = false
                // Handle error - could add error state/alert here
                print("Delete failed: \(error)")
                return .none
                
            default:
                return .none
            }
        }
    }
}
