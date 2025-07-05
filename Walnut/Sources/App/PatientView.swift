//
//  ContentView.swift
//  Walnut-Playground
//
//  Created by Mayank Gandhi on 29/06/25.
//  Copyright © 2025 m. All rights reserved.
//

import SwiftUI

struct PatientView: View {
    
    @Binding var selectedPatient: Patient?
    
    var body: some View {
        if let selectedPatient {
            TabView {
                Tab("Home", systemImage: "person.crop.circle.fill") {
                    NavigationStack {
                        PatientHomeView(patient: selectedPatient)
                            .toolbar {
                                ToolbarItem(placement: .topBarLeading) {
                                    Button("Menu", systemImage: "person.3.sequence") {
                                        withAnimation {
                                            self.selectedPatient = nil
                                        }
                                    }
                                }
                            }
                    }
                }
                
                Tab("Cases", systemImage: "document.on.document") {
                    NavigationStack {
                        MedicalCasesView(medicalCases: MedicalCase.sampleCases)
                    }
                }
                
                Tab("Tests", systemImage: "testtube.2") {
                    NavigationStack {
                        TestResultListView()
                    }
                }
            }
        } else {
            ContentUnavailableView(
                "Select a Patient",
                systemImage: "person.crop.circle.badge.xmark",
                description: Text("Please select a patient by tapping on the menu botton at the top left corner of the screen.")
            )
        }
        
    }
}


struct PatientView_Previews: PreviewProvider {
    static var previews: some View {
        PatientView(selectedPatient: .constant(Patient.samplePatient))
    }
}
