//
//  BiomarkerEngine.swift
//  Walnut
//
//  Created by Mayank Gandhi on 20/09/25.
//  Copyright © 2025 m. All rights reserved.
//

import Foundation

/// Engine responsible for converting blood reports into aggregated biomarker data
/// for visualization and analysis in the BloodTestsViewModel
class BiomarkerEngine {

    // MARK: - Public Interface

    /// Main function: Convert blood reports into aggregated biomarkers
    /// - Parameter bloodReports: Array of blood reports to process
    /// - Returns: Array of aggregated biomarkers ready for display
    static func generateAggregatedBiomarkers(
        from bloodReports: [BloodReport]
    ) -> [AggregatedBiomarker] {

        let engine = BiomarkerEngine()
        return engine.processBloodReports(bloodReports)
    }

    /// Generate biomarkers filtered by category
    /// - Parameters:
    ///   - bloodReports: Array of blood reports to process
    ///   - category: Optional category filter
    /// - Returns: Filtered aggregated biomarkers
    static func generateFilteredBiomarkers(
        from bloodReports: [BloodReport],
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
        from bloodReports: [BloodReport],
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

    private func processBloodReports(_ bloodReports: [BloodReport]) -> [AggregatedBiomarker] {
        // Validate input data
        let validReports = validateBloodReports(bloodReports)

        guard !validReports.isEmpty else { return [] }

        // Group all test results by test name
        let testGroups = groupTestResultsByName(from: validReports)

        // Create aggregated biomarkers from grouped results
        return testGroups.compactMap { (testName, results) in
            createAggregatedBiomarker(from: results)
        }
    }

    // MARK: - Data Validation

    private func validateBloodReports(_ reports: [BloodReport]) -> [BloodReport] {
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

    private func groupTestResultsByName(from reports: [BloodReport]) -> [String: [BloodTestResult]] {
        var testGroups: [String: [BloodTestResult]] = [:]

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

        // Create historical data points
        let historicalValues = validResults.map { (result, date) in
            BiomarkerDataPoint(
                date: date,
                value: Double(result.value ?? "0") ?? 0.0,
                bloodReport: result.bloodReport?.testName,
                document: result.bloodReport?.document
            )
        }.sorted { $0.date < $1.date }

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
            latestBloodReport: latestResult.bloodReport!,
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

    // MARK: - Health Status Determination

    private func determineHealthStatus(for result: BloodTestResult, from dataPoints: [BiomarkerDataPoint]) -> HealthStatus {
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

    /// Get specific biomarker trends for detailed analysis
    /// - Parameters:
    ///   - testName: Name of the test to analyze
    ///   - bloodReports: Array of blood reports
    /// - Returns: BiomarkerTrends object if found
    static func getBiomarkerTrends(
        for testName: String,
        from bloodReports: [BloodReport]
    ) -> BiomarkerTrends? {

        let engine = BiomarkerEngine()
        let testGroups = engine.groupTestResultsByName(from: bloodReports)

        let normalizedTestName = testName.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard let results = testGroups[normalizedTestName],
              let aggregatedBiomarker = engine.createAggregatedBiomarker(from: results) else {
            return nil
        }

        return BiomarkerTrends(
            currentValue: aggregatedBiomarker.currentNumericValue,
            currentValueText: aggregatedBiomarker.currentValue,
            comparisonText: aggregatedBiomarker.trendText,
            comparisonPercentage: aggregatedBiomarker.trendPercentage,
            trendDirection: aggregatedBiomarker.trendDirection,
            normalRange: aggregatedBiomarker.referenceRange
        )
    }

    /// Extract all test results from blood reports
    /// - Parameter reports: Blood reports to process
    /// - Returns: Flattened array of test results
    static func extractTestResults(from reports: [BloodReport]) -> [BloodTestResult] {
        return reports.flatMap { $0.testResults ?? [] }
    }

    /// Validate blood reports and return only valid ones
    /// - Parameter reports: Blood reports to validate
    /// - Returns: Array of valid blood reports
    static func validateBloodReports(_ reports: [BloodReport]) -> [BloodReport] {
        let engine = BiomarkerEngine()
        return engine.validateBloodReports(reports)
    }
}