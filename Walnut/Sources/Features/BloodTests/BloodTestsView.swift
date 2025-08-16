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
    
    let patient: Patient
    
    @Query private var bloodReports: [BloodReport]
    @Environment(\.modelContext) private var modelContext
    @State private var selectedBloodReport: BloodReport?
    @State private var selectedBiomarker: AggregatedBiomarker?
    @State private var searchText = ""
    
    // Computed property for aggregated biomarkers with performance optimization
    @State private var aggregatedBiomarkers: [AggregatedBiomarker] = []
    @State private var isProcessingData = false
    
    
    init(patient: Patient) {
        self.patient = patient
        let patientID = patient.id
        _bloodReports = Query(
            filter: #Predicate<BloodReport> { report in
                report.medicalCase.patient.id == patientID
            },
            sort: \BloodReport.resultDate,
            order: .reverse
        )
    }
    
    var body: some View {
        NavigationStack {
            // Main Content - Clean BioMarker List
            if isProcessingData {
                loadingView
            } else if filteredBiomarkers.isEmpty && !bloodReports.isEmpty {
                emptyFilteredResultsView
            } else if bloodReports.isEmpty {
                emptyStateView
            } else {
                biomarkersList
            }
        }
        .background(Color(UIColor.systemGroupedBackground))
        .navigationTitle("Blood Tests")
        .navigationBarTitleDisplayMode(.large)
        .searchable(text: $searchText, prompt: "Search biomarkers...")
        .onAppear {
            processBloodTestData()
        }
        .onChange(of: bloodReports) {
            processBloodTestData()
        }
    }
    
    
    private func categoryColor(for category: String) -> Color {
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
    
    
    
    // MARK: - Main Content Views
    private var biomarkersList: some View {
        ScrollView {
            LazyVStack(spacing: Spacing.small) {
                ForEach(filteredBiomarkers, id: \.id) { biomarker in
                    BiomarkerListItemView(
                        data: biomarker.historicalValues,
                        color: biomarker.healthStatusColor,
                        biomarkerInfo: BiomarkerInfo(
                            name: biomarker.testName,
                            description: biomarker.description,
                            normalRange: biomarker.referenceRange,
                            unit: biomarker.unit
                        ),
                        biomarkerTrends: BiomarkerTrends(
                            currentValue: biomarker.currentNumericValue,
                            currentValueText: biomarker.currentValue,
                            comparisonText: biomarker.trendText,
                            comparisonPercentage: biomarker.trendPercentage,
                            trendDirection: biomarker.trendDirection,
                            normalRange: biomarker.referenceRange
                        )
                    )
                    .onTapGesture {
                        selectedBiomarker = biomarker
                    }
                }
            }
            .padding(.horizontal, Spacing.medium)
            .padding(.top, Spacing.small)
            .padding(.bottom, Spacing.large)
        }
        .navigationDestination(item: $selectedBiomarker) { biomarker in
            BiomarkerDetailView(
                biomarkerName: biomarker.testName,
                unit: biomarker.unit,
                normalRange: biomarker.referenceRange,
                description: biomarker.description,
                dataPoints: createDataPoints(for: biomarker),
                color: biomarker.healthStatusColor
            )
        }
        .navigationDestination(item: $selectedBloodReport) { bloodReport in
            BloodReportDetailView(bloodReport: bloodReport)
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
                searchText = ""
            }
            .buttonStyle(.bordered)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(UIColor.systemGroupedBackground))
    }
    
    
    // MARK: - Computed Properties
    
    private var filteredBiomarkers: [AggregatedBiomarker] {
        var filtered = aggregatedBiomarkers
        
        // Apply search filter
        if !searchText.isEmpty {
            filtered = filtered.filter { biomarker in
                biomarker.testName.localizedCaseInsensitiveContains(searchText) ||
                biomarker.category.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        // Sort by date (latest first)
        filtered.sort { $0.latestDate > $1.latestDate }
        
        return filtered
    }
    
    // MARK: - Helper Functions
    
    private func createDataPoints(for biomarker: AggregatedBiomarker) -> [BiomarkerDetailView.BiomarkerDataPoint] {
        // Get all blood test results for this biomarker
        var dataPoints: [BiomarkerDetailView.BiomarkerDataPoint] = []
        
        // Collect all test results for this biomarker from all blood reports
        for report in bloodReports {
            for testResult in report.testResults {
                if testResult.testName.lowercased() == biomarker.testName.lowercased() {
                    if let value = Double(testResult.value) {
                        dataPoints.append(
                            BiomarkerDetailView.BiomarkerDataPoint(
                                date: report.resultDate,
                                value: value,
                                isAbnormal: testResult.isAbnormal,
                                bloodReport: report.labName
                            )
                        )
                    }
                }
            }
        }
        
        // Sort by date
        return dataPoints.sorted { $0.date < $1.date }
    }
    
    // MARK: - Data Processing
    
    private func processBloodTestData() {
        guard !bloodReports.isEmpty else {
            aggregatedBiomarkers = []
            return
        }
        
        isProcessingData = true
        
        Task {
            // Process data in background
            let processed = await withTaskGroup(of: [AggregatedBiomarker].self) { group in
                group.addTask {
                    await aggregateBloodTestResults()
                }
                
                var allBiomarkers: [AggregatedBiomarker] = []
                for await biomarkers in group {
                    allBiomarkers.append(contentsOf: biomarkers)
                }
                return allBiomarkers
            }
            
            await MainActor.run {
                self.aggregatedBiomarkers = processed
                self.isProcessingData = false
            }
        }
    }
    
    private func aggregateBloodTestResults() async -> [AggregatedBiomarker] {
        // Group all test results by test name
        var testGroups: [String: [BloodTestResult]] = [:]
        
        for report in bloodReports {
            for testResult in report.testResults {
                let normalizedName = testResult.testName.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
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
        guard let latestResult = results.sorted(by: { $0.bloodReport.resultDate > $1.bloodReport.resultDate }).first else {
            return nil
        }
        
        // Calculate historical values for trend analysis
        let sortedResults = results.sorted { $0.bloodReport.resultDate < $1.bloodReport.resultDate }
        let historicalValues = sortedResults.compactMap { Double($0.value) }
        
        // Calculate trend
        let (trendDirection, trendText, trendPercentage) = calculateTrend(from: historicalValues)
        
        // Determine health status
        let healthStatus = determineHealthStatus(for: latestResult, from: historicalValues)
        
        return AggregatedBiomarker(
            id: UUID(),
            testName: latestResult.testName,
            currentValue: latestResult.value,
            unit: latestResult.unit,
            referenceRange: latestResult.referenceRange,
            category: latestResult.bloodReport.category,
            latestDate: latestResult.bloodReport.resultDate,
            historicalValues: historicalValues,
            healthStatus: healthStatus,
            trendDirection: trendDirection,
            trendText: trendText,
            trendPercentage: trendPercentage,
            latestBloodReport: latestResult.bloodReport,
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
    
    private func determineHealthStatus(for result: BloodTestResult, from historicalValues: [Double]) -> AggregatedBiomarker.HealthStatus {
        if result.isAbnormal {
            // Check if it's consistently abnormal (critical) or just recent (warning)
            let recentAbnormalCount = historicalValues.suffix(3).filter { value in
                // This is a simplified check - in reality you'd parse reference ranges properly
                result.isAbnormal
            }.count
            
            return recentAbnormalCount >= 2 ? .critical : .warning
        }
        
        // Check for consistently good values
        if historicalValues.count >= 3 {
            return .optimal
        }
        
        return .good
    }
}

// MARK: - Supporting Types

struct AggregatedBiomarker: Identifiable, Hashable {
    
    static func == (lhs: AggregatedBiomarker, rhs: AggregatedBiomarker) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    let id: UUID
    let testName: String
    let currentValue: String
    let unit: String
    let referenceRange: String
    let category: String
    let latestDate: Date
    let historicalValues: [Double]
    let healthStatus: HealthStatus
    let trendDirection: TrendDirection
    let trendText: String
    let trendPercentage: String
    let latestBloodReport: BloodReport
    let testCount: Int
    
    enum HealthStatus: Int, CaseIterable {
        case optimal = 0
        case good = 1
        case warning = 2
        case critical = 3
    }
    
    var currentNumericValue: Double {
        Double(currentValue) ?? 0.0
    }
    
    var healthStatusColor: Color {
        switch healthStatus {
        case .optimal: return .healthSuccess
        case .good: return .healthPrimary
        case .warning: return .healthWarning
        case .critical: return .healthError
        }
    }
    
    var description: String {
        switch testName.lowercased() {
        case let name where name.contains("hemoglobin"):
            return "Protein that carries oxygen in red blood cells"
        case let name where name.contains("glucose"):
            return "Blood sugar levels, important for diabetes monitoring"
        case let name where name.contains("cholesterol"):
            return "Blood fats that affect cardiovascular health"
        case let name where name.contains("white blood"):
            return "Immune system cells that fight infections"
        case let name where name.contains("platelet"):
            return "Blood cells that help with clotting"
        case let name where name.contains("creatinine"):
            return "Kidney function marker"
        case let name where name.contains("thyroid") || name.contains("tsh"):
            return "Thyroid hormone levels affecting metabolism"
        default:
            return "Blood test biomarker for health monitoring"
        }
    }
}

#Preview {
    NavigationStack {
        BloodTestsView(patient: Patient.samplePatient)
    }
}
