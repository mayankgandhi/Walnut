//
//  BiomarkerEngine.swift
//  Walnut
//
//  Created by Mayank Gandhi on 20/09/25.
//  Copyright © 2025 m. All rights reserved.
//

import Foundation

/// Engine responsible for converting blood reports into aggregated biomarker data
/// for visualization and analysis in the BioMarkersViewModel
class BiomarkerEngine {

    // MARK: - Public Interface

    /// Main function: Convert blood reports into aggregated biomarkers
    /// - Parameter bloodReports: Array of blood reports to process
    /// - Returns: Array of aggregated biomarkers ready for display
    static func generateAggregatedBiomarkers(
        from bloodReports: [BioMarkerReport]
    ) -> [AggregatedBiomarker] {

        let engine = BiomarkerEngine()
        return engine.processBioMarkerReports(bloodReports)
    }

    /// Generate biomarkers filtered by category
    /// - Parameters:
    ///   - bloodReports: Array of blood reports to process
    ///   - category: Optional category filter
    /// - Returns: Filtered aggregated biomarkers
    static func generateFilteredBiomarkers(
        from bloodReports: [BioMarkerReport],
        category: String? = nil
    ) -> [AggregatedBiomarker] {

        let filteredReports = category != nil
            ? bloodReports.filter { $0.category == category }
            : bloodReports

        return generateAggregatedBiomarkers(from: filteredReports)
    }

    /// Generate biomarkers for a specific date range
    /// - Parameters:
    ///   - bloodReports: Array of blood reports to process
    ///   - startDate: Start date for filtering
    ///   - endDate: End date for filtering
    /// - Returns: Date-filtered aggregated biomarkers
    static func generateBiomarkersForDateRange(
        from bloodReports: [BioMarkerReport],
        startDate: Date,
        endDate: Date
    ) -> [AggregatedBiomarker] {

        let filteredReports = bloodReports.filter { report in
            guard let resultDate = report.resultDate else { return false }
            return resultDate >= startDate && resultDate <= endDate
        }

        return generateAggregatedBiomarkers(from: filteredReports)
    }

    // MARK: - Private Implementation

    private func processBioMarkerReports(_ bloodReports: [BioMarkerReport]) -> [AggregatedBiomarker] {
        // Validate input data
        let validReports = validateBioMarkerReports(bloodReports)

        guard !validReports.isEmpty else { return [] }

        // Group all test results by test name
        let testGroups = groupTestResultsByName(from: validReports)

        // Create aggregated biomarkers from grouped results
        return testGroups.compactMap { (testName, results) in
            createAggregatedBiomarker(from: results)
        }
    }

    // MARK: - Data Validation

    private func validateBioMarkerReports(_ reports: [BioMarkerReport]) -> [BioMarkerReport] {
        return reports.filter { report in
            // Ensure report has basic required data
            guard report.resultDate != nil else { return false }
            guard let testResults = report.testResults, !testResults.isEmpty else { return false }

            // Ensure at least one test result has valid data
            return testResults.contains { result in
                result.testName?.isEmpty == false && result.value?.isEmpty == false
            }
        }
    }

    // MARK: - Data Grouping

    private func groupTestResultsByName(from reports: [BioMarkerReport]) -> [String: [BioMarkerResult]] {
        var testGroups: [String: [BioMarkerResult]] = [:]

        for report in reports {
            for testResult in report.testResults ?? [] {
                guard let testName = testResult.testName else { continue }

                let normalizedName = testName.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
                if testGroups[normalizedName] == nil {
                    testGroups[normalizedName] = []
                }
                testGroups[normalizedName]?.append(testResult)
            }
        }

        return testGroups
    }

    // MARK: - Biomarker Creation

    private func createAggregatedBiomarker(from results: [BioMarkerResult]) -> AggregatedBiomarker? {
        // Filter results that have all required data
        let validResults = results.compactMap { result -> (BioMarkerResult, Date)? in
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

        // Create historical data points
        let rawHistoricalValues = validResults.map { (result, date) in
            BiomarkerDataPoint(
                date: date,
                value: Double(result.value ?? "0") ?? 0.0,
                bloodReport: result.bloodReport?.testName,
                document: result.bloodReport?.document
            )
        }

        // Remove duplicates based on date and value, keeping the most recent one
        let historicalValues = removeDuplicateBiomarkerDataPoints(rawHistoricalValues)
            .sorted { $0.date < $1.date }

        // Calculate trends and health status
        let (trendDirection, trendText, trendPercentage) = calculateTrend(from: historicalValues)
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
            latestBioMarkerReport: latestResult.bloodReport!,
            testCount: results.count
        )
    }

    // MARK: - Trend Calculation

    private func calculateTrend(from dataPoints: [BiomarkerDataPoint]) -> (TrendDirection, String, String) {
        // Filter out data points with nil values and sort by date
        let validDataPoints = dataPoints
            .compactMap { dataPoint -> (Date, Double)? in
                return (dataPoint.date, dataPoint.value)
            }
            .sorted { $0.0 < $1.0 }

        guard validDataPoints.count >= 2 else {
            return (.stable, "0.0", "0%")
        }

        let latest = validDataPoints.last!
        let previous = validDataPoints[validDataPoints.count - 2]

        let change = latest.1 - previous.1
        let percentageChange = abs(change / previous.1 * 100)

        let direction: TrendDirection
        if abs(change) < 0.01 {
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

    // MARK: - Duplicate Removal

    private func removeDuplicateBiomarkerDataPoints(_ dataPoints: [BiomarkerDataPoint]) -> [BiomarkerDataPoint] {
        var uniqueDataPoints: [BiomarkerDataPoint] = []
        var seenCombinations: Set<String> = []

        // Sort by date to keep the latest entry when duplicates are found
        let sortedDataPoints = dataPoints.sorted { $0.date > $1.date }

        for dataPoint in sortedDataPoints {
            // Create a unique key combining date (day precision) and value
            let calendar = Calendar.current
            let dateComponents = calendar.dateComponents([.year, .month, .day], from: dataPoint.date)
            let dateKey = "\(dateComponents.year ?? 0)-\(dateComponents.month ?? 0)-\(dateComponents.day ?? 0)"
            let combinationKey = "\(dateKey):\(dataPoint.value)"

            // Only add if we haven't seen this combination before
            if !seenCombinations.contains(combinationKey) {
                seenCombinations.insert(combinationKey)
                uniqueDataPoints.append(dataPoint)
            }
        }

        return uniqueDataPoints
    }

    // MARK: - Health Status Determination

    private func determineHealthStatus(for result: BioMarkerResult, from dataPoints: [BiomarkerDataPoint]) -> HealthStatus {
        let isAbnormal = result.isAbnormal ?? false

        if isAbnormal {
            // Filter valid data points and sort by date
            let validDataPoints = dataPoints
                .compactMap { dataPoint -> (Date, Double)? in
                    return (dataPoint.date, dataPoint.value)
                }
                .sorted { $0.0 < $1.0 }

            if validDataPoints.count >= 2 {
                let latest = validDataPoints.last!
                let previous = validDataPoints[validDataPoints.count - 2]

                // Check if trend is improving
                let isImproving = (latest.1 > previous.1 && result.value != nil) // This would need more sophisticated logic

                return isImproving ? .warning : .critical
            } else {
                return .critical
            }
        } else {
            // Check if value is optimal within normal range
            if let referenceRange = result.referenceRange,
               let currentValue = result.value,
               let numericValue = Double(currentValue) {

                // Parse reference range (simplified parsing)
                let components = referenceRange.components(separatedBy: "-")
                if components.count == 2,
                   let lowerBound = Double(components[0].trimmingCharacters(in: .whitespaces)),
                   let upperBound = Double(components[1].trimmingCharacters(in: .whitespaces)) {

                    let midPoint = (lowerBound + upperBound) / 2
                    let optimalRange = (upperBound - lowerBound) * 0.3 // 30% of range around midpoint

                    if abs(numericValue - midPoint) <= optimalRange {
                        return .optimal
                    }
                }
            }

            return .good
        }
    }
}

// MARK: - Engine Extensions

extension BiomarkerEngine {

    /// Remove duplicate biomarker data points based on date and value
    /// - Parameter dataPoints: Array of biomarker data points to deduplicate
    /// - Returns: Array of unique biomarker data points, keeping the most recent when duplicates are found
    static func removeDuplicateBiomarkerDataPoints(_ dataPoints: [BiomarkerDataPoint]) -> [BiomarkerDataPoint] {
        let engine = BiomarkerEngine()
        return engine.removeDuplicateBiomarkerDataPoints(dataPoints)
    }

    /// Extract all test results from blood reports
    /// - Parameter reports: Blood reports to process
    /// - Returns: Flattened array of test results
    static func extractTestResults(from reports: [BioMarkerReport]) -> [BioMarkerResult] {
        return reports.flatMap { $0.testResults ?? [] }
    }

    /// Validate blood reports and return only valid ones
    /// - Parameter reports: Blood reports to validate
    /// - Returns: Array of valid blood reports
    static func validateBioMarkerReports(_ reports: [BioMarkerReport]) -> [BioMarkerReport] {
        let engine = BiomarkerEngine()
        return engine.validateBioMarkerReports(reports)
    }

    /// Filter biomarker reports that belong to a specific patient
    /// - Parameters:
    ///   - reports: All biomarker reports to filter
    ///   - patient: The patient to filter for
    /// - Returns: Array of reports associated with the patient
    static func filterReportsForPatient(from reports: [BioMarkerReport], patient: Patient) -> [BioMarkerReport] {
        return reports.filter { report in
            if let patientID = report.patient?.id {
                return patientID == patient.id
            } else if let medicalCase = report.medicalCase {
                return medicalCase.patient?.id == patient.id
            } else {
                return false
            }
        }
    }

    /// Filter biomarker reports that belong to a specific medical case
    /// - Parameters:
    ///   - reports: All biomarker reports to filter
    ///   - medicalCase: The medical case to filter for
    /// - Returns: Array of reports associated with the medical case
    static func filterReportsForMedicalCase(from reports: [BioMarkerReport], medicalCase: MedicalCase) -> [BioMarkerReport] {
        return reports.filter { report in
            return report.medicalCase?.id == medicalCase.id
        }
    }

    /// Get reports that have abnormal test results
    /// - Parameter reports: Reports to check
    /// - Returns: Array of reports containing abnormal results
    static func filterAbnormalReports(from reports: [BioMarkerReport]) -> [BioMarkerReport] {
        return reports.filter { report in
            return report.testResults?.contains { $0.isAbnormal == true } ?? false
        }
    }

    /// Get reports that have only normal test results
    /// - Parameter reports: Reports to check
    /// - Returns: Array of reports with all normal results
    static func filterNormalReports(from reports: [BioMarkerReport]) -> [BioMarkerReport] {
        return reports.filter { report in
            guard let testResults = report.testResults, !testResults.isEmpty else { return false }
            return !testResults.contains { $0.isAbnormal == true }
        }
    }

    /// Get biomarker trends for a specific test across all reports
    /// - Parameters:
    ///   - testName: Name of the test to analyze
    ///   - reports: Reports to search through
    /// - Returns: BiomarkerTrends object with trend analysis
    static func getBiomarkerTrends(for testName: String, from reports: [BioMarkerReport]) -> BiomarkerTrends? {
        let validReports = validateBioMarkerReports(reports)

        // Extract all test results for this specific test
        let testResults = validReports.flatMap { report in
            (report.testResults ?? []).compactMap { result -> (BioMarkerResult, Date)? in
                guard let resultTestName = result.testName,
                      resultTestName.lowercased() == testName.lowercased(),
                      let resultDate = report.resultDate else {
                    return nil
                }
                return (result, resultDate)
            }
        }.sorted { $0.1 < $1.1 } // Sort by date

        guard let latestResult = testResults.last else { return nil }

        // Create historical data points
        let rawHistoricalValues = testResults.map { (result, date) in
            BiomarkerDataPoint(
                date: date,
                value: Double(result.value ?? "0") ?? 0.0,
                bloodReport: result.bloodReport?.testName,
                document: result.bloodReport?.document
            )
        }

        // Remove duplicates based on date and value
        let historicalValues = BiomarkerEngine.removeDuplicateBiomarkerDataPoints(rawHistoricalValues)

        // Calculate trends
        let engine = BiomarkerEngine()
        let (trendDirection, trendText, trendPercentage) = engine.calculateTrend(from: historicalValues)

        return BiomarkerTrends(
            currentValue: Double(latestResult.0.value ?? "0") ?? 0.0,
            currentValueText: latestResult.0.value ?? "0",
            comparisonText: trendText,
            comparisonPercentage: trendPercentage,
            trendDirection: trendDirection,
            normalRange: latestResult.0.referenceRange ?? "N/A"
        )
    }

    /// Group biomarker reports by their source (medical case or direct patient)
    /// - Parameter reports: Reports to group
    /// - Returns: Dictionary mapping source information to reports
    static func groupReportsBySource(_ reports: [BioMarkerReport]) -> [String: [BioMarkerReport]] {
        return Dictionary(grouping: reports) { report in
            if let medicalCase = report.medicalCase,
               let title = medicalCase.title {
                return title
            } else if report.patient != nil {
                return "Direct Upload"
            } else {
                return "Other"
            }
        }
    }

    /// Get the most recent report for a patient
    /// - Parameters:
    ///   - reports: Reports to search through
    ///   - patient: Patient to filter for
    /// - Returns: Most recent report for the patient, if any
    static func getMostRecentReportForPatient(from reports: [BioMarkerReport], patient: Patient) -> BioMarkerReport? {
        let patientReports = filterReportsForPatient(from: reports, patient: patient)
        return patientReports.sorted {
            guard let date1 = $0.resultDate, let date2 = $1.resultDate else { return false }
            return date1 > date2
        }.first
    }

    // MARK: - Test/Debug Helper Functions

    /// Test function to demonstrate deduplication behavior
    /// - Returns: A tuple containing (original count, deduplicated count, sample data points)
    static func testDeduplication() -> (originalCount: Int, deduplicatedCount: Int, sampleData: [BiomarkerDataPoint]) {
        // Create sample data with duplicates
        let today = Date()
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: today) ?? today
        let twoDaysAgo = Calendar.current.date(byAdding: .day, value: -2, to: today) ?? today

        let sampleDataPoints = [
            BiomarkerDataPoint(date: today, value: 120.0, bloodReport: "Report 1"),
            BiomarkerDataPoint(date: today, value: 120.0, bloodReport: "Report 2"), // Duplicate: same date and value
            BiomarkerDataPoint(date: yesterday, value: 118.0, bloodReport: "Report 3"),
            BiomarkerDataPoint(date: yesterday, value: 118.0, bloodReport: "Report 4"), // Duplicate: same date and value
            BiomarkerDataPoint(date: yesterday, value: 119.0, bloodReport: "Report 5"), // Different value, same date
            BiomarkerDataPoint(date: twoDaysAgo, value: 115.0, bloodReport: "Report 6"),
            BiomarkerDataPoint(date: twoDaysAgo, value: 115.0, bloodReport: "Report 7"), // Duplicate: same date and value
        ]

        let deduplicatedData = removeDuplicateBiomarkerDataPoints(sampleDataPoints)

        return (
            originalCount: sampleDataPoints.count,
            deduplicatedCount: deduplicatedData.count,
            sampleData: deduplicatedData
        )
    }
}
