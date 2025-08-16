//
//  EnhancedBiomarkerChart.swift
//  WalnutDesignSystem
//
//  Created by Mayank Gandhi on 16/08/25.
//  Copyright © 2025 m. All rights reserved.
//

import SwiftUI
import Charts

/// Enhanced interactive chart for biomarker data visualization
public struct EnhancedBiomarkerChart: View {
    
    // MARK: - Properties
    
    let data: [Double]
    let color: Color
    let normalRange: String
    @Binding var selectedDataPoint: Int?
    let animateChart: Bool
    let onPointSelected: ((Int) -> Void)?
    
    // MARK: - Initializer
    
    public init(
        data: [Double],
        color: Color = .healthPrimary,
        normalRange: String,
        selectedDataPoint: Binding<Int?>,
        animateChart: Bool = true,
        onPointSelected: ((Int) -> Void)? = nil
    ) {
        self.data = data
        self.color = color
        self.normalRange = normalRange
        self._selectedDataPoint = selectedDataPoint
        self.animateChart = animateChart
        self.onPointSelected = onPointSelected
    }
    
    // MARK: - Body
    
    public var body: some View {
        chartView(
            data: data,
            color: color,
            parsedNormalRange: parseNormalRange(normalRange)
        )
    }
    
    // MARK: - Chart View
    
    @ViewBuilder
    private func chartView(
        data: [Double],
        color: Color = .healthPrimary,
        parsedNormalRange: (min: Double, max: Double)?
    ) -> some View {
        Chart {
            // Normal range background area
            if let range = parsedNormalRange {
                RectangleMark(
                    xStart: .value("Start", 0),
                    xEnd: .value("End", data.count - 1),
                    yStart: .value("Min", range.min),
                    yEnd: .value("Max", range.max)
                )
                .foregroundStyle(Color.healthSuccess.opacity(0.15))
            }
            
            // Area chart under the line for visual appeal
            ForEach(Array(data.enumerated()), id: \.offset) { index, value in
                AreaMark(
                    x: .value("Index", index),
                    y: .value("Value", value)
                )
                .foregroundStyle(
                    Color.clear
                )
                .opacity(animateChart ? 1.0 : 0.0)
            }
            
            // Connecting line
            ForEach(Array(data.enumerated()), id: \.offset) { index, value in
                LineMark(
                    x: .value("Index", index),
                    y: .value("Value", value)
                )
                .foregroundStyle(color)
                .lineStyle(StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round))
                .opacity(animateChart ? 1.0 : 0.0)
            }
            
            // Data points with enhanced styling
            ForEach(Array(data.enumerated()), id: \.offset) { index, value in
                let isInRange = isValueInNormalRange(value, normalRange: parsedNormalRange)
                let isLatest = index == data.count - 1
                let isSelected = selectedDataPoint == index
                
                PointMark(
                    x: .value("Index", index),
                    y: .value("Value", value)
                )
                .foregroundStyle(isInRange ? Color.healthSuccess : Color.healthError)
                .symbolSize(isSelected ? 120 : (isLatest ? 80 : 50))
                .opacity(animateChart ? 1.0 : 0.0)

            }
        }
        .chartXAxis {
            AxisMarks(values: .automatic(desiredCount: 5)) { _ in
                AxisGridLine()
                    .foregroundStyle(.tertiary)
                AxisTick()
                    .foregroundStyle(.secondary)
                AxisValueLabel()
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .chartYAxis {
            AxisMarks(position: .leading) { _ in
                AxisGridLine()
                    .foregroundStyle(.tertiary)
                AxisTick()
                    .foregroundStyle(.secondary)
                AxisValueLabel()
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .chartBackground { _ in
            Color.clear
        }
        .gesture(
            DragGesture(minimumDistance: 0)
                .onChanged { gesture in
                    handleChartTap(at: gesture.location)
                }
                .onEnded { _ in
                    // Clear selection after 2 seconds
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        selectedDataPoint = nil
                    }
                }
        )
    }
    
    // MARK: - Helper Methods
    
    private func handleChartTap(at location: CGPoint) {
        let chartWidth = 280.0 // Approximate chart width
        let pointSpacing = chartWidth / Double(max(1, data.count - 1))
        let selectedIndex = Int(round(location.x / pointSpacing))
        
        if selectedIndex >= 0 && selectedIndex < data.count {
            selectedDataPoint = selectedIndex
            onPointSelected?(selectedIndex)
        }
    }
    
    // Helper function to parse normal range string
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

// MARK: - Preview

#Preview {
    VStack(spacing: Spacing.large) {
        // Normal values chart
        EnhancedBiomarkerChart(
            data: [13.8, 12.5, 14.5, 14.1, 14.3, 13.8, 14.2],
            color: .healthPrimary,
            normalRange: "12.0-15.5",
            selectedDataPoint: .constant(nil),
            animateChart: true
        )
        .frame(height: 280)
        .padding()
        .background(Color(UIColor.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        
        // Abnormal values chart
        EnhancedBiomarkerChart(
            data: [180, 195, 220, 188, 192, 210, 185],
            color: .red,
            normalRange: "< 200",
            selectedDataPoint: .constant(2),
            animateChart: true
        )
        .frame(height: 280)
        .padding()
        .background(Color(UIColor.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    .padding()
    .background(Color(UIColor.systemGroupedBackground))
}
