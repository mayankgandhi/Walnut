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
        var notes = ""
        
        var isDatePickerPresented = false
        var isLoading = false
        
        // TCA Alert State
        @Presents
        var alert: AlertState<Action.Alert>?
        
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
        case patientSaveResponse(Result<Patient, PatientError>)
        case alert(PresentationAction<Alert>)
        
        case delegate(Delegate)
        
        case showDismissAlertFormFilled
        enum Alert: Equatable {
            case confirmDismiss
            case retryAction
        }
        
        enum Delegate {
            case dismissAddFlow
            case patientCreated(Patient)
        }
    }
    
    @Dependency(\.dismiss) var dismiss
    @Dependency(\.patientRepository) var patientRepository
    
    var body: some ReducerOf<Self> {
        BindingReducer()
        
        Reduce { state, action in
            switch action {
                
            case .dateOfBirthTapped:
                state.isDatePickerPresented = true
                return .none
                
            case .dismissDatePicker:
                state.isDatePickerPresented = false
                return .none
                
            case .savePatient:
                guard state.isFormValid else {
                    state.alert = AlertState(
                        title: TextState("Invalid Form"),
                        message: TextState("Please fill in all required fields (First Name and Last Name)."),
                        buttons: [
                            ButtonState(role: .cancel) {
                                TextState("OK")
                            }]
                    )
                    return .none
                }
                
                state.isLoading = true
                
                return .run { [state] send in
                    do {
                        let patient = try patientRepository.createPatient(
                            firstName: state.firstName,
                            lastName: state.lastName,
                            dateOfBirth: state.dateOfBirth,
                            gender: state.gender.isEmpty ? nil : state.gender,
                            bloodType: state.bloodType.isEmpty ? nil : state.bloodType,
                            emergencyContactName: state.emergencyContactName.isEmpty ? nil : state.emergencyContactName,
                            emergencyContactPhone: state.emergencyContactPhone.isEmpty ? nil : state.emergencyContactPhone,
                            notes: state.notes.isEmpty ? nil : state.notes,
                            isActive: true
                        )
                        await send(.patientSaveResponse(.success(patient)))
                    } catch {
                        let patientError = error as? PatientError ?? .unknown(error.localizedDescription)
                        await send(.patientSaveResponse(.failure(patientError)))
                    }
                }
                
            case let .patientSaveResponse(.success(patient)):
                state.isLoading = false
                return .send(.delegate(.patientCreated(patient)))
                
            case let .patientSaveResponse(.failure(error)):
                state.isLoading = false
                state.alert = alertForError(error)
                return .none
                
            case .showDismissAlertFormFilled:
                state.alert = AlertState(
                    title: TextState("Are you sure?"),
                    message: TextState("Please fill in all required fields (First Name and Last Name)."),
                    buttons: [
                        ButtonState(action: .confirmDismiss) {
                            TextState("Confirm")
                        },
                        ButtonState(role: .cancel) {
                            TextState("OK")
                        }
                    ]
                )
                return .none
                
            case .alert(.presented(.confirmDismiss)):
                return .send(.delegate(.dismissAddFlow))
                
            case .alert(.presented(.retryAction)):
                return .send(.savePatient)
                
            default:
                return .none
            }
        }
        .ifLet(\.$alert, action: \.alert)
    }
    
    private func alertForError(_ error: PatientError) -> AlertState<Action.Alert> {
        switch error {
        case .duplicatePatient:
            return AlertState(
                title: TextState("Duplicate Patient"),
                message: TextState("A patient with this name and date of birth already exists."),
                buttons: [
                    ButtonState(role: .cancel) {
                        TextState("Cancel")
                    },
                    ButtonState(action: .retryAction) {
                        TextState("Try Again")
                    }
                ]
            )
            
        case .invalidData(let message):
            return AlertState(
                title: TextState("Invalid Data"),
                message: TextState(message),
                buttons: [
                    ButtonState(role: .cancel) {
                        TextState("OK")
                    }
                ]
            )
            
        case .networkError:
            return AlertState(
                title: TextState("Network Error"),
                message: TextState("Unable to save patient. Please check your internet connection and try again."),
                buttons: [
                    ButtonState(role: .cancel) {
                        TextState("Cancel")
                    },
                    ButtonState(action: .retryAction) {
                        TextState("Retry")
                    }
                ]
            )
            
        case .databaseError:
            return AlertState(
                title: TextState("Database Error"),
                message: TextState("Unable to save patient to local database. Please try again."),
                buttons: [
                    ButtonState(role: .cancel) {
                        TextState("Cancel")
                    },
                    ButtonState(action: .retryAction) {
                        TextState("Retry")
                    }
                ]
            )
            
        case .unknown(let message):
            return AlertState(
                title: TextState("Error"),
                message: TextState(message),
                buttons: [
                    ButtonState(role: .cancel) {
                        TextState("Cancel")
                    },
                    ButtonState(action: .retryAction) {
                        TextState("Try Again")
                    }
                ]
            )
        }
    }}

// MARK: - Patient Error Types

enum PatientError: LocalizedError, Equatable {
    case duplicatePatient
    case invalidData(String)
    case networkError
    case databaseError
    case unknown(String)
    
    var errorDescription: String? {
        switch self {
        case .duplicatePatient:
            return "A patient with this information already exists"
        case .invalidData(let message):
            return "Invalid data: \(message)"
        case .networkError:
            return "Network connection error"
        case .databaseError:
            return "Database error occurred"
        case .unknown(let message):
            return message
        }
    }
}
