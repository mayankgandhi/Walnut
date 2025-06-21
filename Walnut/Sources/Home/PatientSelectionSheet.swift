//
//  PatientSelectionSheet.swift
//  Walnut
//
//  Created by Mayank Gandhi on 19/06/25.
//  Copyright © 2025 m. All rights reserved.
//

import SwiftUI
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
    
    var body: some View {
        Picker(selection: $selectedPatient) {
            HStack(spacing: 6) {
                Image(systemName: "person.circle")
                    .font(.system(size: 14, weight: .semibold))
                Text("Patient")
                    .font(.system(size: 14, weight: .semibold))
            }
            .tag(nil as Patient?)
            
            ForEach(patients, id: \.id) { patient in
                HStack(spacing: 6) {
                    Image(systemName: "person.circle.fill")
                        .font(.system(size: 14, weight: .semibold))
                    Text(patient.fullName)
                        .font(.system(size: 14, weight: .semibold))
                        .lineLimit(1)
                }
                .tag(patient as Patient?)
            }
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
        .pickerStyle(.menu)
    }
}
