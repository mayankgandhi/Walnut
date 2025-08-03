//
//  PrescriptionDetailView.swift
//  Walnut
//
//  Created by Mayank Gandhi on 12/07/25.
//  Copyright © 2025 m. All rights reserved.
//

import SwiftUI

struct PrescriptionDetailView: View {
    
    let prescription: Prescription
    
    @Environment(\.dismiss) private var dismiss
    @State private var showingMedicationEditor = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 20) {
                    // Header Card
                    PrescriptionHeaderCard(prescription: prescription)
                    
                    // Medications Card
                    if !prescription.medications.isEmpty {
                        PrescriptionMedicationsCard(medications: prescription.medications)
                    }
                    
                    // Follow-up Card
                    if prescription.followUpDate != nil || !(prescription.followUpTests?.isEmpty ?? false) {
                        PrescriptionFollowUpCard(prescription: prescription)
                    }
                    
                    // Notes Card
                    if let notesCard = PrescriptionNotesCard(prescription: prescription) {
                        notesCard
                    }
                    
                    // Document Card
                    if let documentCard = PrescriptionDocumentCard(prescription: prescription, onViewDocument: handleDocumentView) {
                        documentCard
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Prescription Details")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .fontWeight(.medium)
                }
            }
            .sheet(isPresented: $showingMedicationEditor) {
                PrescriptionMedicationEditor(prescription: prescription)
            }
        }
    }
    
    // MARK: - Actions
    private func handleDocumentView() {
        // Handle document viewing logic here
        // This could be showing a document viewer, sharing, etc.
    }
}
