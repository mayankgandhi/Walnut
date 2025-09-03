//
//  AddDocumentsButton.swift
//  Walnut
//
//  Created by Mayank Gandhi on 03/09/25.
//  Copyright © 2025 m. All rights reserved.
//

import SwiftUI
import WalnutDesignSystem
import SwiftData

struct AddDocumentsButton: View {
    
    @Environment(\.modelContext) var modelContext
    let medicalCase: MedicalCase
    @State private var store: DocumentPickerStore
    @State private var processingService: DocumentProcessingService
    @State private var viewModel: AddDocumentsButtonViewModel
    
    init(
        modelContext: ModelContext,
        medicalCase: MedicalCase,
        viewModel: AddDocumentsButtonViewModel = .init()
    ) {
        self.medicalCase = medicalCase
        self._store = State(initialValue: DocumentPickerStore())
        self.processingService = DocumentProcessingService.createWithAIKit(
            modelContext: modelContext
        )
        self.viewModel = viewModel
    }
    
    var body: some View {
        Button(action: {
            store.resetState()
            viewModel.showHealthRecordSelector = true
        }) {
            Image(systemName: "plus")
                .font(.system(.headline, design: .rounded, weight: .black))
        }
        .padding(Spacing.xs)
        .background(Color.secondary)
        .foregroundColor(.white)
        .clipShape(Circle())
        .sheet(
            isPresented: $viewModel.showHealthRecordSelector,
            onDismiss: {
                viewModel.showHealthRecordSelector = false
            },
            content: {
                HealthRecordSelectorBottomSheet(
                    medicalCase: medicalCase,
                    store: store,
                    showModularDocumentPicker: $viewModel.showModularDocumentPicker
                )
            }
        )
        .sheet(
            isPresented: $viewModel.showModularDocumentPicker,
            onDismiss: {
                viewModel.showModularDocumentPicker = false
            },
            content: {
                ModularDocumentPickerView(
                    medicalCase: medicalCase,
                    store: store,
                    processingService: processingService
                )
                .presentationCornerRadius(Spacing.large)
                .presentationDetents([.medium])
            }
        )
    }
}

#Preview("Add Documents Button") {
    let schema = Schema([
        Patient.self,
        MedicalCase.self,
        Prescription.self,
        BloodReport.self,
        Document.self
    ])
    let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: schema, configurations: [modelConfiguration])
    
    VStack(spacing: 20) {
        Text("Add Documents Button")
            .font(.title2)
        
        AddDocumentsButton(
            modelContext: container.mainContext,
            medicalCase: .sampleCase
        )
        
        Spacer()
    }
    .padding()
    .modelContainer(container)
}
