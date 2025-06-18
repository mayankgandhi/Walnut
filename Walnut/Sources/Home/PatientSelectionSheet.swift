//
//  PatientSelectionSheet.swift
//  Walnut
//
//  Created by Mayank Gandhi on 19/06/25.
//  Copyright © 2025 m. All rights reserved.
//

import SwiftUI

struct PatientSelector: View {
    @Binding var selectedPatient: Patient?
    let patients: [Patient]
    let placeholder: String
    
    @State private var showingSheet = false
    
    var body: some View {
        Button {
            showingSheet = true
        } label: {
            HStack(spacing: 6) {
                Image(systemName: selectedPatient != nil ? "person.circle.fill" : "person.circle")
                    .font(.system(size: 14, weight: .semibold))
                
                Text(selectedPatient?.fullName ?? "Patient")
                    .font(.system(size: 14, weight: .semibold))
                    .lineLimit(1)
                
                Image(systemName: "chevron.down")
                    .font(.system(size: 10, weight: .semibold))
            }
            .foregroundStyle(.white)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(selectedPatient != nil ? Color.healthGreen : Color.healthBlue)
            )
        }
        .buttonStyle(.plain)
        .sheet(isPresented: $showingSheet) {
            PatientSelectionSheet(
                selectedPatient: $selectedPatient,
                patients: patients,
                onDismiss: { showingSheet = false }
            )
        }
    }
}

struct PatientSelectionSheet: View {
    @Binding var selectedPatient: Patient?
    let patients: [Patient]
    let onDismiss: () -> Void
    
    @State private var searchText = ""
    
    private var filteredPatients: [Patient] {
        if searchText.isEmpty {
            return patients
        }
        return patients.filter { $0.fullName.localizedCaseInsensitiveContains(searchText) }
    }
    
    var body: some View {
        NavigationView {
            List {
                ForEach(filteredPatients, id: \.id) { patient in
                    Button {
                        selectedPatient = patient
                        onDismiss()
                    } label: {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(patient.fullName)
                                    .fontWeight(.medium)
                                    .foregroundColor(.textPrimary)
                                
                                if let dateOfBirth = patient.dateOfBirth {
                                    Text("Born \(dateOfBirth, formatter: DateFormatter.mediumStyle)")
                                        .font(.caption)
                                        .foregroundColor(.textSecondary)
                                }
                            }
                            
                            Spacer()
                            
                            if selectedPatient?.id == patient.id {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.healthBlue)
                                    .font(.system(size: 16, weight: .semibold))
                            }
                        }
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                }
            }
            .searchable(text: $searchText, prompt: "Search patients")
            .navigationTitle("Select Patient")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        onDismiss()
                    }
                }
                
                if selectedPatient != nil {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Clear") {
                            selectedPatient = nil
                            onDismiss()
                        }
                    }
                }
            }
        }
    }
}
