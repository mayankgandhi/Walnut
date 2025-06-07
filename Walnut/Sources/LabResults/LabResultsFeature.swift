//
//  LabResultsFeature.swift
//  Walnut
//
//  Created by Mayank Gandhi on 07/06/25.
//  Copyright © 2025 m. All rights reserved.
//

import ComposableArchitecture

// MARK: - Lab Results Feature
@Reducer
struct LabResultsFeature {
    @ObservableState
    struct State: Equatable {
        var patient: Patient?
        var recentLabResults: [LabResult] = []
        var isLoading = false
    }
    
    enum Action {
        case loadRecentResults
        case resultsLoaded([LabResult])
        case viewAllTapped
        case resultTapped(LabResult)
    }
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .loadRecentResults:
                state.isLoading = true
                return .run { send in
                    // Simulate loading recent lab results
                    let results = await loadRecentLabResults()
                    await send(.resultsLoaded(results))
                }
                
            case let .resultsLoaded(results):
                state.recentLabResults = results
                state.isLoading = false
                return .none
                
            case .viewAllTapped, .resultTapped:
                // Handle navigation
                return .none
            }
        }
    }
}
