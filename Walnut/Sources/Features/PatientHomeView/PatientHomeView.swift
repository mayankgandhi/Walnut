//
//  MedicationsTrackerView.swift
//  Walnut-Playground
//
//  Created by Mayank Gandhi on 30/06/25.
//  Copyright © 2025 m. All rights reserved.
//

import SwiftUI
import SwiftData

struct MedicationsTrackerView: View {
    
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
            ActiveMedicationsSection(patient: patient)
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
