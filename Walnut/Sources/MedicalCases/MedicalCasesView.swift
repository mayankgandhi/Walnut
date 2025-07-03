//
//  Patient+MedicalCasesView.swift
//  Walnut-Playground
//
//  Created by Mayank Gandhi on 29/06/25.
//  Copyright © 2025 m. All rights reserved.
//

import SwiftUI

struct MedicalCasesView: View {
    
    let medicalCases: [MedicalCaseData]
    @State var medicalCase: MedicalCaseData? = nil
    
    init(medicalCases: [MedicalCaseData]) {
        self.medicalCases = medicalCases
    }
    
    var body: some View {
        List {
            ForEach(medicalCases) { medicalCase in
                Button {
                    self.medicalCase = medicalCase
                } label: {
                    MedicalCaseListItem(medicalCase: medicalCase)
                }
            }
        }
        .navigationTitle("Medical Cases")
        .navigationDestination(item: $medicalCase) { medicalCase in
            MedicalCaseDetailView(
                medicalCase: medicalCase,
                documents: DocumentData.documents
            )
        }
    }
    
}

#Preview {
    MedicalCasesView(medicalCases: MedicalCaseData.sampleCases)
}

