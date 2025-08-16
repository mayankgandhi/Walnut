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
    private let data: [Double]
    private let color: Color
    private let biomarkerInfo: BiomarkerInfo
    private let biomarkerTrends: BiomarkerTrends
    
    @State private var animateChart = false
    @State private var selectedDataPoint: Int?
    
    public init(
        data: [Double],
        color: Color = .healthPrimary,
        biomarkerInfo: BiomarkerInfo,
        biomarkerTrends: BiomarkerTrends
    ) {
        self.data = data
        self.color = color
        self.biomarkerInfo = biomarkerInfo
        self.biomarkerTrends = biomarkerTrends
    }
    
    public var body: some View {
        ScrollView {
            VStack(spacing: Spacing.large) {
                // Hero section with current value and trend
                heroSection
                
                // Chart section with enhanced visualization
                chartSection
                
                // Metrics cards
                metricsSection
                
                // Information section
                informationSection
                
                // Historical data section
                if data.count > 1 {
                    historicalDataSection
                }
            }
            .padding(.horizontal, Spacing.medium)
            .padding(.bottom, Spacing.xl)
        }
        .background(Color(UIColor.systemGroupedBackground))
        .navigationTitle(biomarkerInfo.name)
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
                            Text(biomarkerTrends.currentValueText)
                                .font(.system(size: 48, weight: .bold, design: .rounded))
                                .foregroundStyle(color)
                                .contentTransition(.numericText())
                            
                            Text(biomarkerInfo.unit)
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
                HStack {
                    HStack(spacing: Spacing.xs) {
                        Image(systemName: biomarkerTrends.trendDirection.iconName)
                            .font(.caption.weight(.medium))
                            .foregroundStyle(biomarkerTrends.trendDirection.color)
                        
                        Text(biomarkerTrends.comparisonText)
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(biomarkerTrends.trendDirection.color)
                        
                        Text("(\(biomarkerTrends.comparisonPercentage))")
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
                        
                        Text("\(data.count) readings over time")
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
                    data: data,
                    color: color,
                    normalRange: biomarkerTrends.normalRange,
                    selectedDataPoint: $selectedDataPoint,
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
                    
                    Text(biomarkerTrends.normalRange)
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(.primary)
                        .multilineTextAlignment(.center)
                    
                    Text(biomarkerInfo.unit)
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
                    
                    Text("\(data.count)")
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(.primary)
                    
                    Text("total")
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
                Text("About \(biomarkerInfo.name)")
                    .font(.headline.weight(.bold))
                    .foregroundStyle(.primary)
                
                Text(biomarkerInfo.description)
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
                        
                        Text("\(biomarkerTrends.normalRange) \(biomarkerInfo.unit)")
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
                Text("Historical Data")
                    .font(.headline.weight(.bold))
                    .foregroundStyle(.primary)
                
                VStack(spacing: Spacing.small) {
                    ForEach(Array(data.enumerated().reversed().prefix(5)), id: \.offset) { index, value in
                        let originalIndex = data.count - 1 - index
                        let isInRange = isValueInNormalRange(value, normalRange: parseNormalRange(biomarkerTrends.normalRange))
                        let isLatest = originalIndex == data.count - 1
                        
                        HStack {
                            Circle()
                                .fill(isInRange ? Color.healthSuccess : Color.healthError)
                                .frame(width: 8, height: 8)
                            
                            Text("Reading \(originalIndex + 1)")
                                .font(.subheadline.weight(.medium))
                                .foregroundStyle(.secondary)
                            
                            if isLatest {
                                Text("(Latest)")
                                    .font(.caption.weight(.medium))
                                    .foregroundStyle(Color.healthPrimary)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(Color.healthPrimary.opacity(0.1))
                                    .clipShape(Capsule())
                            }
                            
                            Spacer()
                            
                            Text("\(String(format: "%.1f", value)) \(biomarkerInfo.unit)")
                                .font(.subheadline.weight(.bold))
                                .foregroundStyle(.primary)
                        }
                        .padding(.vertical, 2)
                    }
                    
                    if data.count > 5 {
                        HStack {
                            Text("And \(data.count - 5) more readings...")
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
    
    private func chartInsights(for index: Int) -> some View {
        let value = data[index]
        let normalRange = parseNormalRange(biomarkerTrends.normalRange)
        let isInRange = isValueInNormalRange(value, normalRange: normalRange)
        
        return VStack(spacing: Spacing.xs) {
            HStack {
                Text("Reading \(index + 1)")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                
                Spacer()
                
                Text("\(String(format: "%.1f", value)) \(biomarkerInfo.unit)")
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
    
    private var healthStatusColor: Color {
        let normalRange = parseNormalRange(biomarkerTrends.normalRange)
        let currentValue = biomarkerTrends.currentValue
        
        if isValueInNormalRange(currentValue, normalRange: normalRange) {
            return Color.healthSuccess
        } else {
            return Color.healthError
        }
    }
    
    private var healthStatusIcon: String {
        let normalRange = parseNormalRange(biomarkerTrends.normalRange)
        let currentValue = biomarkerTrends.currentValue
        
        if isValueInNormalRange(currentValue, normalRange: normalRange) {
            return "checkmark"
        } else {
            return "exclamationmark"
        }
    }
    
    private var healthStatusText: String {
        let normalRange = parseNormalRange(biomarkerTrends.normalRange)
        let currentValue = biomarkerTrends.currentValue
        
        if isValueInNormalRange(currentValue, normalRange: normalRange) {
            return "Normal"
        } else {
            return "Abnormal"
        }
    }
    
    private var healthStatusSubtext: String {
        let normalRange = parseNormalRange(biomarkerTrends.normalRange)
        let currentValue = biomarkerTrends.currentValue
        
        if isValueInNormalRange(currentValue, normalRange: normalRange) {
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
    BiomarkerDetailView(
        data: [13.8, 12.5, 14.5, 14.1, 14.3, 13.8, 14.2],
        color: .healthPrimary,
        biomarkerInfo: BiomarkerInfo(
            name: "Hemoglobin",
            description: "Hemoglobin carries oxygen in red blood cells",
            normalRange: "12.0-15.5",
            unit: "g/dL"
        ),
        biomarkerTrends: BiomarkerTrends(
            currentValue: 14.2,
            currentValueText: "14.2",
            comparisonText: "0.4 g/dL",
            comparisonPercentage: "3%",
            trendDirection: .up,
            normalRange: "12.0-15.5"
        )
    )
    .ignoresSafeArea()
}
