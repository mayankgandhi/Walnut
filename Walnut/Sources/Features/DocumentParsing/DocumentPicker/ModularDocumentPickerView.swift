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
    @Environment(\.modelContext) private var modelContext
    
    // MARK: - State
    
    @State private var store: DocumentPickerStore
    @State private var processingService: DocumentProcessingService?
    @State private var showingProcessingStatus = false
    
    // MARK: - Initialization
    
    init(medicalCase: MedicalCase, allowedDocumentTypes: [DocumentType] = DocumentType.allCases) {
        self.medicalCase = medicalCase
        self.allowedDocumentTypes = allowedDocumentTypes
        
        self._store = State(initialValue: DocumentPickerStore(
            documentTypes: allowedDocumentTypes,
            defaultDocumentType: allowedDocumentTypes.first ?? .prescription
        ))
    }
    
    // MARK: - Body
    
    var body: some View {
        NavigationView {
            Group {
                if let processingService = processingService {
                    VStack(spacing: 24) {
                        // Document Type Selection
                        DocumentTypeSelector()
                            .environment(store)
                            .padding(.horizontal)
                        
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
                        if store.canUpload && !processingService.isProcessing {
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
                        
                        Spacer()
                    }
                    .environment(processingService)
                } else {
                    ProgressView("Initializing...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .navigationTitle("Add Document")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showingProcessingStatus) {
                if let processingService = processingService {
                    DocumentProcessingStatusView()
                        .environment(processingService)
                }
            }
        }
        .task {
            if processingService == nil {
                processingService = DocumentProcessingService.createWithAIKit(
                    modelContext: modelContext
                )
            }
        }
    }
    
    // MARK: - Actions
    
    private func processDocument() {
        guard let processingService = processingService else { return }
        
        showingProcessingStatus = true
        
        processingService.processDocument(from: store, for: medicalCase) { result in
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

// MARK: - Processing Status View

private struct DocumentProcessingStatusView: View {
    
    @Environment(DocumentProcessingService.self) private var service
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                Spacer()
                
                // Progress indicator
                VStack(spacing: 16) {
                    ProgressView(value: service.processingProgress)
                        .progressViewStyle(LinearProgressViewStyle())
                        .frame(maxWidth: 200)
                    
                    Text(service.processingStatus)
                        .font(.headline)
                        .multilineTextAlignment(.center)
                    
                    if service.isProcessing {
                        Text("Please wait while we process your document...")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                }
                
                Spacer()
                
                // Error handling
                if let error = service.lastError {
                    VStack(spacing: 12) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.largeTitle)
                            .foregroundColor(.red)
                        
                        Text("Processing Failed")
                            .font(.headline)
                        
                        Text(error.localizedDescription)
                            .font(.subheadline)
                            .multilineTextAlignment(.center)
                            .foregroundColor(.secondary)
                        
                        Button("Dismiss") {
                            dismiss()
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .padding()
                } else if service.processingProgress >= 1.0 && !service.isProcessing {
                    VStack(spacing: 12) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.largeTitle)
                            .foregroundColor(.green)
                        
                        Text("Document Processed Successfully")
                            .font(.headline)
                        
                        Button("Done") {
                            dismiss()
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .padding()
                }
            }
            .padding()
            .navigationTitle("Processing Document")
            .navigationBarTitleDisplayMode(.inline)
            .interactiveDismissDisabled(service.isProcessing)
        }
    }
}

// MARK: - Convenience Extensions

extension View {
    
    /// Present a unified document picker sheet
    func documentPicker(
        for medicalCase: MedicalCase,
        allowedTypes: [DocumentType] = DocumentType.allCases,
        isPresented: Binding<Bool>
    ) -> some View {
        self.sheet(isPresented: isPresented) {
            ModularDocumentPickerView(medicalCase: medicalCase, allowedDocumentTypes: allowedTypes)
        }
    }
}

