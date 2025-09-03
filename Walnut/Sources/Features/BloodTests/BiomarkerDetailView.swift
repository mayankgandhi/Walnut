//
//  BiomarkerDetailView.swift
//  WalnutDesignSystem
//
//  Created by Mayank Gandhi on 08/08/25.
//  Copyright © 2025 m. All rights reserved.
//

import SwiftUI
import Charts
import WalnutDesignSystem

/// Full-screen biomarker detail view with chart and metrics
public struct BiomarkerDetailView: View {
    
    @State var viewModel: BiomarkerDetailViewModel
    
    public init(
        biomarkerName: String,
        unit: String,
        normalRange: String,
        dataPoints: [BiomarkerDataPoint],
        color: Color = Color.healthPrimary
    ) {
        self._viewModel = State(wrappedValue: BiomarkerDetailViewModel(
            biomarkerName: biomarkerName,
            unit: unit,
            normalRange: normalRange,
            dataPoints: dataPoints,
            color: color
        ))
    }
    
    // Convenience initializer for BloodTestResults
    public init(
        testName: String,
        bloodTestResults: [Any], // BloodTestResult array - using Any to avoid import issues
        color: Color = .healthPrimary
    ) {
        // Note: In real implementation, would convert bloodTestResults to DataPoint
        self._viewModel = State(wrappedValue: BiomarkerDetailViewModel(
            biomarkerName: testName,
            unit: "",
            normalRange: "",
            dataPoints: [],
            color: color
        ))
    }
    
    
    public var body: some View {
        ScrollView {
            VStack(spacing: Spacing.large) {
                // Hero section with current value and trend
                heroSection
                
                // Information section
                informationSection
                
                // Chart section with enhanced visualization
                chartSection
                
                // Time frame selector
                timeFrameSelector

                // Metrics cards
                metricsSection
                                
                // Historical data section
                if viewModel.filteredDataPoints.count > 1 {
                    historicalDataSection
                }
            }
            .padding(.horizontal, Spacing.medium)
            .padding(.bottom, Spacing.xl)
        }
        .background(Color(UIColor.systemGroupedBackground))
        .navigationTitle(viewModel.biomarkerTitle)
        .navigationBarTitleDisplayMode(.large)
        .onAppear {
            Task {
                try await Task.sleep(nanoseconds: 2_000_000_000)
                withAnimation(.easeInOut(duration: 1.0)) {
                    viewModel.animateChart = true
                }
            }
        }
    }
    
    // MARK: - Hero Section
    private var heroSection: some View {
        HealthCard {
            VStack(spacing: Spacing.medium) {
                // Current value display
                HStack {
                    VStack(alignment: .leading, spacing: Spacing.xs) {
                        Text("Latest Value")
                            .font(.caption.weight(.medium))
                            .foregroundStyle(.secondary)
                        
                        HStack(alignment: .center, spacing: Spacing.xs) {
                            Text(viewModel.formattedCurrentValue)
                                .font(
                                    .system(
                                        .title,
                                        design: .rounded,
                                        weight: .black
                                    )
                                )
                                .foregroundStyle(viewModel.primaryColor)
                                .contentTransition(.numericText())
                            
                            Text(viewModel.unitText)
                                .font(
                                    .system(
                                        .subheadline,
                                        design: .rounded,
                                        weight: .black
                                    )
                                )
                                .foregroundStyle(.secondary)
                        }
                    }
                    
                    Spacer()
                    
                    // Health status indicator
                    VStack(spacing: Spacing.xs) {
                        Circle()
                            .fill(viewModel.healthStatusColor)
                            .frame(width: 24, height: 24)
                            .overlay {
                                Image(systemName: viewModel.healthStatusIcon)
                                    .font(.caption.weight(.bold))
                                    .foregroundStyle(.white)
                            }
                        
                        Text(viewModel.healthStatusText)
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(viewModel.healthStatusColor)
                    }
                }
                
                // Trend information
                if viewModel.filteredDataPoints.count >= 2 {
                    HStack {
                        HStack(spacing: Spacing.xs) {
                            Image(systemName: viewModel.trendDirection.iconName)
                                .font(.caption.weight(.medium))
                                .foregroundStyle(viewModel.trendColor)
                            
                            Text(String(format: "%.1f", abs(viewModel.currentValue - (viewModel.filteredDataPoints.count >= 2 ? viewModel.filteredDataPoints[viewModel.filteredDataPoints.count - 2].value : 0))))
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(viewModel.trendColor)
                            
                            Text("(\(viewModel.formattedTrendPercentage))")
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
        HealthCard {
            VStack(alignment: .leading, spacing: Spacing.small) {
                Text("Time Range")
                    .font(.caption.weight(.medium))
                    .foregroundStyle(.secondary)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: Spacing.small) {
                        ForEach(viewModel.availableTimeFrames, id: \.self) { timeFrame in
                            Button(action: {
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    viewModel.updateTimeFrame(timeFrame)
                                }
                            }) {
                                VStack(spacing: 2) {
                                    Text(timeFrame.rawValue)
                                        .font(.caption.weight(.semibold))
                                        .foregroundStyle(viewModel.selectedTimeFrame == timeFrame ? .white : viewModel.primaryColor)
                                    
                                    Text(timeFrame.displayName)
                                        .font(.caption2)
                                        .foregroundStyle(viewModel.selectedTimeFrame == timeFrame ? .white.opacity(0.8) : .secondary)
                                }
                                .padding(.horizontal, Spacing.small)
                                .padding(.vertical, 6)
                                .background(
                                    RoundedRectangle(cornerRadius: 6)
                                        .fill(viewModel.selectedTimeFrame == timeFrame ? viewModel.primaryColor : Color.clear)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 6)
                                                .stroke(viewModel.primaryColor.opacity(0.3), lineWidth: 1)
                                        )
                                )
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(.horizontal, 1)
                }
                
                if !viewModel.filteredDataPoints.isEmpty {
                    Text("\(viewModel.filteredDataPoints.count) readings")
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                }
            }
        }
    }
    
    // MARK: - Chart Section
    private var chartSection: some View {
        HealthCard {
            
            // Enhanced chart
            EnhancedBiomarkerChart(
                dataPoints: viewModel.filteredDataPoints.map { point in
                    BiomarkerDataPoint(
                        date: point.date,
                        value: point.value,
                        bloodReport: point.bloodReport,
                        bloodReportURLPath: nil
                    )
                },
                color: viewModel.primaryColor,
                normalRange: viewModel.normalRangeText,
                selectedDataPoint: Binding<BiomarkerDataPoint?>(
                    get: {
                        guard let selected = viewModel.selectedDataPoint else { return nil }
                        return BiomarkerDataPoint(
                            date: selected.date,
                            value: selected.value,
                            bloodReport: selected.bloodReport,
                            bloodReportURLPath: nil
                        )
                    },
                    set: { newValue in
                        if let chartPoint = newValue {
                            // Find the corresponding dataPoint in our array
                            let dataPoint = viewModel.filteredDataPoints.first { point in
                                point.date == chartPoint.date &&
                                point.value == chartPoint.value &&
                                point.bloodReport == chartPoint.bloodReport
                            }
                            viewModel.selectDataPoint(dataPoint)
                        } else {
                            viewModel.selectDataPoint(nil)
                        }
                    }
                ),
                animateChart: viewModel.animateChart
            )
            .frame(height: 280)
            
            VStack(alignment: .leading, spacing: Spacing.medium) {
                // Chart header
                HStack {
                    VStack(alignment: .leading, spacing: Spacing.xs) {
                        Text("Trend Analysis")
                            .font(.headline.weight(.bold))
                            .foregroundStyle(.primary)
                        
                        Text("\(viewModel.filteredDataPoints.count) readings over time")
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
                                .fill(viewModel.primaryColor)
                                .frame(width: 8, height: 8)
                            Text("Your Values")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                
                // Chart insights
                if let selectedDataPoint = viewModel.selectedDataPoint {
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
            
            HealthCard {
                VStack(spacing: Spacing.xs) {
                    Text("Normal Range")
                        .font(.caption.weight(.medium))
                        .foregroundStyle(.secondary)
                    
                    Text(viewModel.normalRangeText)
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(.primary)
                        .multilineTextAlignment(.center)
                    
                    Text(viewModel.unitText)
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                }
            }
            
            HealthCard {
                VStack(spacing: Spacing.xs) {
                    Text("Status")
                        .font(.caption.weight(.medium))
                        .foregroundStyle(.secondary)
                    
                    Text(viewModel.healthStatusText)
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(viewModel.healthStatusColor)
                    
                    Text("needs attention")
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                        .multilineTextAlignment(.center)
                }
            }
            
            HealthCard {
                VStack(spacing: Spacing.xs) {
                    Text("Readings")
                        .font(.caption.weight(.medium))
                        .foregroundStyle(.secondary)
                    
                    Text("\(viewModel.filteredDataPoints.count)")
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
        HealthCard {
            
            VStack(alignment: .leading, spacing: Spacing.small) {
                HStack {
                    Image(systemName: "ruler")
                        .font(.caption)
                        .foregroundStyle(Color.healthPrimary)
                        .frame(width: 20)
                    
                    Text("Reference Range:")
                        .font(.caption.weight(.medium))
                        .foregroundStyle(.secondary)
                    
                    Text("\(viewModel.normalRangeText) \(viewModel.unitText)")
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
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    // MARK: - Historical Data Section
    private var historicalDataSection: some View {
        HealthCard {
            VStack(alignment: .leading, spacing: Spacing.medium) {
                Text("Recent Readings")
                    .font(.headline.weight(.bold))
                    .foregroundStyle(.primary)
                
                VStack(spacing: Spacing.small) {
                    ForEach(Array(viewModel.filteredDataPoints.reversed().prefix(5))) { dataPoint in
                        let isInRange = isValueInNormalRange(dataPoint.value, normalRange: parseNormalRange(viewModel.normalRangeText))
                        let isLatest = dataPoint.id == viewModel.filteredDataPoints.last?.id
                        
                        HStack {
                            Circle()
                                .fill(isInRange ? Color.healthSuccess : Color.healthError)
                                .frame(width: 8, height: 8)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text(dataPoint.date.formatted(date: .abbreviated, time: .omitted))
                                    .font(.subheadline.weight(.medium))
                                    .foregroundStyle(.primary)
                                
                                if let bloodReport = dataPoint.bloodReport {
                                    Text(bloodReport)
                                        .font(.caption)
                                        .foregroundStyle(.tertiary)
                                }
                                
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
                            
                            Text("\(String(format: "%.1f", dataPoint.value)) \(viewModel.unitText)")
                                .font(.subheadline.weight(.bold))
                                .foregroundStyle(.primary)
                        }
                        .padding(.vertical, 2)
                    }
                    
                    if viewModel.filteredDataPoints.count > 5 {
                        HStack {
                            Text("And \(viewModel.filteredDataPoints.count - 5) more readings in this timeframe...")
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
        let normalRange = parseNormalRange(viewModel.normalRangeText)
        let isInRange = isValueInNormalRange(dataPoint.value, normalRange: normalRange)
        
        return VStack(spacing: Spacing.xs) {
            HStack {
                Text(dataPoint.date.formatted(date: .abbreviated, time: .omitted))
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                
                Spacer()
                
                Text("\(String(format: "%.1f", dataPoint.value)) \(viewModel.unitText)")
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
    
    // MARK: - Helper Functions
    
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
            dataPoints: [
                BiomarkerDataPoint(
                    date: Calendar.current.date(byAdding: .month, value: -6, to: Date()) ?? Date(),
                    value: 13.8,
                    
                    bloodReport: "LabCorp",
                    bloodReportURLPath: nil
                ),
                BiomarkerDataPoint(
                    date: Calendar.current.date(byAdding: .month, value: -5, to: Date()) ?? Date(),
                    value: 12.5,
                    
                    bloodReport: "Quest Diagnostics",
                    bloodReportURLPath: nil
                ),
                BiomarkerDataPoint(
                    date: Calendar.current.date(byAdding: .month, value: -4, to: Date()) ?? Date(),
                    value: 14.5,
                    
                    bloodReport: "LabCorp",
                    bloodReportURLPath: nil
                ),
                BiomarkerDataPoint(
                    date: Calendar.current.date(byAdding: .month, value: -3, to: Date()) ?? Date(),
                    value: 14.1,
                    
                    bloodReport: "Hospital Lab",
                    bloodReportURLPath: nil
                ),
                BiomarkerDataPoint(
                    date: Calendar.current.date(byAdding: .month, value: -2, to: Date()) ?? Date(),
                    value: 14.3,
                    
                    bloodReport: "Quest Diagnostics",
                    bloodReportURLPath: nil
                ),
                BiomarkerDataPoint(
                    date: Calendar.current.date(byAdding: .month, value: -1, to: Date()) ?? Date(),
                    value: 13.8,
                    
                    bloodReport: "LabCorp",
                    bloodReportURLPath: nil
                ),
                BiomarkerDataPoint(
                    date: Date(),
                    value: 14.2,
                    
                    bloodReport: "LabCorp",
                    bloodReportURLPath: nil
                )
            ],
            color: .healthPrimary
        )
    }
}
