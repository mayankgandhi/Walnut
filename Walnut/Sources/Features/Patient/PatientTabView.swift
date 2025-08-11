//
//  PatientTabView.swift
//  Walnut
//
//  Created by Mayank Gandhi on 11/08/25.
//  Copyright © 2025 m. All rights reserved.
//

import SwiftUI

struct PatientTabView: View {
    let patient: Patient
    
    var body: some View {
        TabView {
            Tab("Home", systemImage: "person.crop.circle.fill") {
                NavigationStack {
                    PatientHomeView(patient: patient)
                        .navigationTitle("Home")
                }
            }
            
            Tab("Cases", systemImage: "document.on.document") {
                NavigationStack {
                    MedicalCasesView(patient: patient)
                }
            }
            
//            Tab("Blood Tests", systemImage: "testtube.2") {
//                NavigationStack {
//                    BloodTestsView(patient: patient)
//                }
//            }
        }
        .navigationTitle(patient.fullName)
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        PatientTabView(patient: .samplePatient)
    }
}