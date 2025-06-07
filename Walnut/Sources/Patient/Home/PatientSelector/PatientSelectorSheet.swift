//
//  PatientSelectorSheet.swift
//  Walnut
//
//  Created by Mayank Gandhi on 07/06/25.
//  Copyright © 2025 m. All rights reserved.
//

import SwiftUI

// MARK: - Patient Selector Sheet
struct PatientSelectorSheet: View {
    let patients: [Patient]
    let selectedPatient: Patient?
    let onPatientSelected: (Patient) -> Void
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            List {
                ForEach(patients, id: \.id) { patient in
                    PatientRow(
                        patient: patient,
                        isSelected: patient.id == selectedPatient?.id,
                        onTap: {
                            onPatientSelected(patient)
                            dismiss()
                        }
                    )
                }
            }
            .navigationTitle("Select Patient")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}
