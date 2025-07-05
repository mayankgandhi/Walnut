//
//  PatientHomeView.swift
//  Walnut-Playground
//
//  Created by Mayank Gandhi on 30/06/25.
//  Copyright © 2025 m. All rights reserved.
//

import SwiftUI

struct PatientHomeView: View {
    
    let patient: Patient
    
    init(patient: Patient) {
        self.patient =  patient
    }
    
    var body: some View {
        NavigationStack {
            List {
                PatientHeaderCard(patient: patient)
            }
            .navigationTitle("Home")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Edit", systemImage: "ellipsis") {
                        print("Edit Button Tapped")
                    }
                }
            }
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



