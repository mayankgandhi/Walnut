//
//  PatientHomeView.swift
//  Walnut-Playground
//
//  Created by Mayank Gandhi on 30/06/25.
//  Copyright © 2025 m. All rights reserved.
//

import SwiftUI
import SwiftData

struct PatientHomeView: View {
    
    let patient: Patient
    @Environment(\.modelContext) private var modelContext
    @State private var showAllMedications = false
    
    init(patient: Patient) {
        self.patient = patient
    }
    
    var body: some View {
        List {
            UpcomingMedicationsSection(patient: patient)
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showAllMedications = true
                } label: {
                    Text("View All")
                        .font(.system(size: 16, weight: .medium))
                }
            }
        }
        .navigationDestination(isPresented: $showAllMedications) {
            AllMedicationsView(patient: patient)
        }
    }
}



struct PatientHomeView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            PatientHomeView(patient: Patient.samplePatient)
        }
    }
}
