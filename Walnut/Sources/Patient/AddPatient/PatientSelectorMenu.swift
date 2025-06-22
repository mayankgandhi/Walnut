//
//  PatientSelectorMenu.swift
//  Walnut
//
//  Created by Mayank Gandhi on 19/06/25.
//  Copyright © 2025 m. All rights reserved.
//

import SwiftUI

struct PatientSelectorMenu: View {
    @State var selectedPatient: Patient?
    let patients: [Patient]
    let placeholder: String
    var selectedAction: (Patient) -> Void
    
    init(
        selectedPatient: Patient?,
        patients: [Patient],
        placeholder: String = "Select Patient",
        selectedAction: @escaping (Patient) -> Void
    ) {
        self.selectedPatient = selectedPatient
        self.patients = patients
        self.placeholder = placeholder
        self.selectedAction = selectedAction
    }
    
    var body: some View {
        Menu {
            if patients.isEmpty {
                Text("No patients available")
                    .foregroundStyle(Color.textSecondary)
            } else {
                ForEach(patients, id: \.id) { patient in
                    Button {
                        selectedAction(patient)
                    } label: {
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(patient.fullName)
                                    .fontWeight(.medium)
                                
                                if let dateOfBirth = patient.dateOfBirth {
                                    Text("Born \(dateOfBirth, formatter: DateFormatter.mediumStyle)")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                            
                            Spacer()
                            
                            if selectedPatient?.id == patient.id {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.healthBlue)
                                    .font(.system(size: 12, weight: .semibold))
                            }
                        }
                    }
                }
                
                if selectedPatient != nil {
                    Divider()
                    
                    Button("Clear Selection") {
                        selectedPatient = nil
                    }
                }
            }
        } label: {
            HStack(spacing: 6) {
                Image(systemName: "person.circle")
                    .font(.system(size: 14, weight: .semibold))
                
                if let patient = selectedPatient {
                    Text(patient.fullName)
                        .font(.system(size: 14, weight: .semibold))
                        .lineLimit(1)
                } else {
                    Text("Patient")
                        .font(.system(size: 14, weight: .semibold))
                }
                
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
    }
}

// MARK: - Alternative with truncated name for long names
struct PatientSelectorMenuCompact: View {
    @Binding var selectedPatient: Patient?
    let patients: [Patient]
    let placeholder: String
    
    init(
        selectedPatient: Binding<Patient?>,
        patients: [Patient],
        placeholder: String = "Select Patient"
    ) {
        self._selectedPatient = selectedPatient
        self.patients = patients
        self.placeholder = placeholder
    }
    
    private var displayText: String {
        if let patient = selectedPatient {
            let fullName = patient.fullName
            return fullName.count > 12 ? String(fullName.prefix(12)) + "..." : fullName
        }
        return "Patient"
    }
    
    var body: some View {
        Menu {
            if patients.isEmpty {
                Text("No patients available")
                    .foregroundColor(.textSecondary)
            } else {
                ForEach(patients, id: \.id) { patient in
                    Button {
                        selectedPatient = patient
                    } label: {
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(patient.fullName)
                                    .fontWeight(.medium)
                                
                                if let dateOfBirth = patient.dateOfBirth {
                                    Text("Born \(dateOfBirth, formatter: DateFormatter.mediumStyle)")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                            
                            Spacer()
                            
                            if selectedPatient?.id == patient.id {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.healthBlue)
                                    .font(.system(size: 12, weight: .semibold))
                            }
                        }
                    }
                }
                
                if selectedPatient != nil {
                    Divider()
                    
                    Button("Clear Selection") {
                        selectedPatient = nil
                    }
                }
            }
        } label: {
            HStack(spacing: 6) {
                Image(systemName: selectedPatient != nil ? "person.circle.fill" : "person.circle")
                    .font(.system(size: 14, weight: .semibold))
                
                Text(displayText)
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
    }
}

// MARK: - Patient Extensions
extension Patient {
    var fullName: String {
        let first = firstName ?? ""
        let last = lastName ?? ""
        return "\(first) \(last)".trimmingCharacters(in: .whitespaces)
    }
}
