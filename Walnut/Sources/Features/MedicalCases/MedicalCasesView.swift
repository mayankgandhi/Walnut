//
//  Patient+MedicalCasesView.swift
//  Walnut-Playground
//
//  Created by Mayank Gandhi on 29/06/25.
//  Copyright © 2025 m. All rights reserved.
//

import SwiftUI

struct MedicalCasesView: View {
    
    let medicalCases: [MedicalCase]
    @State var medicalCase: MedicalCase? = nil
    
    init(medicalCases: [MedicalCase]) {
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
                documents: Document.documents
            )
        }
    }
    
}

#Preview {
    MedicalCasesView(medicalCases: MedicalCase.sampleCases)
}

