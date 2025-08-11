//
//  PatientsList.swift
//  Walnut
//
//  Created by Mayank Gandhi on 09/08/25.
//  Copyright © 2025 m. All rights reserved.
//

import SwiftUI
import SwiftData

// Separate view to handle the dynamic query
private struct PatientsList<Content: View>: View {
    let searchText: String
    let sortOption: PatientsListView.SortOption
    @Binding var showCreatePatient: Bool
    let content: (Patient) -> Content
    
    // Dynamic query based on search text and sort option
    @Query private var patients: [Patient]
    
    init(searchText: String, sortOption: PatientsListView.SortOption, showCreatePatient: Binding<Bool>, @ViewBuilder content: @escaping (Patient) -> Content) {
        self.searchText = searchText
        self.sortOption = sortOption
        self._showCreatePatient = showCreatePatient
        self.content = content
        
        // Configure query based on search text and sort option
        let predicate: Predicate<Patient>
        let sortDescriptors: [SortDescriptor<Patient>]
        
        // Set up sort descriptors based on option
        switch sortOption {
        case .name:
            sortDescriptors = [
                SortDescriptor(\Patient.lastName),
                SortDescriptor(\Patient.firstName)
            ]
        case .recent:
            sortDescriptors = [
                SortDescriptor(\Patient.updatedAt, order: .reverse)
            ]
        case .age:
            sortDescriptors = [
                SortDescriptor(\Patient.dateOfBirth)
            ]
        }
        
        if searchText.isEmpty {
            predicate = #Predicate<Patient> { _ in true }
        } else {
            predicate = #Predicate<Patient> { patient in
                patient.firstName.localizedStandardContains(searchText) ||
                patient.lastName.localizedStandardContains(searchText)
            }
        }
        
        _patients = Query(filter: predicate, sort: sortDescriptors)
    }
    
    var body: some View {
        if patients.isEmpty {
            emptyStateView
        } else {
            List(patients) { patient in
                content(patient)
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets(top: Spacing.xs, leading: Spacing.medium, bottom: Spacing.xs, trailing: Spacing.medium))
            }
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: Spacing.large) {
            Circle()
                .fill(Color.healthPrimary.opacity(0.1))
                .frame(width: 80, height: 80)
                .overlay(
                    Image(systemName: searchText.isEmpty ? "person.3" : "magnifyingglass")
                        .font(.system(size: 36, weight: .medium))
                        .foregroundStyle(Color.healthPrimary)
                )
            
            VStack(spacing: Spacing.xs) {
                Text(searchText.isEmpty ? "No Patients Yet" : "No Results Found")
                    .font(.title2.weight(.semibold))
                    .foregroundStyle(.primary)
                
                Text(searchText.isEmpty ? 
                     "Add your first patient to get started with healthcare management." :
                     "Try adjusting your search terms or check the spelling.")
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, Spacing.xl)
            }
            
            if searchText.isEmpty {
                DSButton("Add First Patient", style: .primary, icon: "plus") {
                    showCreatePatient = true
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .cardStyle()
        .padding(Spacing.medium)
    }
}

struct PatientsListView_Previews: PreviewProvider {
    static var previews: some View {
        TabView {
            NavigationView {
                PatientsListView()
            }
        }
    }
}
