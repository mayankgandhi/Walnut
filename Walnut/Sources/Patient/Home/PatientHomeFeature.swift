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
        var selectedPatient: Patient?
        var isLoading = false
        var showingPatientSelector = false
        
        // Child feature states
        var medicalRecordsState = MedicalRecordsListFeature.State()
        var healthMetricsState = HealthMetricsFeature.State()
        var labResultsState = LabResultsFeature.State()
        var quickActionsState = QuickActionsFeature.State()
        
        var selectedPatientName: String {
            guard let patient = selectedPatient else { return "Select Patient" }
            return "\(patient.firstName) \(patient.lastName)"
        }
        
        @Presents var addPatient: AddPatientFeature.State?
    }
    
    enum Action: BindableAction {
        case binding(BindingAction<State>)
        case onAppear
        case patientsLoaded([Patient])
        case patientSelected(Patient)
        case togglePatientSelector
        case loadPatientData(Patient)
        
        case showAddPatientFlow
        
        // Child feature actions
        case medicalRecords(MedicalRecordsListFeature.Action)
        case healthMetrics(HealthMetricsFeature.Action)
        case labResults(LabResultsFeature.Action)
        case quickActions(QuickActionsFeature.Action)
        
        // Presentation
        case addPatient(PresentationAction<AddPatientFeature.Action>)
    }
    
    var body: some ReducerOf<Self> {
        BindingReducer()
        Scope(state: \.medicalRecordsState, action: \.medicalRecords) {
            MedicalRecordsListFeature()
        }
        
        Scope(state: \.healthMetricsState, action: \.healthMetrics) {
            HealthMetricsFeature()
        }
        
        Scope(state: \.labResultsState, action: \.labResults) {
            LabResultsFeature()
        }
        
        Scope(state: \.quickActionsState, action: \.quickActions) {
            QuickActionsFeature()
        }
        
        Reduce { state, action in
            switch action {
            case .onAppear:
                state.isLoading = true
                return .run { send in
                    // Simulate loading patients from CoreData
//                    let patients = await loadPatients()
                    await send(.patientsLoaded([]))
                }
                
            case .showAddPatientFlow:
                state.addPatient = AddPatientFeature.State()
                return .none
                
            case let .patientsLoaded(patients):
                state.patients = patients
                state.isLoading = false
                if let firstPatient = patients.first {
                    return .send(.patientSelected(firstPatient))
                }
                return .none
                
            case let .patientSelected(patient):
                state.selectedPatient = patient
                state.showingPatientSelector = false
                return .send(.loadPatientData(patient))
                
            case .togglePatientSelector:
                state.showingPatientSelector.toggle()
                return .none
                
            case let .loadPatientData(patient):
                // Update child states with patient data
                state.medicalRecordsState.patient = patient
                state.healthMetricsState.patient = patient
                state.labResultsState.patient = patient
                state.quickActionsState.patient = patient
                return .none
                
            default:
                return .none
            }
        }
        .ifLet(\.$addPatient, action: \.addPatient) {
            AddPatientFeature()
        }
    }
}





// MARK: - Quick Actions Feature
@Reducer
struct QuickActionsFeature {
    @ObservableState
    struct State: Equatable {
        var patient: Patient?
    }
    
    enum Action {
        case addDocumentTapped
        case scheduleAppointmentTapped
        case viewReportsTapped
        case contactDoctorTapped
    }
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .addDocumentTapped, .scheduleAppointmentTapped, .viewReportsTapped, .contactDoctorTapped:
                // Handle navigation actions here
                return .none
            }
        }
    }
}

// MARK: - Quick Actions View
struct QuickActionsView: View {
    @Bindable var store: StoreOf<QuickActionsFeature>
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Quick Actions")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.textPrimary)
                .padding(.horizontal, 20)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    QuickActionCard(
                        icon: "doc.badge.plus",
                        title: "Add Document",
                        color: .healthBlue
                    ) {
                        store.send(.addDocumentTapped)
                    }
                    
                    QuickActionCard(
                        icon: "calendar.badge.plus",
                        title: "Schedule",
                        color: .healthGreen
                    ) {
                        store.send(.scheduleAppointmentTapped)
                    }
                    
                    QuickActionCard(
                        icon: "chart.line.uptrend.xyaxis",
                        title: "View Reports",
                        color: .chartBlue
                    ) {
                        store.send(.viewReportsTapped)
                    }
                    
                    QuickActionCard(
                        icon: "phone.circle",
                        title: "Contact Doctor",
                        color: .healthCoral
                    ) {
                        store.send(.contactDoctorTapped)
                    }
                }
                .padding(.horizontal, 20)
            }
        }
    }
}

// MARK: - Quick Action Card
struct QuickActionCard: View {
    let icon: String
    let title: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Circle()
                    .fill(color.opacity(0.1))
                    .frame(width: 40, height: 40)
                    .overlay(
                        Image(systemName: icon)
                            .foregroundColor(color)
                            .font(.system(size: 18, weight: .medium))
                    )
                
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.textPrimary)
                    .multilineTextAlignment(.center)
            }
            .frame(width: 80)
            .padding(.vertical, 12)
            .background(Color.white)
            .cornerRadius(12)
            .shadow(color: .shadowColor.opacity(0.08), radius: 4, x: 0, y: 2)
        }
    }
}

// MARK: - Health Metrics Feature
@Reducer
struct HealthMetricsFeature {
    @ObservableState
    struct State: Equatable {
        var patient: Patient?
        var healthScore: Int = 85
        var recentMetrics: [HealthMetric] = []
    }
    
    enum Action {
        case loadMetrics
        case viewDetailsTapped
    }
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .loadMetrics:
                // Load health metrics for patient
                state.recentMetrics = mockHealthMetrics()
                return .none
                
            case .viewDetailsTapped:
                // Handle navigation to detailed metrics
                return .none
            }
        }
    }
}

// MARK: - Health Metrics View
struct HealthMetricsView: View {
    @Bindable var store: StoreOf<HealthMetricsFeature>
    
    var body: some View {
        FormSection(title: "Health Overview", icon: "heart.circle") {
            VStack(spacing: 16) {
                // Health Score
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Health Score")
                            .font(.subheadline)
                            .foregroundColor(.textSecondary)
                        
                        Text("\(store.healthScore)")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.healthGreen)
                    }
                    
                    Spacer()
                    
                    Button("View Details") {
                        store.send(.viewDetailsTapped)
                    }
                    .font(.caption)
                    .foregroundColor(.healthBlue)
                }
                
                // Recent Metrics
                if !store.recentMetrics.isEmpty {
                    VStack(spacing: 8) {
                        ForEach(store.recentMetrics, id: \.name) { metric in
                            HealthMetricRow(metric: metric)
                        }
                    }
                }
            }
        }
        .onAppear {
            store.send(.loadMetrics)
        }
    }
}

// MARK: - Health Metric Model & Row
struct HealthMetric: Equatable {
    let name: String
    let value: String
    let status: HealthStatus
    let date: Date
}

enum HealthStatus: Equatable {
    case normal, warning, critical
    
    var color: Color {
        switch self {
        case .normal: return .labNormal
        case .warning: return .labWarning
        case .critical: return .labCritical
        }
    }
}

struct HealthMetricRow: View {
    let metric: HealthMetric
    
    var body: some View {
        HStack {
            Circle()
                .fill(metric.status.color)
                .frame(width: 8, height: 8)
            
            Text(metric.name)
                .font(.subheadline)
                .foregroundColor(.textPrimary)
            
            Spacer()
            
            Text(metric.value)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.textSecondary)
        }
    }
}

private func mockHealthMetrics() -> [HealthMetric] {
    [
        HealthMetric(name: "Blood Pressure", value: "120/80", status: .normal, date: Date()),
        HealthMetric(name: "Heart Rate", value: "72 bpm", status: .normal, date: Date()),
        HealthMetric(name: "Blood Sugar", value: "95 mg/dL", status: .normal, date: Date())
    ]
}
