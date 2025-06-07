//
//  MedicalRecordsListFeature.swift
//  Walnut
//
//  Created by Mayank Gandhi on 07/06/25.
//  Copyright © 2025 m. All rights reserved.
//

import ComposableArchitecture
import SwiftUI

// MARK: - Medical Records Feature
@Reducer
struct MedicalRecordsListFeature {
    @ObservableState
    struct State: Equatable {
        var patient: Patient?
        var medicalRecords: [MedicalRecord] = []
        var isLoading = false
    }
    
    enum Action {
        case loadRecords
        case recordsLoaded([MedicalRecord])
        case recordTapped(MedicalRecord)
        case viewAllTapped
    }
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .loadRecords:
                state.isLoading = true
                return .run { send in
                    await send(.recordsLoaded([]))
                }
                
            case let .recordsLoaded(records):
                state.medicalRecords = records
                state.isLoading = false
                return .none
                
            case .recordTapped, .viewAllTapped:
                return .none
            }
        }
    }
}
