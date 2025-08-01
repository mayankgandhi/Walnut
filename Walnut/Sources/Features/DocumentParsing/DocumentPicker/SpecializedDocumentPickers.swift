//
//  SpecializedDocumentPickers.swift
//  Walnut
//
//  Created by Mayank Gandhi on 29/07/25.
//  Copyright © 2025 m. All rights reserved.
//

import SwiftUI
import SwiftData

// MARK: - Specialized Document Picker Views

/// Specialized document picker for prescription documents only
struct PrescriptionDocumentPicker: View {
    
    let medicalCase: MedicalCase
    @State private var store = DocumentPickerStore.forPrescriptions()
    @State private var processingService: DocumentProcessingService?
    
    @Environment(\.modelContext) private var modelContext
    
    var body: some View {
        Group {
            if let processingService = processingService {
                ModularDocumentPickerView(medicalCase: medicalCase, store: store)
                    .environment(processingService)
            } else {
                ProgressView("Initializing...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .task {
            if processingService == nil {
                let apiKey = claudeKey
                let claudeService = ClaudeDocumentService(apiKey: apiKey)
                processingService = DocumentProcessingService.create(
                    claudeService: claudeService,
                    modelContext: modelContext
                )
            }
        }
    }
}

/// Specialized document picker for blood report documents only
struct BloodReportDocumentPicker: View {
    
    let medicalCase: MedicalCase
    @State private var store = DocumentPickerStore.forBloodReports()
    @State private var processingService: DocumentProcessingService?
    
    @Environment(\.modelContext) private var modelContext
    
    var body: some View {
        Group {
            if let processingService = processingService {
                ModularDocumentPickerView(medicalCase: medicalCase, store: store)
                    .environment(processingService)
            } else {
                ProgressView("Initializing...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .task {
            if processingService == nil {
                let apiKey = claudeKey
                let claudeService = ClaudeDocumentService(apiKey: apiKey)
                processingService = DocumentProcessingService.create(
                    claudeService: claudeService,
                    modelContext: modelContext
                )
            }
        }
    }
}

/// General document picker that supports all document types
struct GeneralDocumentPicker: View {
    
    let medicalCase: MedicalCase
    let allowedDocumentTypes: [DocumentType]
    
    @State private var store: DocumentPickerStore
    @State private var processingService: DocumentProcessingService?
    
    @Environment(\.modelContext) private var modelContext
    
    init(medicalCase: MedicalCase, allowedDocumentTypes: [DocumentType] = DocumentType.allCases) {
        self.medicalCase = medicalCase
        self.allowedDocumentTypes = allowedDocumentTypes
        
        self._store = State(initialValue: DocumentPickerStore(
            documentTypes: allowedDocumentTypes,
            defaultDocumentType: allowedDocumentTypes.first ?? .prescription
        ))
    }
    
    var body: some View {
        Group {
            if let processingService = processingService {
                ModularDocumentPickerView(medicalCase: medicalCase, store: store)
                    .environment(processingService)
            } else {
                ProgressView("Initializing...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .task {
            if processingService == nil {
                let apiKey = claudeKey
                let claudeService = ClaudeDocumentService(apiKey: apiKey)
                processingService = DocumentProcessingService.create(
                    claudeService: claudeService,
                    modelContext: modelContext
                )
            }
        }
    }
}

// MARK: - Convenience Extensions

extension View {
    
    /// Present a prescription document picker sheet
    func prescriptionDocumentPicker(
        for medicalCase: MedicalCase,
        isPresented: Binding<Bool>
    ) -> some View {
        self.sheet(isPresented: isPresented) {
            PrescriptionDocumentPicker(medicalCase: medicalCase)
        }
    }
    
    /// Present a blood report document picker sheet
    func bloodReportDocumentPicker(
        for medicalCase: MedicalCase,
        isPresented: Binding<Bool>
    ) -> some View {
        self.sheet(isPresented: isPresented) {
            BloodReportDocumentPicker(medicalCase: medicalCase)
        }
    }
    
    /// Present a general document picker sheet
    func generalDocumentPicker(
        for medicalCase: MedicalCase,
        allowedTypes: [DocumentType] = DocumentType.allCases,
        isPresented: Binding<Bool>
    ) -> some View {
        self.sheet(isPresented: isPresented) {
            GeneralDocumentPicker(medicalCase: medicalCase, allowedDocumentTypes: allowedTypes)
        }
    }
}

// MARK: - Preview

#Preview("Prescription Picker") {
    PrescriptionDocumentPicker(medicalCase: MedicalCase.sampleCase)
}

#Preview("Blood Report Picker") {
    BloodReportDocumentPicker(medicalCase: MedicalCase.sampleCase)
}

#Preview("General Picker") {
    GeneralDocumentPicker(medicalCase: MedicalCase.sampleCase)
}
