//
//  MedicalCaseDetailView 2.swift
//  Walnut-Playground
//
//  Created by Mayank Gandhi on 02/07/25.
//  Copyright © 2025 m. All rights reserved.
//

import SwiftUI

struct MedicalCaseDetailView: View {
    let medicalCase: MedicalCase
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header Card
                MedicalCaseHeaderCard(medicalCase: medicalCase)
                    .padding(.horizontal)
                
                DocumentsSection(
                    medicalCase: medicalCase
                )
                
                BloodReportsSection(
                    medicalCase: medicalCase
                )
                
                // Show unparsed documents only if there are any
                if !medicalCase.unparsedDocuments.isEmpty {
                    UnparsedDocumentsSection(
                        medicalCase: medicalCase
                    )
                }

            }
            .padding(.vertical)
        }
        .background(Color(UIColor.systemGroupedBackground))
        .navigationBarTitleDisplayMode(.inline)
    }
}


#Preview(body: {
    MedicalCaseDetailView(
        medicalCase: MedicalCase.sampleCase
    )
})
