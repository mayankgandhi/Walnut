//
//  PatientFeature.swift
//  Walnut
//
//  Created by Mayank Gandhi on 22/06/25.
//  Copyright © 2025 m. All rights reserved.
//

import ComposableArchitecture
import SwiftUI

// MARK: - Patient Feature
@Reducer
struct PatientFeature {
    @ObservableState
    struct State: Equatable {
        let patient: Patient
        var medicalCases: [MedicalCase] = []
        var isLoadingCases = false
        var showingAddCase = false
        @Presents var addCase: AddMedicalCaseFeature.State?
        @Presents var editCase: EditMedicalCaseFeature.State?
        @Presents var selectedCaseForDetails: MedicalCaseDetailsFeature.State?
        
        init(patient: Patient) {
            self.patient = patient
        }
    }
    
    enum Action {
        case onAppear
        case medicalCasesLoaded([MedicalCase])
        case showAddCase
        case hideAddCase
        case addCase(PresentationAction<AddMedicalCaseFeature.Action>)
        case editTapped(MedicalCase)
        case editCase(PresentationAction<EditMedicalCaseFeature.Action>)
        case showCaseDetails(MedicalCase)
        case hideCaseDetails
        case caseDetailsAction(PresentationAction<MedicalCaseDetailsFeature.Action>)
        case deleteCases(IndexSet)
        case caseDeleted(MedicalCase)
    }
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                state.isLoadingCases = true
                return .run { [patientID = state.patient.id] send in
                    // Load medical cases for this patient
                    @Dependency(\.medicalCaseService) var medicalCaseService
                    let cases = try await medicalCaseService.loadMedicalCases(for: patientID!)
                    let allCases = cases.filter { $0.id != nil }
                    await send(.medicalCasesLoaded(allCases))
                }
                
            case let .medicalCasesLoaded(cases):
                state.medicalCases = cases
                state.isLoadingCases = false
                return .none
                
            case .showAddCase:
                state.addCase = AddMedicalCaseFeature.State(patientID: state.patient.id!)
                return .none
                
            case .hideAddCase:
                state.addCase = nil
                return .none
                
            case let .showCaseDetails(medicalCase):
                state.selectedCaseForDetails = MedicalCaseDetailsFeature.State(medicalCase: medicalCase)
                return .none
                
            case .hideCaseDetails:
                state.selectedCaseForDetails = nil
                return .none
                
            case let .deleteCases(indexSet):
                let casesToDelete = indexSet.map { state.medicalCases[$0] }
                return .run { send in
                    for `case` in casesToDelete {
                        @Dependency(\.medicalCaseService) var medicalCaseService
                        _ = try await medicalCaseService.deleteMedicalCase(`case`)
                        await send(.caseDeleted(`case`))
                    }
                } catch: { error,_ in
                    dump(error)
                }
                
            case let .caseDeleted(deletedCase):
                state.medicalCases.removeAll { $0.id == deletedCase.id }
                return .none
                
            case .addCase(.presented(.delegate(.caseCreated(let newCase)))):
                state.medicalCases.append(newCase)
                state.addCase = nil
                return .none
                
            case .editCase(.presented(.delegate(.caseUpdated(let updatedCase)))):
                if let index = state.medicalCases.firstIndex(where: { $0.id == updatedCase.id }) {
                    state.medicalCases[index] = updatedCase
                }
                state.editCase = nil
                return .none
                
            default:
                return .none
            }
        }
        .ifLet(\.$addCase, action: \.addCase) {
            AddMedicalCaseFeature()
        }
        .ifLet(\.$editCase, action: \.editCase) {
            EditMedicalCaseFeature()
        }
        .ifLet(\.$selectedCaseForDetails, action: \.caseDetailsAction) {
            MedicalCaseDetailsFeature()
        }
    }
}

// MARK: - Patient View
struct PatientView: View {
    @Bindable var store: StoreOf<PatientFeature>
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 24) {
                PatientHeaderView(patient: store.patient)
                MedicalCasesSection(store: store)
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
        }
        .onAppear {
            store.send(.onAppear)
        }
        .sheet(item: $store.scope(state: \.addCase, action: \.addCase)) { addCaseStore in
            AddMedicalCaseView(store: addCaseStore)
        }
        .sheet(item: $store.scope(state: \.editCase, action: \.editCase)) { editCaseStore in
            EditMedicalCaseView(store: editCaseStore)
        }
        .sheet(item: $store.scope(state: \.selectedCaseForDetails, action: \.caseDetailsAction)) { detailsStore in
            MedicalCaseDetailsView(store: detailsStore)
        }
    }
}

// MARK: - Patient Header View
struct PatientHeaderView: View {
    let patient: Patient
    
    private var age: Int {
        Calendar.current.dateComponents([.year], from: patient.dateOfBirth ?? Date(), to: Date()).year ?? 0
    }
    
    private var initials: String {
        let first = patient.firstName?.prefix(1) ?? ""
        let last = patient.lastName?.prefix(1) ?? ""
        return "\(first)\(last)".uppercased()
    }
    
    var body: some View {
        VStack(spacing: 20) {
            // Profile Section
            HStack(spacing: 16) {
                // Avatar
                ZStack {
                    Circle()
                        .fill(LinearGradient(
                            colors: [.blue.opacity(0.8), .purple.opacity(0.6)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ))
                        .frame(width: 80, height: 80)
                    
                    Text(initials)
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("\(patient.firstName ?? "") \(patient.lastName ?? "")")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.textPrimary)
                    
                    HStack(spacing: 16) {
                        Label("\(age) years", systemImage: "calendar")
                        if let gender = patient.gender {
                            Label(gender, systemImage: "person")
                        }
                    }
                    .font(.subheadline)
                    .foregroundColor(.textSecondary)
                    
                    if let bloodType = patient.bloodType {
                        HStack {
                            Image(systemName: "drop.fill")
                                .foregroundColor(.red)
                            Text("Blood Type: \(bloodType)")
                                .font(.subheadline)
                                .foregroundColor(.textSecondary)
                        }
                    }
                }
                
                Spacer()
            }
            
            // Quick Stats Cards
            HStack(spacing: 12) {
                QuickStatCard(
                    title: "Cases",
                    value: "\(patient.medicalCases?.count ?? 0)",
                    icon: "folder.fill",
                    color: .blue
                )
                
                QuickStatCard(
                    title: "Records",
                    value: "\(patient.medicalRecords?.count ?? 0)",
                    icon: "doc.text.fill",
                    color: .green
                )
                
                QuickStatCard(
                    title: "Lab Results",
                    value: "\(patient.labResults?.count ?? 0)",
                    icon: "chart.line.uptrend.xyaxis",
                    color: .orange
                )
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.cardBackground)
                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
        )
    }
}

// MARK: - Quick Stat Card
struct QuickStatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)
            
            Text(value)
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundColor(.textPrimary)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(color.opacity(0.1))
        )
    }
}

// MARK: - Medical Cases Section
struct MedicalCasesSection: View {
    
    @Bindable var store: StoreOf<PatientFeature>
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Section Header
            HStack {
                Text("Medical Cases")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.textPrimary)
                
                Spacer()
                
                Button {
                    store.send(.showAddCase)
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "plus")
                        Text("Add Case")
                    }
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.accentColor)
                    )
                }
            }
            
            // Cases List
            if store.isLoadingCases {
                CasesLoadingView()
            } else if store.medicalCases.isEmpty {
                EmptyCasesView {
                    store.send(.showAddCase)
                }
            } else {
                LazyVStack(spacing: 12) {
                    ForEach(store.medicalCases, id: \.id) { medicalCase in
                        MedicalCaseCard(
                            medicalCase: medicalCase,
                            onTap: { store.send(.showCaseDetails(medicalCase)) },
                            onEdit: {
                                store.send(.editTapped(medicalCase))
                            }
                        )
                    }
                    .onDelete { indexSet in
                        store.send(.deleteCases(indexSet))
                    }
                }
            }
        }
    }
}

// MARK: - Medical Case Card
struct MedicalCaseCard: View {
    let medicalCase: MedicalCase
    let onTap: () -> Void
    let onEdit: () -> Void
    
    private var statusColor: Color {
        medicalCase.followUpRequired ? .orange : .green
    }
    
    private var statusText: String {
        medicalCase.followUpRequired ? "Follow-up Required" : "Completed"
    }
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                // Status Indicator
                VStack {
                    Circle()
                        .fill(statusColor)
                        .frame(width: 12, height: 12)
                    
                    Rectangle()
                        .fill(statusColor.opacity(0.3))
                        .frame(width: 2)
                        .frame(maxHeight: .infinity)
                }
                .frame(height: 60)
                
                // Case Content
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(medicalCase.title ?? "Untitled Case")
                            .font(.headline)
                            .fontWeight(.medium)
                            .foregroundColor(.textPrimary)
                            .multilineTextAlignment(.leading)
                        
                        Spacer()
                        
                        Menu {
                            Button("Edit", action: onEdit)
                            Button("View Details", action: onTap)
                        } label: {
                            Image(systemName: "ellipsis")
                                .foregroundColor(.textSecondary)
                                .padding(8)
                        }
                    }
                    
                    if let notes = medicalCase.notes, !notes.isEmpty {
                        Text(notes)
                            .font(.subheadline)
                            .foregroundColor(.textSecondary)
                            .lineLimit(2)
                            .multilineTextAlignment(.leading)
                    }
                    
                    HStack {
                        Text(statusText)
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(statusColor)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(statusColor.opacity(0.15))
                            )
                        
                        Spacer()
                        
                        if let createdAt = medicalCase.createdAt {
                            Text(createdAt, style: .date)
                                .font(.caption)
                                .foregroundColor(.textTertiary)
                        }
                    }
                }
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.textTertiary)
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.cardBackground)
                    .shadow(color: .black.opacity(0.03), radius: 4, x: 0, y: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Loading and Empty States
struct CasesLoadingView: View {
    var body: some View {
        VStack(spacing: 16) {
            ForEach(0..<3, id: \.self) { _ in
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.gray.opacity(0.1))
                    .frame(height: 80)
                    .redacted(reason: .placeholder)
            }
        }
    }
}

struct EmptyCasesView: View {
    let onAddCase: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "folder.badge.plus")
                .font(.system(size: 48))
                .foregroundColor(.textTertiary)
            
            VStack(spacing: 8) {
                Text("No Medical Cases")
                    .font(.headline)
                    .foregroundColor(.textPrimary)
                
                Text("Start by creating the first medical case for this patient")
                    .font(.subheadline)
                    .foregroundColor(.textSecondary)
                    .multilineTextAlignment(.center)
            }
            
            Button("Add First Case", action: onAddCase)
                .buttonStyle(.borderedProminent)
        }
        .padding(40)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.cardBackground)
                .strokeBorder(Color.gray.opacity(0.2), lineWidth: 1)
        )
    }
}

// MARK: - Color Extensions
extension Color {
    static let walnutBackground = Color(UIColor.systemGroupedBackground)
    static let cardBackground = Color(UIColor.systemBackground)
    static let textPrimary = Color(UIColor.label)
    static let textSecondary = Color(UIColor.secondaryLabel)
    static let textTertiary = Color(UIColor.tertiaryLabel)
}
