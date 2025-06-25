//
//  AddMedicalCaseFeature.swift
//  Walnut
//
//  Created by Mayank Gandhi on 22/06/25.
//  Copyright © 2025 m. All rights reserved.
//

import ComposableArchitecture
import Foundation

// MARK: - Add Medical Case Feature
@Reducer
struct AddMedicalCaseFeature {
    @ObservableState
    struct State: Equatable {
        let patientID: UUID
        var title = ""
        var notes = ""
        var treatmentPlan = ""
        var followUpRequired = false
        var isLoading = false
        var validationError: String?
        
        var isValid: Bool {
            !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        }
        
        init(patientID: UUID) {
            self.patientID = patientID
        }
    }
    
    enum Action: BindableAction {
        case binding(BindingAction<State>)
        case saveCase
        case caseSaved(MedicalCase)
        case saveError(String)
        case dismiss
        case delegate(Delegate)
        
        enum Delegate {
            case caseCreated(MedicalCase)
        }
    }
    
    var body: some ReducerOf<Self> {
        BindingReducer()
        
        Reduce { state, action in
            switch action {
            case .saveCase:
                guard state.isValid else {
                    state.validationError = "Case title is required"
                    return .none
                }
                
                state.isLoading = true
                state.validationError = nil
                
                return .run { [state] send in
                    do {
                        @Dependency(\.medicalCaseService) var medicalCaseService
                        let newCase = try await medicalCaseService.createMedicalCase(
                            patientID: state.patientID,
                            title: state.title.trimmingCharacters(in: .whitespacesAndNewlines),
                            notes: state.notes.isEmpty ? nil : state.notes,
                            treatmentPlan: state.treatmentPlan.isEmpty ? nil : state.treatmentPlan,
                            followUpRequired: state.followUpRequired
                        )
                        await send(.caseSaved(newCase))
                    } catch {
                        await send(.saveError(error.localizedDescription))
                    }
                }
                
            case let .caseSaved(medicalCase):
                state.isLoading = false
                return .send(.delegate(.caseCreated(medicalCase)))
                
            case let .saveError(error):
                state.isLoading = false
                state.validationError = error
                return .none
                
            case .dismiss:
                return .none
                
            default:
                return .none
            }
        }
    }
}
