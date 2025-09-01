//
//  BiomarkerDetailViewModel.swift
//  WalnutDesignSystem
//
//  Created by Mayank Gandhi on 30/08/25.
//  Copyright © 2025 m. All rights reserved.
//

import SwiftUI
import Foundation
import Observation

public struct DataPoint: Identifiable {
    public let id = UUID()
    public let date: Date
    public let value: Double
    public let isAbnormal: Bool
    public let bloodReport: String
    
    public init(date: Date, value: Double, isAbnormal: Bool, bloodReport: String) {
        self.date = date
        self.value = value
        self.isAbnormal = isAbnormal
        self.bloodReport = bloodReport
    }
}

@Observable
public class BiomarkerDetailViewModel {
    
    // MARK: - Published Properties
    var selectedTimeFrame: TimeFrame = .all
    var filteredDataPoints: [DataPoint] = []
    var selectedDataPoint: DataPoint?
    var currentValue: Double = 0.0
    var trendPercentage: Double = 0.0
    var trendDirection: TrendDirection = .stable
    var healthStatus: HealthStatus = .good
    var animateChart = false
    
    // MARK: - Private Properties
    private let biomarkerName: String
    private let unit: String
    private let normalRange: String
    private let description: String
    private let allDataPoints: [DataPoint]
    private let color: Color
    
    // MARK: - Computed Properties
    
    var formattedCurrentValue: String {
        return String(format: "%.1f", currentValue)
    }
    
    var formattedTrendPercentage: String {
        return String(format: "%.1f%%", trendPercentage)
    }
    
    var trendColor: Color {
        switch trendDirection {
        case .up:
            return healthStatus == .critical || healthStatus == .warning ? .healthError : .healthSuccess
        case .down:
            return healthStatus == .critical || healthStatus == .warning ? .healthSuccess : .healthError
        case .stable:
            return .gray
        }
    }
    
    var trendIcon: String {
        switch trendDirection {
        case .up: return "arrow.up"
        case .down: return "arrow.down"
        case .stable: return "minus"
        }
    }
    
    var healthStatusColor: Color {
        healthStatus.color
    }
    
    var healthStatusIcon: String {
        healthStatus.icon
    }
    
    var healthStatusText: String {
        healthStatus.displayName
    }
    
    // MARK: - Initializer
    
    public init(
        biomarkerName: String,
        unit: String,
        normalRange: String,
        description: String,
        dataPoints: [DataPoint],
        color: Color
    ) {
        self.biomarkerName = biomarkerName
        self.unit = unit
        self.normalRange = normalRange
        self.description = description
        self.allDataPoints = dataPoints.sorted { $0.date < $1.date }
        self.color = color
        
        // Initial data processing
        filterDataPoints()
        calculateCurrentMetrics()
    }
    
    // MARK: - Public Methods
    
    func updateTimeFrame(_ timeFrame: TimeFrame) {
        selectedTimeFrame = timeFrame
        filterDataPoints()
        calculateCurrentMetrics()
    }
    
    func selectDataPoint(_ dataPoint: DataPoint?) {
        selectedDataPoint = dataPoint
    }
    
    func startChartAnimation() {
        withAnimation(.easeInOut(duration: 1.0)) {
            animateChart = true
        }
    }
    
    // MARK: - Public Computed Properties
    
    var biomarkerTitle: String {
        biomarkerName
    }
    
    var unitText: String {
        unit
    }
    
    var normalRangeText: String {
        normalRange
    }
    
    var descriptionText: String {
        description
    }
    
    var primaryColor: Color {
        color
    }
    
    var currentDataPoint: DataPoint? {
        filteredDataPoints.last
    }
    
    var availableTimeFrames: [TimeFrame] {
        guard let oldestDate = allDataPoints.first?.date else { return [.all] }
        
        let daysSinceOldest = Calendar.current.dateComponents([.day], from: oldestDate, to: Date()).day ?? 0
        
        var frames: [TimeFrame] = [.all]
        if daysSinceOldest >= 30 { frames.append(.oneMonth) }
        if daysSinceOldest >= 90 { frames.append(.threeMonths) }
        if daysSinceOldest >= 180 { frames.append(.sixMonths) }
        if daysSinceOldest >= 365 { frames.append(.oneYear) }
        
        return frames.reversed()
    }
    
    // MARK: - Private Methods
    
    private func filterDataPoints() {
        let now = Date()
        
        switch selectedTimeFrame {
        case .all:
            filteredDataPoints = allDataPoints
        case .oneYear:
            let oneYearAgo = Calendar.current.date(byAdding: .year, value: -1, to: now) ?? now
            filteredDataPoints = allDataPoints.filter { $0.date >= oneYearAgo }
        case .sixMonths:
            let sixMonthsAgo = Calendar.current.date(byAdding: .month, value: -6, to: now) ?? now
            filteredDataPoints = allDataPoints.filter { $0.date >= sixMonthsAgo }
        case .threeMonths:
            let threeMonthsAgo = Calendar.current.date(byAdding: .month, value: -3, to: now) ?? now
            filteredDataPoints = allDataPoints.filter { $0.date >= threeMonthsAgo }
        case .oneMonth:
            let oneMonthAgo = Calendar.current.date(byAdding: .month, value: -1, to: now) ?? now
            filteredDataPoints = allDataPoints.filter { $0.date >= oneMonthAgo }
        }
    }
    
    private func calculateCurrentMetrics() {
        guard let latestPoint = filteredDataPoints.last else {
            currentValue = 0.0
            trendPercentage = 0.0
            trendDirection = .stable
            healthStatus = .good
            return
        }
        
        currentValue = latestPoint.value
        healthStatus = determineHealthStatus(for: latestPoint.value)
        
        // Calculate trend
        if filteredDataPoints.count >= 2 {
            let previousPoint = filteredDataPoints[filteredDataPoints.count - 2]
            let change = currentValue - previousPoint.value
            let percentageChange = abs(change / previousPoint.value * 100)
            
            trendPercentage = percentageChange
            
            if abs(change) < 0.01 {
                trendDirection = .stable
            } else if change > 0 {
                trendDirection = .up
            } else {
                trendDirection = .down
            }
        } else {
            trendPercentage = 0.0
            trendDirection = .stable
        }
    }
    
    private func determineHealthStatus(for value: Double) -> HealthStatus {
        // Parse normal range if available
        guard !normalRange.isEmpty && normalRange != "N/A" else {
            return .good
        }
        
        // Simple range parsing - this could be made more sophisticated
        let components = normalRange.components(separatedBy: "-")
        if components.count == 2,
           let lowerBound = Double(components[0].trimmingCharacters(in: .whitespaces)),
           let upperBound = Double(components[1].trimmingCharacters(in: .whitespaces)) {
            
            if value < lowerBound * 0.8 || value > upperBound * 1.2 {
                return .critical
            } else if value < lowerBound || value > upperBound {
                return .warning
            } else if value >= lowerBound * 0.9 && value <= upperBound * 0.9 {
                return .optimal
            } else {
                return .good
            }
        }
        
        return .good
    }
}

// MARK: - Supporting Types

public enum TimeFrame: String, CaseIterable {
    case oneMonth = "1M"
    case threeMonths = "3M"
    case sixMonths = "6M"
    case oneYear = "1Y"
    case all = "All"
    
    public var displayName: String {
        switch self {
        case .oneMonth: return "1 Month"
        case .threeMonths: return "3 Months"
        case .sixMonths: return "6 Months"
        case .oneYear: return "1 Year"
        case .all: return "All Time"
        }
    }
    
    public var dateRange: TimeInterval? {
        switch self {
        case .oneMonth: return 30 * 24 * 60 * 60
        case .threeMonths: return 90 * 24 * 60 * 60
        case .sixMonths: return 180 * 24 * 60 * 60
        case .oneYear: return 365 * 24 * 60 * 60
        case .all: return nil
        }
    }
}

public enum TrendDirection {
    case up, down, stable
    
    public var iconName: String {
        switch self {
        case .up: return "arrow.up.right"
        case .down: return "arrow.down.right"
        case .stable: return "arrow.right"
        }
    }
    
    public var color: Color {
        switch self {
        case .up: return .healthSuccess
        case .down: return .healthError
        case .stable: return .secondary
        }
    }
}

