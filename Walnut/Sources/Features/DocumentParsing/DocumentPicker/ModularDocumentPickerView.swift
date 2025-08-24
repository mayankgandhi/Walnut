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

struct ModularDocumentPickerView: View {
    
    // MARK: - Configuration
    
    let medicalCase: MedicalCase
    let allowedDocumentTypes: [DocumentType]
    
    // MARK: - Environment
    
    @Environment(\.dismiss) private var dismiss
    private var modelContext: ModelContext
    
    // MARK: - State
    
    @State private var store: DocumentPickerStore
    @State private var processingService: DocumentProcessingService
    @State private var showingProcessingStatus = false
    
    // MARK: - Initialization
    
    init(
        medicalCase: MedicalCase,
        allowedDocumentTypes: [DocumentType] = DocumentType.allCases,
        modelContext: ModelContext
    ) {
        self.medicalCase = medicalCase
        self.allowedDocumentTypes = allowedDocumentTypes
        self.modelContext = modelContext
        
        self._store = State(initialValue: DocumentPickerStore(
            documentTypes: allowedDocumentTypes,
            defaultDocumentType: allowedDocumentTypes.first ?? .prescription
        ))
        self.processingService = DocumentProcessingService.createWithAIKit(
            modelContext: modelContext
        )
    }
    
    // MARK: - Body
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                // Document Type Selection
                DocumentTypeSelector()
                    .environment(store)
                    .padding(.horizontal)
                
                if showingProcessingStatus {
                    DocumentProcessingStatusView(
                        isProcessing: $store.isProcessing,
                        processingProgress: $processingService.processingProgress,
                        processingStatus: $processingService.processingStatus,
                        lastError: $processingService.lastError
                    )
                } else if store.selectedDocumentType != nil {
                    // Document Source Picker
                    DocumentSourcePicker()
                        .environment(store)
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
                    if store.canUpload &&
                        !processingService.isProcessing &&
                        store.selectedDocumentType != nil {
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
        showingProcessingStatus = true
        processingService
            .processDocument(
                from: store,
                for: medicalCase,
                selectedDocumentType: store.selectedDocumentType!
            ) { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    showingProcessingStatus = false
                    dismiss()
                case .failure(let error):
                    store.errorMessage = error.localizedDescription
                    showingProcessingStatus = false
                }
            }
        }
    }
}
