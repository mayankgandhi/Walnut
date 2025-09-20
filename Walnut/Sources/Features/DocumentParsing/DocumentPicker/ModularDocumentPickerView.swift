//
//  ModularDocumentPickerView.swift
//  Walnut
//
//  Created by Mayank Gandhi on 29/07/25.
//  Copyright © 2025 m. All rights reserved.
//

import SwiftUI
import SwiftData
import AIKit
import WalnutDesignSystem

struct ModularDocumentPickerView: View {

    // MARK: - Configuration
    let patient: Patient
    let medicalCase: MedicalCase?

    // MARK: - Environment
    @Environment(\.dismiss) private var dismiss
    @State private var store: DocumentPickerStore
    // MARK: - State

    init(
        patient: Patient,
        medicalCase: MedicalCase? = nil,
        store: DocumentPickerStore
    ) {
        self.patient = patient
        self.medicalCase = medicalCase
        self.store = store
    }
    
    // MARK: - Body
    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: Spacing.large) {
                
                if store.selectedDocumentType != nil {
                    // Document Source Picker
                    DocumentSourcePicker(patient: patient, medicalCase: medicalCase, store: store)
                        .padding(.horizontal)
                    
                    // Clear selection button
                    if store.hasSelection {
                        Button("Clear Selection") {
                            store.clearSelection()
                        }
                        .font(.subheadline)
                        .foregroundColor(.red)
                        .padding(.horizontal)
                    }
                    
                    // Error message
                    if let errorMessage = store.errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .padding(.horizontal)
                    }
                    
                    // Upload button
                    if store.canUpload && store.selectedDocumentType != nil {
                        Button("Upload \(store.selectedDocument != nil ? "Document" : "Image")") {
                            processDocument()
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color.blue)
                        .cornerRadius(12)
                        .padding(.horizontal)
                    }
                }
            }
            .frame(maxHeight: .infinity, alignment: .top)
            .navigationTitle("Add Document")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Cancel", systemImage: "xmark.circle.fill") {
                        dismiss()
                    }
                }
            }
        }
        
    }
    
    // MARK: - Actions
    
    private func processDocument() {
        guard let documentType = store.selectedDocumentType else { return }
        
        // Start document processing through the upload state manager
        DocumentUploadStateManager.shared.processDocument(
            from: store,
            for: medicalCase,
            patient: patient,
            selectedDocumentType: documentType
        )
        
        // Dismiss picker immediately after starting upload
        dismiss()
    }
}

