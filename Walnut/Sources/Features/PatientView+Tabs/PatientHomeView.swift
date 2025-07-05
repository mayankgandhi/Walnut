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
        List {
            PatientHeaderCard(patient: patient)
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



