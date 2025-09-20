//
//  BioMarkersViewModel.swift
//  Walnut
//
//  Created by Mayank Gandhi on 29/08/25.
//  Copyright © 2025 m. All rights reserved.
//

import SwiftUI
import SwiftData
import Observation
import WalnutDesignSystem

@Observable
class BioMarkersViewModel {
    
    // MARK: - Published Properties
    var bloodReports: [BioMarkerReport] = []
    var aggregatedBiomarkers: [AggregatedBiomarker] = []
    var searchText = ""
    var isLoading = false
    var isProcessingData = false
    var error: Error?
    
    // Navigation State
    var selectedBiomarker: AggregatedBiomarker?
    var selectedBioMarkerReport: BioMarkerReport?
    
    // MARK: - Private Properties
    private let patient: Patient
    private let modelContext: ModelContext
    private var debounceTask: Task<Void, Never>?
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }()
    
    // MARK: - Computed Properties
    
    var filteredBiomarkers: [AggregatedBiomarker] {
        var filtered = aggregatedBiomarkers
        
        // Apply search filter
        if !searchText.isEmpty {
            filtered = filtered.filter { biomarker in
                let testName = biomarker.testName
                let category = biomarker.category
                return testName.localizedCaseInsensitiveContains(searchText) ||
                       category.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        // Sort by date (latest first)
        filtered.sort { $0.latestDate > $1.latestDate }
        
        return filtered
    }
    
    var isEmpty: Bool {
        return bloodReports.isEmpty
    }
    
    var hasFilteredResults: Bool {
        return !filteredBiomarkers.isEmpty
    }

    var currentPatient: Patient {
        return patient
    }

    var currentModelContext: ModelContext {
        return modelContext
    }
    
    // MARK: - Initializer
    
    init(patient: Patient, modelContext: ModelContext) {
        self.patient = patient
        self.modelContext = modelContext
    }
    
    // MARK: - Data Fetching (Following Hacking with Swift pattern)
    
    @MainActor
    func fetchBioMarkerReports(patientID: UUID) async {
        isLoading = true
        error = nil
        
        do {
            let predicate = #Predicate<BioMarkerReport> { report in
                if let medicalCase = report.medicalCase,
                   let patient = medicalCase.patient {
                    return patient.id == patientID
                } else {
                    return false
                }
            }
            let descriptor = FetchDescriptor<BioMarkerReport>(
                predicate: predicate,
                sortBy: [SortDescriptor(\.resultDate, order: .reverse)]
            )
            
            bloodReports = try modelContext.fetch(descriptor)
            
            try await processBioMarkerData()
            
        } catch {
            self.error = error
        }
        
        isLoading = false
    }
    
    func refreshData() {
        Task {
            if let patientID = patient.id {
                await fetchBioMarkerReports(patientID: patientID)
            }
        }
    }
    
    // MARK: - Search Management
    
    func updateSearchText(_ newText: String) {
        // Cancel any existing debounce task
        debounceTask?.cancel()
        
        // Debounce search updates to prevent excessive filtering
        debounceTask = Task { [weak self] in
            try? await Task.sleep(for: .milliseconds(300))
            
            guard !Task.isCancelled else { return }
            
            await MainActor.run {
                self?.searchText = newText
            }
        }
    }
    
    func clearSearch() {
        searchText = ""
        debounceTask?.cancel()
    }
    
    // MARK: - Navigation Actions
    
    func selectBiomarker(_ biomarker: AggregatedBiomarker) {
        selectedBiomarker = biomarker
    }
    
    func selectBioMarkerReport(_ bloodReport: BioMarkerReport) {
        selectedBioMarkerReport = bloodReport
    }
    
    // MARK: - Data Processing (Using BiomarkerEngine)

    @MainActor
    private func processBioMarkerData() async {
        guard !bloodReports.isEmpty else {
            aggregatedBiomarkers = []
            return
        }
        
        isProcessingData = true
        
        aggregatedBiomarkers = BiomarkerEngine.generateAggregatedBiomarkers(from: bloodReports)
        
        isProcessingData = false
    }

    // MARK: - Advanced BiomarkerEngine Features

    /// Get biomarkers filtered by category using the engine
    func getBiomarkersForCategory(_ category: String) -> [AggregatedBiomarker] {
        return BiomarkerEngine.generateFilteredBiomarkers(from: bloodReports, category: category)
    }

    // MARK: - Utility Methods

    func categoryColor(for category: String) -> Color {
        switch category.lowercased() {
        case "hematology": return .red
        case "chemistry": return .blue
        case "lipid": return .purple
        case "thyroid": return .orange
        case "liver": return .brown
        case "kidney": return .cyan
        default: return .healthPrimary
        }
    }
    
    // MARK: - Cleanup
    
    deinit {
        debounceTask?.cancel()
    }
}

// MARK: - Extensions

extension BioMarkersViewModel {
    
    /// Check if the view should show empty state
    var shouldShowEmptyState: Bool {
        return !isLoading && !isProcessingData && isEmpty
    }
    
    /// Check if the view should show empty filtered results
    var shouldShowEmptyFilteredResults: Bool {
        return !isLoading && !isProcessingData && !isEmpty && !hasFilteredResults
    }
    
    /// Check if the view should show biomarkers list
    var shouldShowBiomarkersList: Bool {
        return !isLoading && !isProcessingData && hasFilteredResults
    }
}
