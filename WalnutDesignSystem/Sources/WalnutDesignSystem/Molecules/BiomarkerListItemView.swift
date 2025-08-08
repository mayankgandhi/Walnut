//
//  BiomarkerListItemView.swift
//  WalnutDesignSystem
//
//  Created by Mayank Gandhi on 08/08/25.
//  Copyright © 2025 m. All rights reserved.
//

import SwiftUI
import Charts

/// Compact biomarker display component for list views
public struct BiomarkerListItemView: View {
    private let data: [Double]
    private let color: Color
    private let biomarkerInfo: BiomarkerInfo
    private let biomarkerTrends: BiomarkerTrends
    
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
        HStack(spacing: 16) {
            // Left side - Biomarker info
            VStack(alignment: .leading, spacing: 4) {
                Text(biomarkerInfo.name)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                HStack(spacing: 4) {
                    Text(biomarkerTrends.currentValueText)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Text(biomarkerInfo.unit)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .offset(y: 2)
                }
                
                HStack(spacing: 4) {
                    Image(systemName: biomarkerTrends.trendDirection.iconName)
                        .foregroundColor(biomarkerTrends.trendDirection.color)
                        .font(.caption)
                    Text(biomarkerTrends.comparisonPercentage)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(biomarkerTrends.trendDirection.color)
                    Text("vs last week")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            // Right side - Mini chart
            VStack(alignment: .trailing, spacing: 4) {
                miniChartView
                
                Text("Normal")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.green)
            }
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
        )
    }
    
    private var miniChartView: some View {
        let normalRange = parseNormalRange(biomarkerTrends.normalRange)
        
        return Chart {
            // Normal range background area
            if let range = normalRange {
                RectangleMark(
                    xStart: .value("Start", 0),
                    xEnd: .value("End", data.count - 1),
                    yStart: .value("Min", range.min),
                    yEnd: .value("Max", range.max)
                )
                .foregroundStyle(.green.opacity(0.1))
                .cornerRadius(4)
            }
            
            // Line chart connecting all points
            ForEach(Array(data.enumerated()), id: \.offset) { index, value in
                LineMark(
                    x: .value("Index", index),
                    y: .value("Value", value)
                )
                .foregroundStyle(.gray.opacity(0.8))
                .lineStyle(StrokeStyle(lineWidth: 1.5))
            }
            
            // Data points with color coding
            ForEach(Array(data.enumerated()), id: \.offset) { index, value in
                let isInRange = isValueInNormalRange(value, normalRange: normalRange)
                let isLatest = index == data.count - 1
                
                PointMark(
                    x: .value("Index", index),
                    y: .value("Value", value)
                )
                .foregroundStyle(isInRange ? .green : .red)
                .symbolSize(isLatest ? 40 : 25)
            }
        }
        .chartXAxis(.hidden)
        .chartYAxis(.hidden)
        .chartBackground { _ in
            Color.clear
        }
        .frame(width: 80, height: 40)
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

#Preview {
    ScrollView {
        VStack(spacing: 12) {
            // Values mostly in normal range
            BiomarkerListItemView(
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
            
            // Mix of normal and abnormal values
            BiomarkerListItemView(
                data: [95, 110, 92, 105, 94, 91, 96],
                color: .glucose,
                biomarkerInfo: BiomarkerInfo(
                    name: "Blood Glucose",
                    description: "Blood sugar levels",
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
                )
            )
            
            // Values outside normal range (high)
            BiomarkerListItemView(
                data: [180, 195, 205, 188, 192, 210, 185],
                color: .red,
                biomarkerInfo: BiomarkerInfo(
                    name: "Blood Pressure",
                    description: "Systolic blood pressure",
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
                )
            )
            
            // "Less than" range format
            BiomarkerListItemView(
                data: [180, 195, 220, 188, 192, 210, 185],
                color: .purple,
                biomarkerInfo: BiomarkerInfo(
                    name: "Total Cholesterol",
                    description: "Total cholesterol levels",
                    normalRange: "< 200",
                    unit: "mg/dL"
                ),
                biomarkerTrends: BiomarkerTrends(
                    currentValue: 185,
                    currentValueText: "185",
                    comparisonText: "5 mg/dL",
                    comparisonPercentage: "3%",
                    trendDirection: .down,
                    normalRange: "< 200"
                )
            )
        }
        .padding()
    }
    .background(Color(.systemGroupedBackground))
}
