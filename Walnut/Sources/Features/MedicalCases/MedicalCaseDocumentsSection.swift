//
//  Document.swift
//  Walnut-Playground
//
//  Created by Mayank Gandhi on 02/07/25.
//  Copyright © 2025 m. All rights reserved.
//

import SwiftUI
import PDFKit
import SwiftUI
import PDFKit

// MARK: - Documents Section
struct DocumentsSection: View {
    
    @State var selectedPrescription: Prescription?
    let medicalCase: MedicalCase
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Section Header
            DocumentsSectionHeader(
                medicalCase: medicalCase,
                documentCount: medicalCase.prescriptions.count
            )
            
            // List
            LazyVStack(spacing: 12) {
                ForEach(medicalCase.prescriptions) { prescription in
                    PrescriptionListItem(prescription: prescription)
                        .onTapGesture {
                            selectedPrescription = prescription
                        }
                }
            }
        }
        .padding(.horizontal, 16)
        .navigationDestination(item: $selectedPrescription) { prescription in
            PrescriptionDetailView(prescription: prescription)
        }
    }
}



// MARK: - Section Header
struct DocumentsSectionHeader: View {
    
    let medicalCase: MedicalCase
    let documentCount: Int
    @State private var showAddDocument = false
    
    init(medicalCase: MedicalCase,
         documentCount: Int,
         showAddDocument: Bool = false) {
        self.medicalCase = medicalCase
        self.documentCount = documentCount
        self.showAddDocument = showAddDocument
    }
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 8) {
                    Image(systemName: "doc.text.fill")
                        .font(.title2)
                        .foregroundColor(.blue)

                    Text("Prescriptions")
                        .font(.title2)
                        .fontWeight(.bold)
                }
                
                Text("\(documentCount) documents")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Button {
                showAddDocument = true
            } label: {
                Label("Add Document", systemImage: "doc.badge.plus")
            }
            
        }
        .sheet(isPresented: $showAddDocument) {
            DocumentPickerView(medicalCase: medicalCase)
        }
    }
}
