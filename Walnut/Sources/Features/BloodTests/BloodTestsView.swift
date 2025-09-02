//
//  BloodTestsView.swift
//  Walnut
//
//  Created by Mayank Gandhi on 28/07/25.
//  Copyright © 2025 m. All rights reserved.
//

import SwiftUI
import SwiftData
import WalnutDesignSystem

struct BloodTestsView: View {
    
    @State private var viewModel: BloodTestsViewModel
    
    init(viewModel: BloodTestsViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        NavigationStack {
            Group {
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
            .background(Color(UIColor.systemGroupedBackground))
            .navigationTitle("Blood Tests")
            .navigationBarTitleDisplayMode(.large)
            .searchable(text: Binding(
                get: { viewModel.searchText },
                set: { viewModel.updateSearchText($0) }
            ), prompt: "Search biomarkers...")
            .navigationDestination(item: $viewModel.selectedBiomarker) { biomarker in
                BiomarkerDetailView(
                    biomarkerName: biomarker.testName,
                    unit: biomarker.unit.isEmpty ? "N/A" : biomarker.unit,
                    normalRange: biomarker.referenceRange.isEmpty ? "N/A" : biomarker.referenceRange,
                    dataPoints: biomarker.historicalValues,
                    color: biomarker.healthStatusColor
                )
            }
            .navigationDestination(item: $viewModel.selectedBloodReport) { bloodReport in
                BloodReportDetailView(bloodReport: bloodReport)
            }
            .task {
                viewModel.refreshData()
            }
            .refreshable {
                viewModel.refreshData()
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
        .background(Color(UIColor.systemGroupedBackground))
    }
    
    private var emptyStateView: some View {
        ContentUnavailableView {
            Label("No Blood Tests", systemImage: "testtube.2")
        } description: {
            VStack(spacing: Spacing.small) {
                Text("Upload lab reports to track your biomarkers and health trends over time.")
                    .multilineTextAlignment(.center)
                
                Text("Your blood test history will appear here once you upload reports from your medical cases.")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(UIColor.systemGroupedBackground))
    }
    
    private var emptyFilteredResultsView: some View {
        ContentUnavailableView {
            Label("No Matching Results", systemImage: "magnifyingglass")
        } description: {
            Text("Try adjusting your search terms or filters to find blood test results.")
                .multilineTextAlignment(.center)
        } actions: {
            Button("Clear Filters") {
                viewModel.clearSearch()
            }
            .buttonStyle(.bordered)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(UIColor.systemGroupedBackground))
    }
    
}


// MARK: - Preview Container Helper
struct PreviewContainer {
    static func createModelContainer() -> ModelContainer {
        let schema = Schema([
            Patient.self,
            MedicalCase.self, 
            BloodReport.self,
            BloodTestResult.self
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
        BloodTestsView(viewModel: BloodTestsViewModel(patient: patient, modelContext: container.mainContext))
    }
    .modelContainer(container)
}

#Preview("Empty Blood Tests View") {
    let container = PreviewContainer.createModelContainer()
    let patient = Patient.samplePatient
    
    NavigationStack {
        BloodTestsView(viewModel: BloodTestsViewModel(patient: patient, modelContext: container.mainContext))
    }
    .modelContainer(container)
}

#Preview("Blood Tests - With Medications Patient") {
    let container = PreviewContainer.createModelContainer()
    let patient = Patient.samplePatientWithMedications
    
    NavigationStack {
        BloodTestsView(viewModel: BloodTestsViewModel(patient: patient, modelContext: container.mainContext))
    }
    .modelContainer(container)
}
