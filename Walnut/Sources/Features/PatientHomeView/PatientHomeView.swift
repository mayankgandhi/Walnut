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
    
    @Binding var patient: Patient?
    @Environment(\.modelContext) private var modelContext
    
    init(patient: Binding<Patient?>) {
        self._patient =  patient
    }
    
    var body: some View {
        List {
            if let patient {
                PatientHeaderCard(patient: patient)
                
                UpcomingMedicationsSection(patient: patient)
                
                ActiveMedicationsSection(patient: patient)
            } else {
                ContentUnavailableView(
                    "Select a Patient",
                    systemImage: "person.crop.circle.badge.xmark",
                    description: Text("Please select a patient by tapping on the menu botton at the top left corner of the screen.")
                )
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button("Menu", systemImage: "person.3.sequence") {
                    withAnimation {
                        self.patient = nil
                    }
                }
            }
        }
    }
}



struct PatientHomeView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            PatientHomeView(patient: .constant(Patient.samplePatient))
        }
    }
}
