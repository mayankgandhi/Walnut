//
//  BiomarkerListItemView.swift
//  WalnutDesignSystem
//
//  Created by Mayank Gandhi on 08/08/25.
//  Copyright © 2025 m. All rights reserved.
//

import SwiftUI
import Charts
import WalnutDesignSystem

/// Compact biomarker display component for list views
public struct BiomarkerListItemView: View {
    private let data: [Double]
    private let color: Color
    private let biomarkerInfo: BiomarkerInfo
    private let biomarkerTrends: BiomarkerTrends
    private let iconName: String
    
    public init(
        data: [Double],
        color: Color = .healthPrimary,
        biomarkerInfo: BiomarkerInfo,
        biomarkerTrends: BiomarkerTrends,
        iconName: String = "chart.line.uptrend.xyaxis"
    ) {
        self.data = data
        self.color = color
        self.biomarkerInfo = biomarkerInfo
        self.biomarkerTrends = biomarkerTrends
        self.iconName = iconName
    }
    
    public var body: some View {
        HealthCard {
            HStack(alignment: .center, spacing: Spacing.medium) {
                // Health status indicator with icon
                Circle()
                    .fill(color.opacity(0.15))
                    .frame(width: 36, height: 36)
                    .overlay {
                        Image(systemName: iconName)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundStyle(color)
                    }
                
                // Biomarker info section - improved text handling
                VStack(alignment: .leading, spacing: Spacing.xs) {
                    // Biomarker name with better handling for long names
                    Text(biomarkerInfo.name)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.primary)
                        .lineLimit(2)
                        .minimumScaleFactor(0.8)
                        .multilineTextAlignment(.leading)
                        .allowsTightening(true)
                    
                    // Current value with unit
                    HStack(alignment: .firstTextBaseline, spacing: 4) {
                        Text(biomarkerTrends.currentValueText)
                            .font(.system(.title3, design: .rounded, weight: .bold))
                            .foregroundStyle(.primary)
                            .lineLimit(1)
                            .minimumScaleFactor(0.7)
                        
                        if !biomarkerInfo.unit.isEmpty {
                            Text(biomarkerInfo.unit)
                                .font(.caption.weight(.medium))
                                .foregroundStyle(.secondary)
                                .lineLimit(1)
                                .minimumScaleFactor(0.8)
                        }
                    }
                    
                    // Reference range with improved formatting
                    if !biomarkerTrends.normalRange.isEmpty {
                        Text("Ref: \(biomarkerTrends.normalRange)")
                            .font(.footnote)
                            .foregroundStyle(.tertiary)
                            .lineLimit(1)
                            .minimumScaleFactor(0.8)
                    }
                }
                
                Spacer()
                
                // Right side content
                VStack(alignment: .trailing, spacing: Spacing.small) {
                    // Mini chart
                    miniChartView
                    
                    // Trend information with status badge design
                    HStack(spacing: Spacing.xs) {
                        Image(systemName: biomarkerTrends.trendDirection.iconName)
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(biomarkerTrends.trendDirection.color)
                        
                        Text(biomarkerTrends.comparisonPercentage)
                            .font(.caption2.weight(.bold))
                            .foregroundStyle(biomarkerTrends.trendDirection.color)
                            .lineLimit(1)
                            .minimumScaleFactor(0.8)
                    }
                    .padding(.horizontal, Spacing.xs)
                    .padding(.vertical, 2)
                    .background(biomarkerTrends.trendDirection.color.opacity(0.1))
                    .clipShape(Capsule())
                }
            }
        }
    }
    
    private var miniChartView: some View {
        let normalRange = parseNormalRange(biomarkerTrends.normalRange)
        
        return Chart {
            // Normal range background area with softer styling
            if let range = normalRange {
                RectangleMark(
                    xStart: .value("Start", 0),
                    xEnd: .value("End", data.count - 1),
                    yStart: .value("Min", range.min),
                    yEnd: .value("Max", range.max)
                )
                .foregroundStyle(Color.healthSuccess.opacity(0.08))
                .cornerRadius(2)
            }
            
            // Gradient area under the line
            ForEach(Array(data.enumerated()), id: \.offset) { index, value in
                if index < data.count - 1 {
                    AreaMark(
                        x: .value("Index", index),
                        yStart: .value("Min", data.min() ?? 0),
                        yEnd: .value("Value", value)
                    )
                    .foregroundStyle(
                        LinearGradient(
                            colors: [color.opacity(0.3), color.opacity(0.05)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                }
            }
            
            // Line chart with improved styling
            ForEach(Array(data.enumerated()), id: \.offset) { index, value in
                LineMark(
                    x: .value("Index", index),
                    y: .value("Value", value)
                )
                .foregroundStyle(color)
                .lineStyle(StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))
                .interpolationMethod(.catmullRom)
            }
            
            // Data points with refined design
            ForEach(Array(data.enumerated()), id: \.offset) { index, value in
                let isInRange = isValueInNormalRange(value, normalRange: normalRange)
                let isLatest = index == data.count - 1
                
                PointMark(
                    x: .value("Index", index),
                    y: .value("Value", value)
                )
                .foregroundStyle(isLatest ? color : color.opacity(0.6))
                .symbolSize(isLatest ? 36 : 20)
                .symbol(isLatest ? .circle : .circle)
            }
            
            // Highlight the latest point with a ring
            if let lastIndex = data.indices.last, let lastValue = data.last {
                PointMark(
                    x: .value("Index", lastIndex),
                    y: .value("Value", lastValue)
                )
                .foregroundStyle(.clear)
                .symbolSize(50)
                .symbol(.circle)
                .lineStyle(StrokeStyle(lineWidth: 1.5))
                .foregroundStyle(color.opacity(0.4))
            }
        }
        .chartXAxis(.hidden)
        .chartYAxis(.hidden)
        .chartBackground { _ in
            Color.clear
        }
        .chartPlotStyle { plot in
            plot.frame(height: 44)
        }
        .frame(width: 88, height: 44)
        .background(
            RoundedRectangle(cornerRadius: 6)
                .fill(color.opacity(0.02))
                .stroke(color.opacity(0.1), lineWidth: 0.5)
        )
    }
    
    // Helper function to parse normal range string
    private func parseNormalRange(_ rangeString: String) -> (min: Double, max: Double)? {
        // Handle different range formats like "12.0-15.5", "< 200", "> 90", "70-100"
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
                // Use a reasonable upper bound for visualization
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

#Preview("Enhanced Biomarker List") {
    ScrollView {
        VStack(spacing: Spacing.medium) {
            // Hemoglobin - optimal values with upward trend
            BiomarkerListItemView(
                data: [13.8, 12.5, 14.5, 14.1, 14.3, 13.8, 14.2],
                color: .healthSuccess,
                biomarkerInfo: BiomarkerInfo(
                    name: "Hemoglobin",
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
                ),
                iconName: "drop.fill"
            )
            
            // Blood Glucose - stable but slightly elevated
            BiomarkerListItemView(
                data: [95, 110, 92, 105, 94, 91, 96],
                color: .healthWarning,
                biomarkerInfo: BiomarkerInfo(
                    name: "Blood Glucose",
                    normalRange: "70-100",
                    unit: "mg/dL"
                ),
                biomarkerTrends: BiomarkerTrends(
                    currentValue: 96,
                    currentValueText: "96",
                    comparisonText: "2 mg/dL",
                    comparisonPercentage: "2%",
                    trendDirection: .stable,
                    normalRange: "70-100"
                ),
                iconName: "cube.fill"
            )
            
            // Blood Pressure - high with downward trend
            BiomarkerListItemView(
                data: [180, 195, 205, 188, 192, 210, 185],
                color: .healthError,
                biomarkerInfo: BiomarkerInfo(
                    name: "Systolic Blood Pressure",
                    normalRange: "90-120",
                    unit: "mmHg"
                ),
                biomarkerTrends: BiomarkerTrends(
                    currentValue: 185,
                    currentValueText: "185",
                    comparisonText: "5 mmHg",
                    comparisonPercentage: "3%",
                    trendDirection: .down,
                    normalRange: "90-120"
                ),
                iconName: "heart.fill"
            )
            
            // Total Cholesterol - improving trend
            BiomarkerListItemView(
                data: [220, 215, 208, 195, 192, 188, 185],
                color: .healthPrimary,
                biomarkerInfo: BiomarkerInfo(
                    name: "Total Cholesterol",
                    normalRange: "< 200",
                    unit: "mg/dL"
                ),
                biomarkerTrends: BiomarkerTrends(
                    currentValue: 185,
                    currentValueText: "185",
                    comparisonText: "3 mg/dL",
                    comparisonPercentage: "2%",
                    trendDirection: .down,
                    normalRange: "< 200"
                ),
                iconName: "waveform.path.ecg"
            )
            
            // White Blood Cell Count - normal range
            BiomarkerListItemView(
                data: [6.8, 7.2, 6.5, 7.1, 6.9, 7.3, 7.0],
                color: .healthSuccess,
                biomarkerInfo: BiomarkerInfo(
                    name: "White Blood Cell Count",
                    normalRange: "4.5-11.0",
                    unit: "K/μL"
                ),
                biomarkerTrends: BiomarkerTrends(
                    currentValue: 7.0,
                    currentValueText: "7.0",
                    comparisonText: "0.3 K/μL",
                    comparisonPercentage: "4%",
                    trendDirection: .stable,
                    normalRange: "4.5-11.0"
                ),
                iconName: "shield.fill"
            )
            
            // Vitamin D - critical level with upward trend
            BiomarkerListItemView(
                data: [15, 16, 18, 19, 21, 23, 25],
                color: .orange,
                biomarkerInfo: BiomarkerInfo(
                    name: "Vitamin D",
                    normalRange: "30-100",
                    unit: "ng/mL"
                ),
                biomarkerTrends: BiomarkerTrends(
                    currentValue: 25,
                    currentValueText: "25",
                    comparisonText: "2 ng/mL",
                    comparisonPercentage: "8%",
                    trendDirection: .up,
                    normalRange: "30-100"
                ),
                iconName: "sun.max.fill"
            )
        }
        .padding()
    }
    .background(Color(UIColor.systemGroupedBackground))
}
