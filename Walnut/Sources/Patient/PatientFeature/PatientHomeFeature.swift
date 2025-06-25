//
//  PatientHomeFeature.swift
//  Walnut
//
//  Created by Mayank Gandhi on 07/06/25.
//  Copyright © 2025 m. All rights reserved.
//

import ComposableArchitecture
import SwiftUI
import CoreData

// MARK: - Patient Home Feature
@Reducer
struct PatientHomeFeature {
    
    @ObservableState
    struct State: Equatable {
        var patients: [Patient] = []
        var selectedPatient: PatientFeature.State?
        
        var isLoading = false
        var showingPatientSelector = false
        var error: String?
        
        var selectedPatientName: String {
            guard let patient = selectedPatient?.patient else { return "Select Patient" }
            return "\(patient.firstName ?? "") \(patient.lastName ?? "")"
        }
        @Presents var addPatient: AddPatientFeature.State?
    }
    
    enum Action: BindableAction {
        case binding(BindingAction<State>)
        case onAppear
        case patientsLoaded([Patient])
        case patientsLoadFailed(String)
        case patientSelected(Patient)
        case togglePatientSelector
        case loadPatientData(Patient)
        case refreshPatients
        
        case showAddPatientFlow
        case patientAdded(Patient)
        
        case selectedPatient(PatientFeature.Action)
        // Presentation
        case addPatient(PresentationAction<AddPatientFeature.Action>)
    }
    
    // Dependency injection for the repository
    var body: some ReducerOf<Self> {
        BindingReducer()

        Reduce { state, action in
            switch action {
                
            case .onAppear, .refreshPatients:
                state.isLoading = true
                state.error = nil
                return .run { send in
                    do {
                        let patients = try await loadActivePatients()
                        await send(.patientsLoaded(patients))
                    } catch {
                        await send(.patientsLoadFailed(error.localizedDescription))
                    }
                }
                
            case .showAddPatientFlow:
                state.addPatient = AddPatientFeature.State()
                return .none
                
            case let .patientsLoaded(patients):
                state.patients = patients
                state.isLoading = false
                state.error = nil
                
                // Auto-select first patient if none selected and patients exist
                if state.selectedPatient == nil, let firstPatient = patients.first {
                    return .send(.patientSelected(firstPatient))
                }
                return .none
                
            case let .patientsLoadFailed(error):
                state.isLoading = false
                state.error = error
                return .none
                
            case let .patientSelected(patient):
                state.selectedPatient = PatientFeature.State(patient: patient)
                state.showingPatientSelector = false
                return .send(.loadPatientData(patient))
                
            case .togglePatientSelector:
                state.showingPatientSelector.toggle()
                return .none
                
            case let .loadPatientData(patient):
                return .none
                
            case let .patientAdded(patient):
                // Refresh patients list and select the new patient
                state.patients.append(patient)
                return .send(.patientSelected(patient))
                
            case .addPatient(.presented(.delegate(.patientCreated(let patient)))):
                state.addPatient = nil
                return .send(.patientAdded(patient))
                
            case .addPatient(.presented(.delegate(.dismissAddFlow))):
                state.addPatient = nil
                return .none
                
            default:
                return .none
            }
        }
        .ifLet(\.selectedPatient, action: \.selectedPatient) {
            PatientFeature()
        }
        .ifLet(\.$addPatient, action: \.addPatient) {
            AddPatientFeature()
        }
    }
    
    // MARK: - Private Helper Functions
    
    @Sendable
    private func loadActivePatients() async throws -> [Patient] {
        return try await withCheckedThrowingContinuation { continuation in
            DispatchQueue.main.async {
                do {
                    @Dependency(\.patientRepository) var patientRepository
                    let patients = try patientRepository.fetchActivePatients()
                    continuation.resume(returning: patients)
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }
}

