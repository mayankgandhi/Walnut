//
//  PatientTabView.swift
//  Walnut
//
//  Created by Mayank Gandhi on 11/08/25.
//  Copyright © 2025 m. All rights reserved.
//

import SwiftUI
import WalnutDesignSystem

struct PatientTabView: View {
    let patient: Patient
    
    var body: some View {
        TabView {
            Tab("Medications", systemImage: "pills.fill") {
                NavigationStack {
                    MedicationsTrackerView(patient: patient)
                }
            }
            
            Tab("Cases", systemImage: "document.on.document") {
                NavigationStack {
                    MedicalCasesView(patient: patient)
                }
            }
            
            Tab("Blood Tests", systemImage: "testtube.2") {
                NavigationStack {
                    BloodTestsView(patient: patient)
                }
            }
            
            Tab("Settings", systemImage: "gear") {
                NavigationStack {
                    PatientSettingsView(patient: patient)
                }
            }
        }
        .navigationTitle(patient.name ?? "")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        PatientTabView(patient: .samplePatient)
    }
}
