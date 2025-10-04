//
//  BioMarkersView.swift
//  Walnut
//
//  Created by Mayank Gandhi on 28/07/25.
//  Copyright © 2025 m. All rights reserved.
//

import SwiftUI
import SwiftData
import WalnutDesignSystem

struct BioMarkersView: View {
    
    @State private var viewModel: BioMarkersViewModel
    @State private var showDocumentPicker = false
    @State private var documentPickerStore = DocumentPickerStore()
    @State private var showBiomarkerReportsList = false
    
    init(viewModel: BioMarkersViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: Spacing.medium) {
                HStack(spacing: Spacing.small) {
                    
                    NavBarHeader(
                        iconName: "graph",
                        iconColor: .green,
                        title: "Trends",
                        subtitle: "Visualise the latest trends in your health"
                    )
                    
                    Button(action: {
                        showBiomarkerReportsList = true
                    }) {
                        Image(systemName: "document.on.document.fill")
                    }
                    .buttonStyle(.glass)
                    
                    Button(action: {
                        // Pre-configure document picker for lab results
                        documentPickerStore.selectDocumentType(.biomarkerReport)
                        showDocumentPicker = true
                    }) {
                        Image(systemName: "plus")
                    }
                    .buttonStyle(.glass)
                }
                .padding(.trailing, Spacing.medium)
                
                // Search bar
                SearchBar(
                    searchText: Binding(
                        get: { viewModel.searchText },
                        set: { viewModel.updateSearchText($0) }
                    ),
                    placeholder: "Search biomarkers...",
                    onClear: {
                        viewModel.clearSearch()
                    }
                )
                .padding(.bottom, Spacing.small)
                
                if viewModel.isLoading || viewModel.isProcessingData {
                    loadingView
                } else if viewModel.shouldShowEmptyFilteredResults {
                    emptyFilteredResultsView
                } else if viewModel.shouldShowEmptyState {
                    emptyStateView
                } else if viewModel.shouldShowBiomarkersList {
                    biomarkersList
                } else {
                    emptyStateView
                }
            }
            .task {
                viewModel.refreshData()
            }
            .refreshable {
                viewModel.refreshData()
            }
            .background {
                ContentBackgroundView(color: .green)
            }
            .navigationDestination(item: $viewModel.selectedBiomarker) { biomarker in
                BiomarkerDetailView(
                    biomarkerName: biomarker.testName,
                    unit: biomarker.unit.isEmpty ? "N/A" : biomarker.unit,
                    normalRange: biomarker.referenceRange.isEmpty ? "N/A" : biomarker.referenceRange,
                    dataPoints: biomarker.historicalValues,
                    color: biomarker.healthStatusColor
                )
            }
            .navigationDestination(item: $viewModel.selectedBioMarkerReport) { bloodReport in
                BioMarkerReportDetailView(bloodReport: bloodReport)
            }
            .sheet(isPresented: $showDocumentPicker, onDismiss: {
                // Reset document picker store and refresh data
                documentPickerStore.resetState()
                viewModel.refreshData()
            }) {
                ModularDocumentPickerView(
                    patient: viewModel.currentPatient,
                    medicalCase: nil,
                    store: documentPickerStore
                )
            }
            .sheet(isPresented: $showBiomarkerReportsList, onDismiss: {
                // Refresh data when list is dismissed
                viewModel.refreshData()
            }) {
                NavigationStack {
                    BiomarkerReportListView(
                        patient: viewModel.currentPatient,
                        modelContext: viewModel.currentModelContext
                    )
                }
            }
            
        }
    }
    
    
    // MARK: - View Components
    
    private var biomarkersList: some View {
        ScrollView {
            LazyVStack(spacing: Spacing.small) {
                ForEach(viewModel.filteredBiomarkers, id: \.id) { biomarker in
                    BiomarkerListItemView(
                        data: biomarker.historicalValues.map(\.value),
                        color: biomarker.healthStatusColor,
                        biomarkerInfo: BiomarkerInfo(
                            name: biomarker.testName,
                            normalRange: biomarker.referenceRange.isEmpty ? "N/A" : biomarker.referenceRange,
                            unit: biomarker.unit.isEmpty ? "" : biomarker.unit
                        ),
                        biomarkerTrends: BiomarkerTrends(
                            currentValue: biomarker.currentNumericValue,
                            currentValueText: biomarker.currentValue,
                            comparisonText: biomarker.trendText,
                            comparisonPercentage: biomarker.trendPercentage,
                            trendDirection: biomarker.trendDirection,
                            normalRange: biomarker.referenceRange.isEmpty ? "N/A" : biomarker.referenceRange
                        )
                    )
                    .onTapGesture {
                        viewModel.selectBiomarker(biomarker)
                    }
                }
            }
            .padding(.horizontal, Spacing.medium)
            .padding(.top, Spacing.small)
            .padding(.bottom, Spacing.large)
        }
    }
    
    private var loadingView: some View {
        VStack(spacing: Spacing.medium) {
            ProgressView()
                .scaleEffect(1.2)
            
            Text("Processing blood test data...")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var emptyStateView: some View {
        ContentUnavailableView {
            Label("Track Your Health Trends", systemImage: "chart.line.uptrend.xyaxis")
        } description: {
            VStack(spacing: Spacing.small) {
                Text("Upload lab reports to visualize your health markers and track changes over time.")
                    .multilineTextAlignment(.center)

                Text("Add your first report to start tracking your wellness journey.")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
                    .multilineTextAlignment(.center)
            }
        } actions: {
            Button("Upload Lab Report") {
                documentPickerStore.selectDocumentType(.biomarkerReport)
                showDocumentPicker = true
            }
            .buttonStyle(.borderedProminent)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var emptyFilteredResultsView: some View {
        if viewModel.searchText != "" {
            ContentUnavailableView {
                Label("No Matching Results", systemImage: "magnifyingglass")
            } description: {
                Text("Try adjusting your search terms to find health markers.")
                    .multilineTextAlignment(.center)
            } actions: {
                Button("Clear Search") {
                    viewModel.clearSearch()
                }
                .buttonStyle(.bordered)
            }
        } else {
            ContentUnavailableView {
                Label("No Results Found", systemImage: "chart.xyaxis.line")
            } description: {
                Text("Upload lab reports to your health journal entries to see trends here.")
                    .multilineTextAlignment(.center)
            } actions: {
                Button("Clear Search") {
                    viewModel.clearSearch()
                }
                .buttonStyle(.bordered)
            }
        }
    }
    
}


// MARK: - Preview Container Helper
struct PreviewContainer {
    static func createModelContainer() -> ModelContainer {
        let schema = Schema([
            Patient.self,
            MedicalCase.self,
            BioMarkerReport.self,
            BioMarkerResult.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        
        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }
}

#Preview("Blood Tests View with Data") {
    let container = PreviewContainer.createModelContainer()
    let patient = Patient.samplePatient
    
    NavigationStack {
        BioMarkersView(viewModel: BioMarkersViewModel(patient: patient, modelContext: container.mainContext))
    }
    .modelContainer(container)
}

#Preview("Empty Blood Tests View") {
    let container = PreviewContainer.createModelContainer()
    let patient = Patient.samplePatient
    
    NavigationStack {
        BioMarkersView(viewModel: BioMarkersViewModel(patient: patient, modelContext: container.mainContext))
    }
    .modelContainer(container)
}

#Preview("Blood Tests - With Medications Patient") {
    let container = PreviewContainer.createModelContainer()
    let patient = Patient.samplePatientWithMedications
    
    NavigationStack {
        BioMarkersView(viewModel: BioMarkersViewModel(patient: patient, modelContext: container.mainContext))
    }
    .modelContainer(container)
}
