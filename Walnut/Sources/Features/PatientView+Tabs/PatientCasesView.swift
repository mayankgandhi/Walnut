//
//  PatientCasesView.swift
//  Walnut-Playground
//
//  Created by Mayank Gandhi on 30/06/25.
//  Copyright © 2025 m. All rights reserved.
//

import SwiftUI

struct PatientCasesView: View {
        
    var body: some View {
        MedicalCasesView(medicalCases: MedicalCase.sampleCases)
            .navigationTitle(Text("Patient Cases"))
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Create", systemImage: "plus") {
                        print("Create Button Tapped")
                    }
                }
            }
    }
}


struct PatientCasesView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            PatientCasesView()
        }
    }
}



