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
    
    init(patient: Patient) {
        self.patient = patient
    }
    
    var body: some View {
        AllMedicationsView(patient: patient)
    }
}



#Preview {
    NavigationStack {
        MedicationsTrackerView(patient: .samplePatient)
    }
    .modelContainer(for: Patient.self, inMemory: true)
}
