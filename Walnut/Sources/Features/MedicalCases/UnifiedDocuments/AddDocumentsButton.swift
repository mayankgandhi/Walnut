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
                .font(.system(size: 20, weight: .bold))
        }
        .padding()
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
            }
        )
    }
}



