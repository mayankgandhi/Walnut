//
//  BiomarkerDetailView.swift
//  WalnutDesignSystem
//
//  Created by Mayank Gandhi on 08/08/25.
//  Copyright © 2025 m. All rights reserved.
//

import SwiftUI
import Charts

/// Full-screen biomarker detail view with chart and metrics
public struct BiomarkerDetailView: View {
    // Historical data model
    public struct BiomarkerDataPoint: Identifiable {
        public let id = UUID()
        public let date: Date
        public let value: Double
        public let isAbnormal: Bool
        public let bloodReport: String // Lab name for context
        
        public init(date: Date, value: Double, isAbnormal: Bool, bloodReport: String) {
            self.date = date
            self.value = value
            self.isAbnormal = isAbnormal
            self.bloodReport = bloodReport
        }
    }
    
    // Time frame options
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
    
    private let biomarkerName: String
    private let unit: String
    private let normalRange: String
    private let description: String
    private let dataPoints: [BiomarkerDataPoint]
    private let color: Color
    
    @State private var animateChart = false
    @State private var selectedDataPoint: BiomarkerDataPoint?
    @State private var selectedTimeFrame: TimeFrame = .all
    
    public init(
        biomarkerName: String,
        unit: String,
        normalRange: String,
        description: String,
        dataPoints: [BiomarkerDataPoint],
        color: Color = .healthPrimary
    ) {
        self.biomarkerName = biomarkerName
        self.unit = unit
        self.normalRange = normalRange
        self.description = description
        self.dataPoints = dataPoints.sorted { $0.date < $1.date }
        self.color = color
    }
    
    // Convenience initializer for BloodTestResults
    public init(
        testName: String,
        bloodTestResults: [Any], // BloodTestResult array - using Any to avoid import issues
        color: Color = .healthPrimary
    ) {
        self.biomarkerName = testName
        self.unit = "" // Will be extracted from first result
        self.normalRange = "" // Will be extracted from first result  
        self.description = "Blood test biomarker for health monitoring"
        self.dataPoints = [] // Will be populated from results
        self.color = color
        
        // Note: In real implementation, would convert bloodTestResults to BiomarkerDataPoint
        // This is a placeholder for the structure
    }
    
    // Computed properties for filtered data
    private var filteredDataPoints: [BiomarkerDataPoint] {
        guard let timeRange = selectedTimeFrame.dateRange else {
            return dataPoints
        }
        
        let cutoffDate = Date().addingTimeInterval(-timeRange)
        return dataPoints.filter { $0.date >= cutoffDate }
    }
    
    private var currentValue: BiomarkerDataPoint? {
        filteredDataPoints.last
    }
    
    private var availableTimeFrames: [TimeFrame] {
        guard let oldestDate = dataPoints.first?.date else { return [.all] }
        
        let daysSinceOldest = Calendar.current.dateComponents([.day], from: oldestDate, to: Date()).day ?? 0
        
        var frames: [TimeFrame] = [.all]
        if daysSinceOldest >= 30 { frames.append(.oneMonth) }
        if daysSinceOldest >= 90 { frames.append(.threeMonths) }
        if daysSinceOldest >= 180 { frames.append(.sixMonths) }
        if daysSinceOldest >= 365 { frames.append(.oneYear) }
        
        return frames.reversed()
    }
    
    public var body: some View {
        ScrollView {
            VStack(spacing: Spacing.large) {
                // Hero section with current value and trend
                heroSection
                
                // Time frame selector
                timeFrameSelector
                
                // Chart section with enhanced visualization
                chartSection
                
                // Metrics cards
                metricsSection
                
                // Information section
                informationSection
                
                // Historical data section
                if filteredDataPoints.count > 1 {
                    historicalDataSection
                }
            }
            .padding(.horizontal, Spacing.medium)
            .padding(.bottom, Spacing.xl)
        }
        .background(Color(UIColor.systemGroupedBackground))
        .navigationTitle(biomarkerName)
        .navigationBarTitleDisplayMode(.large)
        .onAppear {
            withAnimation(.easeInOut(duration: 1.0)) {
                animateChart = true
            }
        }
    }
    
    // MARK: - Hero Section
    private var heroSection: some View {
        HealthCard(padding: Spacing.large) {
            VStack(spacing: Spacing.medium) {
                // Current value display
                HStack {
                    VStack(alignment: .leading, spacing: Spacing.xs) {
                        Text("Current Value")
                            .font(.caption.weight(.medium))
                            .foregroundStyle(.secondary)
                        
                        HStack(alignment: .firstTextBaseline, spacing: Spacing.xs) {
                            Text(currentValue?.value.formatted(.number.precision(.fractionLength(1))) ?? "--")
                                .font(.system(size: 48, weight: .bold, design: .rounded))
                                .foregroundStyle(color)
                                .contentTransition(.numericText())
                            
                            Text(unit)
                                .font(.title3.weight(.medium))
                                .foregroundStyle(.secondary)
                                .offset(y: -8)
                        }
                    }
                    
                    Spacer()
                    
                    // Health status indicator
                    VStack(spacing: Spacing.xs) {
                        Circle()
                            .fill(healthStatusColor)
                            .frame(width: 24, height: 24)
                            .overlay {
                                Image(systemName: healthStatusIcon)
                                    .font(.caption.weight(.bold))
                                    .foregroundStyle(.white)
                            }
                        
                        Text(healthStatusText)
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(healthStatusColor)
                    }
                }
                
                // Trend information
                if let trendInfo = calculateTrend() {
                    HStack {
                        HStack(spacing: Spacing.xs) {
                            Image(systemName: trendInfo.direction.iconName)
                                .font(.caption.weight(.medium))
                                .foregroundStyle(trendInfo.direction.color)
                            
                            Text(trendInfo.changeText)
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(trendInfo.direction.color)
                            
                            Text("(\(trendInfo.percentageText))")
                                .font(.caption.weight(.medium))
                                .foregroundStyle(.secondary)
                            
                            Text("from last reading")
                                .font(.caption)
                                .foregroundStyle(.tertiary)
                        }
                        
                        Spacer()
                    }
                }
            }
        }
    }
    
    // MARK: - Time Frame Selector
    private var timeFrameSelector: some View {
        HealthCard(padding: Spacing.medium) {
            VStack(alignment: .leading, spacing: Spacing.small) {
                Text("Time Range")
                    .font(.caption.weight(.medium))
                    .foregroundStyle(.secondary)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: Spacing.small) {
                        ForEach(availableTimeFrames, id: \.self) { timeFrame in
                            Button(action: {
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    selectedTimeFrame = timeFrame
                                }
                            }) {
                                VStack(spacing: 2) {
                                    Text(timeFrame.rawValue)
                                        .font(.caption.weight(.semibold))
                                        .foregroundStyle(selectedTimeFrame == timeFrame ? .white : color)
                                    
                                    Text(timeFrame.displayName)
                                        .font(.caption2)
                                        .foregroundStyle(selectedTimeFrame == timeFrame ? .white.opacity(0.8) : .secondary)
                                }
                                .padding(.horizontal, Spacing.small)
                                .padding(.vertical, 6)
                                .background(
                                    RoundedRectangle(cornerRadius: 6)
                                        .fill(selectedTimeFrame == timeFrame ? color : Color.clear)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 6)
                                                .stroke(color.opacity(0.3), lineWidth: 1)
                                        )
                                )
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(.horizontal, 1)
                }
                
                if !filteredDataPoints.isEmpty {
                    Text("\(filteredDataPoints.count) readings")
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                }
            }
        }
    }
    
    // MARK: - Chart Section
    private var chartSection: some View {
        HealthCard(padding: Spacing.large) {
            VStack(alignment: .leading, spacing: Spacing.medium) {
                // Chart header
                HStack {
                    VStack(alignment: .leading, spacing: Spacing.xs) {
                        Text("Trend Analysis")
                            .font(.headline.weight(.bold))
                            .foregroundStyle(.primary)
                        
                        Text("\(dataPoints.count) readings over time")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    
                    Spacer()
                    
                    // Legend
                    HStack(spacing: Spacing.small) {
                        HStack(spacing: 4) {
                            Circle()
                                .fill(Color.healthSuccess.opacity(0.3))
                                .frame(width: 8, height: 8)
                            Text("Normal Range")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        
                        HStack(spacing: 4) {
                            Circle()
                                .fill(color)
                                .frame(width: 8, height: 8)
                            Text("Your Values")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                
                // Enhanced chart
                EnhancedBiomarkerChart(
                    dataPoints: filteredDataPoints.map { point in
                        EnhancedBiomarkerChart.BiomarkerDataPoint(
                            date: point.date,
                            value: point.value,
                            isAbnormal: point.isAbnormal,
                            bloodReport: point.bloodReport
                        )
                    },
                    color: color,
                    normalRange: normalRange,
                    selectedDataPoint: Binding<EnhancedBiomarkerChart.BiomarkerDataPoint?>(
                        get: {
                            guard let selected = selectedDataPoint else { return nil }
                            return EnhancedBiomarkerChart.BiomarkerDataPoint(
                                date: selected.date,
                                value: selected.value,
                                isAbnormal: selected.isAbnormal,
                                bloodReport: selected.bloodReport
                            )
                        },
                        set: { newValue in
                            if let chartPoint = newValue {
                                // Find the corresponding dataPoint in our array
                                selectedDataPoint = filteredDataPoints.first { point in
                                    point.date == chartPoint.date && 
                                    point.value == chartPoint.value &&
                                    point.bloodReport == chartPoint.bloodReport
                                }
                            } else {
                                selectedDataPoint = nil
                            }
                        }
                    ),
                    animateChart: animateChart
                )
                .frame(height: 280)
                
                // Chart insights
                if let selectedDataPoint = selectedDataPoint {
                    chartInsights(for: selectedDataPoint)
                } else {
                    defaultChartInsights
                }
            }
        }
    }
    
    
    // MARK: - Metrics Section
    private var metricsSection: some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: Spacing.medium) {
            
            HealthCard(padding: Spacing.medium) {
                VStack(spacing: Spacing.xs) {
                    Text("Normal Range")
                        .font(.caption.weight(.medium))
                        .foregroundStyle(.secondary)
                    
                    Text(normalRange)
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(.primary)
                        .multilineTextAlignment(.center)
                    
                    Text(unit)
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                }
            }
            
            HealthCard(padding: Spacing.medium) {
                VStack(spacing: Spacing.xs) {
                    Text("Status")
                        .font(.caption.weight(.medium))
                        .foregroundStyle(.secondary)
                    
                    Text(healthStatusText)
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(healthStatusColor)
                    
                    Text(healthStatusSubtext)
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                        .multilineTextAlignment(.center)
                }
            }
            
            HealthCard(padding: Spacing.medium) {
                VStack(spacing: Spacing.xs) {
                    Text("Readings")
                        .font(.caption.weight(.medium))
                        .foregroundStyle(.secondary)
                    
                    Text("\(filteredDataPoints.count)")
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(.primary)
                    
                    Text("in timeframe")
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                }
            }
        }
    }
    
    // MARK: - Information Section
    private var informationSection: some View {
        HealthCard(padding: Spacing.large) {
            VStack(alignment: .leading, spacing: Spacing.medium) {
                Text("About \(biomarkerName)")
                    .font(.headline.weight(.bold))
                    .foregroundStyle(.primary)
                
                Text(description)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
                
                Divider()
                
                VStack(alignment: .leading, spacing: Spacing.small) {
                    HStack {
                        Image(systemName: "ruler")
                            .font(.caption)
                            .foregroundStyle(Color.healthPrimary)
                            .frame(width: 20)
                        
                        Text("Reference Range:")
                            .font(.caption.weight(.medium))
                            .foregroundStyle(.secondary)
                        
                        Text("\(normalRange) \(unit)")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.primary)
                    }
                    
                    HStack {
                        Image(systemName: "calendar")
                            .font(.caption)
                            .foregroundStyle(Color.healthPrimary)
                            .frame(width: 20)
                        
                        Text("Frequency:")
                            .font(.caption.weight(.medium))
                            .foregroundStyle(.secondary)
                        
                        Text("Regular monitoring recommended")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.primary)
                    }
                }
            }
        }
    }
    
    // MARK: - Historical Data Section
    private var historicalDataSection: some View {
        HealthCard(padding: Spacing.large) {
            VStack(alignment: .leading, spacing: Spacing.medium) {
                Text("Recent Readings")
                    .font(.headline.weight(.bold))
                    .foregroundStyle(.primary)
                
                VStack(spacing: Spacing.small) {
                    ForEach(Array(filteredDataPoints.reversed().prefix(5))) { dataPoint in
                        let isInRange = isValueInNormalRange(dataPoint.value, normalRange: parseNormalRange(normalRange))
                        let isLatest = dataPoint.id == filteredDataPoints.last?.id
                        
                        HStack {
                            Circle()
                                .fill(isInRange ? Color.healthSuccess : Color.healthError)
                                .frame(width: 8, height: 8)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text(dataPoint.date.formatted(date: .abbreviated, time: .omitted))
                                    .font(.subheadline.weight(.medium))
                                    .foregroundStyle(.primary)
                                
                                Text(dataPoint.bloodReport)
                                    .font(.caption)
                                    .foregroundStyle(.tertiary)
                            }
                            
                            if isLatest {
                                Text("Latest")
                                    .font(.caption.weight(.medium))
                                    .foregroundStyle(Color.healthPrimary)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(Color.healthPrimary.opacity(0.1))
                                    .clipShape(Capsule())
                            }
                            
                            Spacer()
                            
                            Text("\(String(format: "%.1f", dataPoint.value)) \(unit)")
                                .font(.subheadline.weight(.bold))
                                .foregroundStyle(.primary)
                        }
                        .padding(.vertical, 2)
                    }
                    
                    if filteredDataPoints.count > 5 {
                        HStack {
                            Text("And \(filteredDataPoints.count - 5) more readings in this timeframe...")
                                .font(.caption)
                                .foregroundStyle(.tertiary)
                            Spacer()
                        }
                        .padding(.top, Spacing.xs)
                    }
                }
            }
        }
    }
    
    // MARK: - Chart Insights
    
    private func chartInsights(for dataPoint: BiomarkerDataPoint) -> some View {
        let normalRange = parseNormalRange(normalRange)
        let isInRange = isValueInNormalRange(dataPoint.value, normalRange: normalRange)
        
        return VStack(spacing: Spacing.xs) {
            HStack {
                Text(dataPoint.date.formatted(date: .abbreviated, time: .omitted))
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                
                Spacer()
                
                Text("\(String(format: "%.1f", dataPoint.value)) \(unit)")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.primary)
            }
            
            HStack {
                Circle()
                    .fill(isInRange ? Color.healthSuccess : Color.healthError)
                    .frame(width: 6, height: 6)
                
                Text(isInRange ? "Within normal range" : "Outside normal range")
                    .font(.caption2)
                    .foregroundStyle(isInRange ? Color.healthSuccess : Color.healthError)
                
                Spacer()
            }
            
            HStack {
                Text("Lab: \(dataPoint.bloodReport)")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
                
                Spacer()
            }
        }
        .padding(.top, Spacing.xs)
    }
    
    private var defaultChartInsights: some View {
        VStack(spacing: Spacing.xs) {
            HStack {
                Text("Tap any point for details")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
                
                Spacer()
            }
        }
        .padding(.top, Spacing.xs)
    }
    
    // MARK: - Helper Functions & Computed Properties
    
    // Trend direction enum
    private enum TrendDirection {
        case up, down, stable
        
        var iconName: String {
            switch self {
            case .up: return "arrow.up.right"
            case .down: return "arrow.down.right"
            case .stable: return "arrow.right"
            }
        }
        
        var color: Color {
            switch self {
            case .up: return .healthSuccess
            case .down: return .healthError
            case .stable: return .secondary
            }
        }
    }
    
    // Trend calculation
    private struct TrendInfo {
        let direction: TrendDirection
        let changeText: String
        let percentageText: String
    }
    
    private func calculateTrend() -> TrendInfo? {
        guard filteredDataPoints.count >= 2 else { return nil }
        
        let current = filteredDataPoints.last!.value
        let previous = filteredDataPoints[filteredDataPoints.count - 2].value
        let change = current - previous
        let percentageChange = abs(change / previous * 100)
        
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
        
        return TrendInfo(direction: direction, changeText: changeText, percentageText: percentageText)
    }
    
    private var healthStatusColor: Color {
        guard let currentValue = currentValue else { return Color.healthPrimary }
        let normalRange = parseNormalRange(normalRange)
        
        if isValueInNormalRange(currentValue.value, normalRange: normalRange) {
            return Color.healthSuccess
        } else {
            return Color.healthError
        }
    }
    
    private var healthStatusIcon: String {
        guard let currentValue = currentValue else { return "questionmark" }
        let normalRange = parseNormalRange(normalRange)
        
        if isValueInNormalRange(currentValue.value, normalRange: normalRange) {
            return "checkmark"
        } else {
            return "exclamationmark"
        }
    }
    
    private var healthStatusText: String {
        guard let currentValue = currentValue else { return "Unknown" }
        let normalRange = parseNormalRange(normalRange)
        
        if isValueInNormalRange(currentValue.value, normalRange: normalRange) {
            return "Normal"
        } else {
            return "Abnormal"
        }
    }
    
    private var healthStatusSubtext: String {
        guard let currentValue = currentValue else { return "no data" }
        let normalRange = parseNormalRange(normalRange)
        
        if isValueInNormalRange(currentValue.value, normalRange: normalRange) {
            return "within range"
        } else {
            return "needs attention"
        }
    }
    
    // Helper function to parse normal range string (reused from BiomarkerListItemView)
    private func parseNormalRange(_ rangeString: String) -> (min: Double, max: Double)? {
        let cleanRange = rangeString.trimmingCharacters(in: .whitespaces)
        
        if cleanRange.contains("-") {
            let components = cleanRange.components(separatedBy: "-")
            if components.count == 2,
               let min = Double(components[0].trimmingCharacters(in: .whitespaces)),
               let max = Double(components[1].trimmingCharacters(in: .whitespaces)) {
                return (min: min, max: max)
            }
        } else if cleanRange.hasPrefix("<") {
            let valueString = String(cleanRange.dropFirst()).trimmingCharacters(in: .whitespaces)
            if let maxValue = Double(valueString) {
                return (min: 0, max: maxValue)
            }
        } else if cleanRange.hasPrefix(">") {
            let valueString = String(cleanRange.dropFirst()).trimmingCharacters(in: .whitespaces)
            if let minValue = Double(valueString) {
                let maxValue = minValue * 2
                return (min: minValue, max: maxValue)
            }
        }
        
        return nil
    }
    
    // Helper function to check if value is in normal range
    private func isValueInNormalRange(_ value: Double, normalRange: (min: Double, max: Double)?) -> Bool {
        guard let range = normalRange else { return true }
        return value >= range.min && value <= range.max
    }
}

#Preview {
    NavigationStack {
        BiomarkerDetailView(
            biomarkerName: "Hemoglobin",
            unit: "g/dL",
            normalRange: "12.0-15.5",
            description: "Hemoglobin carries oxygen in red blood cells and is essential for transporting oxygen throughout the body.",
            dataPoints: [
                BiomarkerDetailView.BiomarkerDataPoint(
                    date: Calendar.current.date(byAdding: .month, value: -6, to: Date()) ?? Date(),
                    value: 13.8,
                    isAbnormal: false,
                    bloodReport: "LabCorp"
                ),
                BiomarkerDetailView.BiomarkerDataPoint(
                    date: Calendar.current.date(byAdding: .month, value: -5, to: Date()) ?? Date(),
                    value: 12.5,
                    isAbnormal: false,
                    bloodReport: "Quest Diagnostics"
                ),
                BiomarkerDetailView.BiomarkerDataPoint(
                    date: Calendar.current.date(byAdding: .month, value: -4, to: Date()) ?? Date(),
                    value: 14.5,
                    isAbnormal: false,
                    bloodReport: "LabCorp"
                ),
                BiomarkerDetailView.BiomarkerDataPoint(
                    date: Calendar.current.date(byAdding: .month, value: -3, to: Date()) ?? Date(),
                    value: 14.1,
                    isAbnormal: false,
                    bloodReport: "Hospital Lab"
                ),
                BiomarkerDetailView.BiomarkerDataPoint(
                    date: Calendar.current.date(byAdding: .month, value: -2, to: Date()) ?? Date(),
                    value: 14.3,
                    isAbnormal: false,
                    bloodReport: "Quest Diagnostics"
                ),
                BiomarkerDetailView.BiomarkerDataPoint(
                    date: Calendar.current.date(byAdding: .month, value: -1, to: Date()) ?? Date(),
                    value: 13.8,
                    isAbnormal: false,
                    bloodReport: "LabCorp"
                ),
                BiomarkerDetailView.BiomarkerDataPoint(
                    date: Date(),
                    value: 14.2,
                    isAbnormal: false,
                    bloodReport: "LabCorp"
                )
            ],
            color: .healthPrimary
        )
    }
}
