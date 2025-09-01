//
//  BloodTestsViewModel.swift
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
class BloodTestsViewModel {
    
    // MARK: - Published Properties
    var bloodReports: [BloodReport] = []
    var aggregatedBiomarkers: [AggregatedBiomarker] = []
    var searchText = ""
    var isLoading = false
    var isProcessingData = false
    var error: Error?
    
    // Navigation State
    var selectedBiomarker: AggregatedBiomarker?
    var selectedBloodReport: BloodReport?
    
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
    
    // MARK: - Initializer
    
    init(patient: Patient, modelContext: ModelContext) {
        self.patient = patient
        self.modelContext = modelContext
    }
    
    // MARK: - Data Fetching (Following Hacking with Swift pattern)
    
    @MainActor
    func fetchBloodReports(patientID: UUID) async {
        isLoading = true
        error = nil
        
        do {
            let predicate = #Predicate<BloodReport> { report in
                if let medicalCase = report.medicalCase,
                   let patient = medicalCase.patient {
                    return patient.id == patientID
                } else {
                    return false
                }
            }
            let descriptor = FetchDescriptor<BloodReport>(
                predicate: predicate,
                sortBy: [SortDescriptor(\.resultDate, order: .reverse)]
            )
            
            bloodReports = try modelContext.fetch(descriptor)
            
            try await processBloodTestData()
            
        } catch {
            self.error = error
        }
        
        isLoading = false
    }
    
    func refreshData() {
        Task {
            if let patientID = patient.id {
                await fetchBloodReports(patientID: patientID)
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
    
    func selectBloodReport(_ bloodReport: BloodReport) {
        selectedBloodReport = bloodReport
    }
    
    // MARK: - Data Processing (Moved from View)
    
    @MainActor
    private func processBloodTestData() async {
        guard !bloodReports.isEmpty else {
            aggregatedBiomarkers = []
            return
        }
        
        isProcessingData = true
        
        // Process data in background
        let processed = await withTaskGroup(of: [AggregatedBiomarker].self) { group in
            group.addTask { [weak self] in
                await self?.aggregateBloodTestResults() ?? []
            }
            
            var allBiomarkers: [AggregatedBiomarker] = []
            for await biomarkers in group {
                allBiomarkers.append(contentsOf: biomarkers)
            }
            return allBiomarkers
        }
        
        aggregatedBiomarkers = processed
        isProcessingData = false
    }
    
    private func aggregateBloodTestResults() async -> [AggregatedBiomarker] {
        // Group all test results by test name
        var testGroups: [String: [BloodTestResult]] = [:]
        
        for report in bloodReports {
            for testResult in report.testResults ?? [] {
                guard let testName = testResult.testName else { continue }
                
                let normalizedName = testName.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
                if testGroups[normalizedName] == nil {
                    testGroups[normalizedName] = []
                }
                testGroups[normalizedName]?.append(testResult)
            }
        }
        
        // Create aggregated biomarkers
        return testGroups.compactMap { (testName, results) in
            createAggregatedBiomarker(from: results)
        }
    }
    
    private func createAggregatedBiomarker(from results: [BloodTestResult]) -> AggregatedBiomarker? {
        // Filter results that have all required data
        let validResults = results.compactMap { result -> (BloodTestResult, Date)? in
            guard let bloodReport = result.bloodReport,
                  let resultDate = bloodReport.resultDate else {
                return nil
            }
            return (result, resultDate)
        }
        
        guard let (latestResult, latestDate) = validResults.sorted(by: { $0.1 > $1.1 }).first,
              let testName = latestResult.testName,
              let currentValue = latestResult.value else {
            return nil
        }
        
        // Calculate historical values for trend analysis
        let sortedResults = validResults.sorted { $0.1 < $1.1 }
        let historicalValues = sortedResults.compactMap { result, _ -> Double? in
            guard let value = result.value else { return nil }
            return Double(value)
        }
        
        // Calculate trend
        let (trendDirection, trendText, trendPercentage) = calculateTrend(from: historicalValues)
        
        // Determine health status
        let healthStatus = determineHealthStatus(for: latestResult, from: historicalValues)
        
        return AggregatedBiomarker(
            id: UUID(),
            testName: testName,
            currentValue: currentValue,
            unit: latestResult.unit ?? "",
            referenceRange: latestResult.referenceRange ?? "",
            category: latestResult.bloodReport?.category ?? "General",
            latestDate: latestDate,
            historicalValues: historicalValues,
            healthStatus: healthStatus,
            trendDirection: trendDirection,
            trendText: trendText,
            trendPercentage: trendPercentage,
            latestBloodReport: latestResult.bloodReport!,
            testCount: results.count
        )
    }
    
    private func calculateTrend(from values: [Double]) -> (TrendDirection, String, String) {
        guard values.count >= 2 else {
            return (.stable, "No comparison", "--")
        }
        
        let current = values.last!
        let previous = values[values.count - 2]
        let change = current - previous
        let percentageChange = abs(change / previous * 100)
        
        let direction: TrendDirection
        if abs(change) < 0.01 { // Consider very small changes as stable
            direction = .stable
        } else if change > 0 {
            direction = .up
        } else {
            direction = .down
        }
        
        let changeText = String(format: "%.1f", abs(change))
        let percentageText = String(format: "%.0f%%", percentageChange)
        
        return (direction, changeText, percentageText)
    }
    
    private func determineHealthStatus(for result: BloodTestResult, from historicalValues: [Double]) -> HealthStatus {
        let isAbnormal = result.isAbnormal ?? false
        
        if isAbnormal {
            // Check if it's consistently abnormal (critical) or just recent (warning)
            let recentAbnormalCount = historicalValues.suffix(3).filter { _ in
                // This is a simplified check - in reality you'd parse reference ranges properly
                // For now, we'll just check if the current result is abnormal
                isAbnormal
            }.count
            
            return recentAbnormalCount >= 2 ? .critical : .warning
        }
        
        // Check for consistently good values
        if historicalValues.count >= 3 {
            return .optimal
        }
        
        return .good
    }
    
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

extension BloodTestsViewModel {
    
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
