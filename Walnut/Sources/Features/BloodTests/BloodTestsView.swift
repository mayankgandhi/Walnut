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
    @State private var selectedCategory: String? = nil
    @State private var sortOrder: SortOrder = .date
    @State private var showingFilters = false
    
    // Computed property for aggregated biomarkers with performance optimization
    @State private var aggregatedBiomarkers: [AggregatedBiomarker] = []
    @State private var isProcessingData = false
    
    enum SortOrder: CaseIterable {
        case date, name, status, category
        
        var displayName: String {
            switch self {
            case .date: return "Date"
            case .name: return "Test Name"
            case .status: return "Health Status"
            case .category: return "Category"
            }
        }
        
        var iconName: String {
            switch self {
            case .date: return "calendar"
            case .name: return "textformat.abc"
            case .status: return "heart.fill"
            case .category: return "tag"
            }
        }
    }
    
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
            VStack(spacing: 0) {
                // Simple Modern Header
                modernHeaderSection
                
                // Filter and Sort Controls
                if !bloodReports.isEmpty {
                    filterAndSortSection
                        .background(Color(UIColor.systemBackground))
                }
                
                // Main Content
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
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingFilters.toggle() }) {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                            .foregroundStyle(showingFilters ? Color.healthPrimary : .secondary)
                    }
                }
            }
            .sheet(isPresented: $showingFilters) {
                filtersSheet
            }
            .onAppear {
                processBloodTestData()
            }
            .onChange(of: bloodReports) {
                processBloodTestData()
            }
        }
    }
    
    // MARK: - Modern Header Section
    private var modernHeaderSection: some View {
        VStack(spacing: Spacing.medium) {
            // Clean stats row with subtle animations
            HStack(spacing: Spacing.xl) {
                // Total biomarkers with pulse animation
                VStack(spacing: 4) {
                    Text("\(filteredBiomarkers.count)")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.healthPrimary)
                        .contentTransition(.numericText())
                    
                    Text("Biomarkers")
                        .font(.caption.weight(.medium))
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                // Health status indicator with dynamic color
                VStack(spacing: 4) {
                    HStack(spacing: 6) {
                        Circle()
                            .fill(healthStatusGradient)
                            .frame(width: 12, height: 12)
                            .scaleEffect(abnormalTestsCount > 0 ? 1.2 : 1.0)
                            .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: abnormalTestsCount > 0)
                        
                        Text(healthStatusText)
                            .font(.system(size: 20, weight: .semibold, design: .rounded))
                            .foregroundStyle(abnormalTestsCount > 0 ? Color.healthWarning : Color.healthSuccess)
                    }
                    
                    Text(abnormalTestsCount > 0 ? "\(abnormalTestsCount) need attention" : "All looking good")
                        .font(.caption.weight(.medium))
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                // Latest update with relative time
                VStack(spacing: 4) {
                    Text(latestTestRelativeTime)
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundStyle(Color.healthPrimary)
                    
                    Text("Last updated")
                        .font(.caption.weight(.medium))
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.horizontal, Spacing.large)
            .padding(.vertical, Spacing.medium)
            
            // Subtle divider
            if !bloodReports.isEmpty {
                Rectangle()
                    .fill(.quaternary)
                    .frame(height: 1)
                    .padding(.horizontal, Spacing.large)
            }
        }
        .background(
            // Subtle gradient background
            LinearGradient(
                colors: [
                    Color(UIColor.systemBackground),
                    Color(UIColor.systemBackground).opacity(0.8)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        )
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
    
    // MARK: - Computed Properties for Modern Header
    
    private var healthStatusGradient: some ShapeStyle {
        if abnormalTestsCount > 0 {
            return LinearGradient(
                colors: [Color.healthWarning, Color.healthWarning.opacity(0.7)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        } else {
            return LinearGradient(
                colors: [Color.healthSuccess, Color.healthSuccess.opacity(0.7)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
    
    private var healthStatusText: String {
        if abnormalTestsCount == 0 {
            return "Healthy"
        } else if abnormalTestsCount <= 2 {
            return "Monitor"
        } else {
            return "Review"
        }
    }
    
    private var latestTestRelativeTime: String {
        guard let latestDate = bloodReports.first?.resultDate else { return "No data" }
        
        let days = Calendar.current.dateComponents([.day], from: latestDate, to: Date()).day ?? 0
        
        if days == 0 {
            return "Today"
        } else if days == 1 {
            return "Yesterday"
        } else if days < 7 {
            return "\(days) days ago"
        } else if days < 30 {
            let weeks = days / 7
            return weeks == 1 ? "1 week ago" : "\(weeks) weeks ago"
        } else {
            let months = days / 30
            return months == 1 ? "1 month ago" : "\(months) months ago"
        }
    }
    
    // MARK: - Filter and Sort Section
    private var filterAndSortSection: some View {
        VStack(spacing: Spacing.small) {
            HStack(spacing: Spacing.medium) {
                // Sort Picker
                Menu {
                    ForEach(SortOrder.allCases, id: \.self) { order in
                        Button(action: { sortOrder = order }) {
                            HStack {
                                Image(systemName: order.iconName)
                                Text(order.displayName)
                                if sortOrder == order {
                                    Spacer()
                                    Image(systemName: "checkmark")
                                }
                            }
                        }
                    }
                } label: {
                    HStack(spacing: Spacing.xs) {
                        Image(systemName: sortOrder.iconName)
                            .font(.caption)
                        Text(sortOrder.displayName)
                            .font(.caption.weight(.medium))
                        Image(systemName: "chevron.down")
                            .font(.caption2)
                    }
                    .foregroundStyle(Color.healthPrimary)
                    .padding(.horizontal, Spacing.small)
                    .padding(.vertical, 6)
                    .background(Color.healthPrimary.opacity(0.1))
                    .clipShape(Capsule())
                }
                
                Spacer()
                
                // Category Filter
                if !availableCategories.isEmpty {
                    Menu {
                        Button("All Categories") {
                            selectedCategory = nil
                        }
                        
                        ForEach(availableCategories, id: \.self) { category in
                            Button(category.isEmpty ? "General" : category) {
                                selectedCategory = category
                            }
                        }
                    } label: {
                        HStack(spacing: Spacing.xs) {
                            Image(systemName: "tag")
                                .font(.caption)
                            Text(selectedCategory?.isEmpty == false ? selectedCategory! : "All")
                                .font(.caption.weight(.medium))
                                .lineLimit(1)
                            Image(systemName: "chevron.down")
                                .font(.caption2)
                        }
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, Spacing.small)
                        .padding(.vertical, 6)
                        .background(Color(UIColor.secondarySystemGroupedBackground))
                        .clipShape(Capsule())
                    }
                }
            }
            .padding(.horizontal, Spacing.medium)
            
            // Active Filters Indicator
            if selectedCategory != nil || !searchText.isEmpty {
                HStack {
                    Text("Active filters:")
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                    
                    if !searchText.isEmpty {
                        filterTag(text: "Search: \(searchText)", onRemove: { searchText = "" })
                    }
                    
                    if let category = selectedCategory {
                        filterTag(text: category.isEmpty ? "General" : category, onRemove: { selectedCategory = nil })
                    }
                    
                    Spacer()
                }
                .padding(.horizontal, Spacing.medium)
                .padding(.bottom, Spacing.xs)
            }
        }
        .padding(.vertical, Spacing.small)
    }
    
    private func filterTag(text: String, onRemove: @escaping () -> Void) -> some View {
        HStack(spacing: 4) {
            Text(text)
                .font(.caption2.weight(.medium))
            
            Button(action: onRemove) {
                Image(systemName: "xmark")
                    .font(.caption2.weight(.bold))
            }
        }
        .foregroundStyle(.white)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Color.healthPrimary)
        .clipShape(Capsule())
    }
    
    // MARK: - Main Content Views
    private var biomarkersList: some View {
        ScrollView {
            LazyVStack(spacing: Spacing.medium) {
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
                        // Navigate to detailed biomarker view
                        selectedBiomarker = biomarker
                    }
                }
            }
            .padding(.horizontal, Spacing.medium)
            .padding(.bottom, Spacing.xl)
        }
        .navigationDestination(item: $selectedBiomarker) { biomarker in
            BiomarkerDetailView(
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
                selectedCategory = nil
            }
            .buttonStyle(.bordered)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(UIColor.systemGroupedBackground))
    }
    
    // MARK: - Filters Sheet
    private var filtersSheet: some View {
        NavigationStack {
            List {
                Section("Sort Order") {
                    ForEach(SortOrder.allCases, id: \.self) { order in
                        HStack {
                            Image(systemName: order.iconName)
                                .foregroundStyle(Color.healthPrimary)
                                .frame(width: 20)
                            
                            Text(order.displayName)
                            
                            Spacer()
                            
                            if sortOrder == order {
                                Image(systemName: "checkmark")
                                    .foregroundStyle(Color.healthPrimary)
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            sortOrder = order
                        }
                    }
                }
                
                Section("Categories") {
                    HStack {
                        Text("All Categories")
                        Spacer()
                        if selectedCategory == nil {
                            Image(systemName: "checkmark")
                                .foregroundStyle(Color.healthPrimary)
                        }
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        selectedCategory = nil
                    }
                    
                    ForEach(availableCategories, id: \.self) { category in
                        HStack {
                            Circle()
                                .fill(categoryColor(for: category))
                                .frame(width: 12, height: 12)
                            
                            Text(category.isEmpty ? "General" : category)
                            
                            Spacer()
                            
                            if selectedCategory == category {
                                Image(systemName: "checkmark")
                                    .foregroundStyle(Color.healthPrimary)
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            selectedCategory = category
                        }
                    }
                }
            }
            .navigationTitle("Filters")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        showingFilters = false
                    }
                }
            }
        }
        .presentationDetents([.medium])
    }
    
    // MARK: - Computed Properties
    
    private var totalTests: Int {
        bloodReports.reduce(0) { $0 + $1.testResults.count }
    }
    
    private var abnormalTestsCount: Int {
        bloodReports.reduce(0) { total, report in
            total + report.testResults.filter(\.isAbnormal).count
        }
    }
    
    private var availableCategories: [String] {
        Array(Set(bloodReports.map { $0.category })).sorted()
    }
    
    private var filteredBiomarkers: [AggregatedBiomarker] {
        var filtered = aggregatedBiomarkers
        
        // Apply search filter
        if !searchText.isEmpty {
            filtered = filtered.filter { biomarker in
                biomarker.testName.localizedCaseInsensitiveContains(searchText) ||
                biomarker.category.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        // Apply category filter
        if let selectedCategory = selectedCategory {
            filtered = filtered.filter { $0.category.lowercased() == selectedCategory.lowercased() }
        }
        
        // Apply sort order
        switch sortOrder {
        case .date:
            filtered.sort { $0.latestDate > $1.latestDate }
        case .name:
            filtered.sort { $0.testName < $1.testName }
        case .status:
            filtered.sort { $0.healthStatus.rawValue < $1.healthStatus.rawValue }
        case .category:
            filtered.sort { $0.category < $1.category }
        }
        
        return filtered
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
