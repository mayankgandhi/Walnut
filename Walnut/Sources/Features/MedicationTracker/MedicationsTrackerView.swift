//
//  MedicationsTrackerView.swift
//  Walnut-Playground
//
//  Created by Mayank Gandhi on 30/06/25.
//  Copyright © 2025 m. All rights reserved.
//

import SwiftUI
import SwiftData
import WalnutDesignSystem

struct MedicationsTrackerView: View {
    
    let patient: Patient
    @Environment(\.modelContext) private var modelContext
    @State private var showSettings = false
    
    init(patient: Patient) {
        self.patient = patient
    }
    
    var body: some View {
        ScrollView {
            PatientHeaderCard(patient: patient)
            
            UpcomingMedicationsSection(patient: patient)
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showSettings = true
                } label: {
                    Image(systemName: "gear.circle.fill")
                        .foregroundStyle(Color.healthPrimary)
                }
            }
        }
        .navigationDestination(isPresented: $showSettings) {
            PatientSettingsView(patient: patient)
        }
    }
}



struct MedicationsTrackerView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            MedicationsTrackerView(patient: Patient.samplePatient)
        }
    }
}
