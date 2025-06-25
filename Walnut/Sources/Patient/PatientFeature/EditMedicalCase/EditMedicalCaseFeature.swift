//
//  EditMedicalCaseFeature.swift
//  Walnut
//
//  Created by Mayank Gandhi on 22/06/25.
//  Copyright © 2025 m. All rights reserved.
//

import ComposableArchitecture

// MARK: - Edit Medical Case Feature
@Reducer
struct EditMedicalCaseFeature {
    @ObservableState
    struct State: Equatable {
        let originalCase: MedicalCase
        var title: String
        var notes: String
        var treatmentPlan: String
        var followUpRequired: Bool
        var isLoading = false
        var validationError: String?
        
        var isValid: Bool {
            !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        }
        
        var hasChanges: Bool {
            title != (originalCase.title ?? "") ||
            notes != (originalCase.notes ?? "") ||
            treatmentPlan != (originalCase.treatmentPlan ?? "") ||
            followUpRequired != originalCase.followUpRequired
        }
        
        init(medicalCase: MedicalCase) {
            self.originalCase = medicalCase
            self.title = medicalCase.title ?? ""
            self.notes = medicalCase.notes ?? ""
            self.treatmentPlan = medicalCase.treatmentPlan ?? ""
            self.followUpRequired = medicalCase.followUpRequired
        }
    }
    
    enum Action: BindableAction {
        case binding(BindingAction<State>)
        case saveChanges
        case caseSaved(MedicalCase)
        case saveError(String)
        case dismiss
        case delegate(Delegate)
        
        enum Delegate {
            case caseUpdated(MedicalCase)
        }
    }
    
    var body: some ReducerOf<Self> {
        BindingReducer()
        
        Reduce { state, action in
            switch action {
            case .saveChanges:
                guard state.isValid else {
                    state.validationError = "Case title is required"
                    return .none
                }
                
                guard state.hasChanges else {
                    return .send(.dismiss)
                }
                
                state.isLoading = true
                state.validationError = nil
                
                return .run { [state] send in
                    do {
                        @Dependency(\.medicalCaseService)var medicalCaseService
                        let updatedCase = try await medicalCaseService.updateMedicalCase(
                            caseID: state.originalCase.id!,
                            title: state.title.trimmingCharacters(in: .whitespacesAndNewlines),
                            notes: state.notes.isEmpty ? nil : state.notes,
                            treatmentPlan: state.treatmentPlan.isEmpty ? nil : state.treatmentPlan,
                            followUpRequired: state.followUpRequired
                        )
                        await send(.caseSaved(updatedCase))
                    } catch {
                        await send(.saveError(error.localizedDescription))
                    }
                }
                
            case let .caseSaved(medicalCase):
                state.isLoading = false
                return .send(.delegate(.caseUpdated(medicalCase)))
                
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
