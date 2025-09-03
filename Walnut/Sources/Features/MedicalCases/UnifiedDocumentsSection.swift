//
//  UnifiedDocumentsSection.swift
//  Walnut
//
//  Created by Mayank Gandhi on 22/08/25.
//  Copyright © 2025 m. All rights reserved.
//

import SwiftUI
import WalnutDesignSystem
import SwiftData

struct UnifiedDocumentsSection: View {
    
    private var modelContext: ModelContext
    let medicalCase: MedicalCase
    @State private var store: DocumentPickerStore
    @State private var processingService: DocumentProcessingService
   
    @State private var viewModel = UnifiedDocumentsSectionViewModel()
    
    init(
        modelContext: ModelContext,
        medicalCase: MedicalCase,
        viewModel: UnifiedDocumentsSectionViewModel = UnifiedDocumentsSectionViewModel()
    ) {
        self.modelContext = modelContext
        self.medicalCase = medicalCase
        self._store = State(initialValue: DocumentPickerStore())
        self.processingService = DocumentProcessingService.createWithAIKit(
            modelContext: modelContext
        )
        self.viewModel = viewModel
    }
    
    var body: some View {
        VStack(
            alignment: .leading,
            spacing: Spacing.medium
        ) {
            
            HealthCardHeader.medicalDocuments(
                count: viewModel.totalDocumentCount,
                onAddTap: {
                    store.resetState()
                    viewModel.showAddDocumentSheet()
                }
            )
            
            Group {
                if viewModel.isLoading {
                    loadingView
                        .transition(.opacity)
                } else if viewModel.isEmpty {
                    emptyStateView
                        .transition(.opacity.combined(with: .scale(scale: 0.95)))
                } else {
                    documentsListView
                        .transition(.opacity.combined(with: .move(edge: .top)))
                }
            }
            .animation(.easeInOut(duration: 0.3), value: viewModel.isLoading)
            .animation(.easeInOut(duration: 0.3), value: viewModel.isEmpty)
        }
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
        .navigationDestination(item: $viewModel.navigationState.selectedPrescription) { prescription in
            PrescriptionDetailView(prescription: prescription)
        }
        .navigationDestination(item: $viewModel.navigationState.selectedBloodReport) { bloodReport in
            BloodReportDetailView(bloodReport: bloodReport)
        }
        .navigationDestination(item: $viewModel.navigationState.selectedDocument) { document in
            DocumentViewer(document: document)
        }
        .task {
            viewModel.loadDocuments(from: medicalCase)
        }
        .refreshable {
            await viewModel.refresh(from: medicalCase)
        }
    }
    
    // MARK: - View Components
    
    private var loadingView: some View {
        VStack(spacing: Spacing.medium) {
            ProgressView()
                .scaleEffect(1.2)
            
            Text("Loading documents...")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, Spacing.xl)
    }
    
    private var emptyStateView: some View {
        VStack(alignment: .center, spacing: Spacing.large) {
            ZStack {
                Circle()
                    .fill(Color.healthPrimary.opacity(0.1))
                    .frame(width: 80, height: 80)
                
                Image(systemName: "doc.badge.plus")
                    .font(.system(size: 32, weight: .light))
                    .foregroundStyle(Color.healthPrimary.opacity(0.6))
            }
            
            VStack(alignment: .center, spacing: Spacing.small) {
                Text("No documents yet")
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(.primary)
                
                Text("Add medical documents to track prescriptions, lab results, and more")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(nil)
            }
            
            Button {
                viewModel.showAddDocumentSheet()
            } label: {
                Text("Add First Document")
                    .font(.body)
                    .foregroundStyle(.primary)
            }
            .buttonStyle(.borderedProminent)
            .tint(Color.healthPrimary)
            .controlSize(.large)
        }
        .padding(.vertical, Spacing.xl)
    }
    
    private var documentsListView: some View {
        LazyVStack(alignment: .center, spacing: Spacing.small) {
            ForEach(viewModel.allDocuments, id: \.id) { item in
                DocumentRowView(item: item, viewModel: viewModel)
                    .transition(.asymmetric(
                        insertion: .move(edge: .top).combined(with: .opacity),
                        removal: .move(edge: .trailing).combined(with: .opacity)
                    ))
            }
        }
    }
    
}

