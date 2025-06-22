//
//  MedicalCaseDetailsFeature.swift
//  Walnut
//
//  Created by Mayank Gandhi on 22/06/25.
//  Copyright © 2025 m. All rights reserved.
//

import ComposableArchitecture
import SwiftUI

// MARK: - Medical Case Details Feature
@Reducer
struct MedicalCaseDetailsFeature {
    @ObservableState
    struct State: Equatable {
        let medicalCase: MedicalCase
        var medicalRecords: [MedicalRecord] = []
        var labResults: [LabResult] = []
        var documents: [Document] = []
        var calendarEvents: [CalendarEvent] = []
        var isLoading = true
        var showingEditCase = false
        @Presents var editCase: EditMedicalCaseFeature.State?
        var selectedTab: DetailTab = .overview
        
        enum DetailTab: String, CaseIterable {
            case overview = "Overview"
            case records = "Records"
            case labs = "Lab Results"
            case documents = "Documents"
            case calendar = "Calendar"
        }
        
        init(medicalCase: MedicalCase) {
            self.medicalCase = medicalCase
        }
    }
    
    enum Action {
        case onAppear
        case dataLoaded(records: [MedicalRecord],
                        labs: [LabResult],
                        documents: [Document],
                        events: [CalendarEvent])
        case tabSelected(State.DetailTab)
        case showEditCase
        case hideEditCase
        case editCase(PresentationAction<EditMedicalCaseFeature.Action>)
        case dismiss
        case delegate(Delegate)
        
        enum Delegate {
            case caseUpdated(MedicalCase)
        }
    }
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                state.isLoading = true
                return .run { [caseID = state.medicalCase.id] send in
                    @Dependency(\.medicalCaseService) var medicalCaseService
                    async let records = medicalCaseService.loadMedicalRecords(for: caseID!)
                    async let labs = medicalCaseService.loadLabResults(for: caseID!)
                    async let documents = medicalCaseService.loadDocuments(for: caseID!)
                    async let events = medicalCaseService.loadCalendarEvents(for: caseID!)
                    await send(.dataLoaded(records: try await records,
                                           labs: try await labs,
                                           documents: try await documents,
                                           events: try await events))
                }
                
            case let .dataLoaded(records, labs, documents, events):
                state.medicalRecords = records
                state.labResults = labs
                state.documents = documents
                state.calendarEvents = events
                state.isLoading = false
                return .none
                
            case let .tabSelected(tab):
                state.selectedTab = tab
                return .none
                
            case .showEditCase:
                state.editCase = EditMedicalCaseFeature.State(medicalCase: state.medicalCase)
                return .none
                
            case .hideEditCase:
                state.editCase = nil
                return .none
                
            case .editCase(.presented(.delegate(.caseUpdated(let updatedCase)))):
                state.editCase = nil
                return .send(.delegate(.caseUpdated(updatedCase)))
                
            case .dismiss:
                return .none
                
            default:
                return .none
            }
        }
        .ifLet(\.$editCase, action: \.editCase) {
            EditMedicalCaseFeature()
        }
    }
}
