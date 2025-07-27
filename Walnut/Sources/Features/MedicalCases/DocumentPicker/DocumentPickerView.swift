//
//  DocumentPickerView.swift
//  Walnut-Playground
//
//  Created by Mayank Gandhi on 02/07/25.
//  Copyright © 2025 m. All rights reserved.
//

import SwiftUI
import PDFKit
import UniformTypeIdentifiers
import PhotosUI

// MARK: - Legacy DocumentPickerView (Backward Compatibility)
// This view maintains the existing API while using the new modular architecture internally

struct DocumentPickerView: View {
    
    let medicalCase: MedicalCase
    @State private var store: DocumentPickerStore
    @State private var processingService: DocumentProcessingService?
    
    init(medicalCase: MedicalCase) {
        self.medicalCase = medicalCase
        // Initialize with prescription-only configuration for backward compatibility
        self._store = State(initialValue: DocumentPickerStore.forPrescriptions())
    }
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    var body: some View {
        VStack {
            if let processingService = processingService {
                // Use the new modular implementation
                ModularDocumentPickerView(medicalCase: medicalCase, store: store)
                    .environment(processingService)
            } else {
                // Loading state while initializing processing service
                ProgressView("Initializing...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .task {
            // Initialize the processing service
            if processingService == nil {
                // Get API key from environment or configuration
                let apiKey = claudeKey // Assuming this exists
                let claudeService = ClaudeFilesService(apiKey: apiKey)
                processingService = DocumentProcessingService(
                    claudeService: claudeService,
                    modelContext: modelContext
                )
            }
        }
    }
}
