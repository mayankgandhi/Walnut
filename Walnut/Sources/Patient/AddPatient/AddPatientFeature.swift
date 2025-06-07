//
//  AddPatientFeature.swift
//  Walnut
//
//  Created by Mayank Gandhi on 07/06/25.
//  Copyright © 2025 m. All rights reserved.
//


import ComposableArchitecture
import Foundation
import SwiftUI

// MARK: - Add Patient Feature

@Reducer
struct AddPatientFeature {
    
    @ObservableState
    struct State: Equatable {
        var firstName = ""
        var lastName = ""
        var dateOfBirth: Date?
        var gender = ""
        var bloodType = ""
        var emergencyContactName = ""
        var emergencyContactPhone = ""
        var insuranceProvider = ""
        var insurancePolicyNumber = ""
        var medicalRecordNumber = ""
        var notes = ""
        
        var isDatePickerPresented = false
        var isLoading = false
        var errorMessage: String?
        
        // Validation
        var isFormValid: Bool {
            !firstName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
            !lastName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        }
        
        // Gender options
        let genderOptions = ["Male", "Female", "Other", "Prefer not to say"]
        
        // Blood type options
        let bloodTypeOptions = ["A+", "A-", "B+", "B-", "AB+", "AB-", "O+", "O-"]
    }
    
    enum Action: BindableAction {
        case binding(BindingAction<State>)
        case dateOfBirthTapped
        case dismissDatePicker
        case savePatient
        case patientSaveResponse(Result<Void, Error>)
        case dismiss
    }
    
    @Dependency(\.dismiss) var dismiss
    
    var body: some ReducerOf<Self> {
        BindingReducer()
        
        Reduce { state, action in
            switch action {
            case .binding:
                return .none
                
            case .dateOfBirthTapped:
                state.isDatePickerPresented = true
                return .none
                
            case .dismissDatePicker:
                state.isDatePickerPresented = false
                return .none
                
            case .savePatient:
                guard state.isFormValid else { return .none }
                
                state.isLoading = true
                state.errorMessage = nil
                
                // In a real app, you would inject a patient repository/service
                return .run { [state] send in
                    do {
                        // Simulate saving patient
                        try await Task.sleep(for: .seconds(1))
                        await send(.patientSaveResponse(.success(())))
                    } catch {
                        await send(.patientSaveResponse(.failure(error)))
                    }
                }
                
            case let .patientSaveResponse(.success):
                state.isLoading = false
                return .run { _ in await self.dismiss() }
                
            case let .patientSaveResponse(.failure(error)):
                state.isLoading = false
                state.errorMessage = error.localizedDescription
                return .none
                
            case .dismiss:
                return .run { _ in await self.dismiss() }
            }
        }
    }
}