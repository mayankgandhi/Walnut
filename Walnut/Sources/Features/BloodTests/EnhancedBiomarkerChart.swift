//
//  EnhancedBiomarkerChart.swift
//  WalnutDesignSystem
//
//  Created by Mayank Gandhi on 16/08/25.
//  Copyright © 2025 m. All rights reserved.
//

import SwiftUI
import Charts
import WalnutDesignSystem

/// Enhanced interactive chart for biomarker data visualization
public struct EnhancedBiomarkerChart: View {
    
    // MARK: - Properties
    
    let dataPoints: [BiomarkerDataPoint]
    let color: Color
    let normalRange: String
    @Binding var selectedDataPoint: BiomarkerDataPoint?
    let animateChart: Bool
    let onPointSelected: ((BiomarkerDataPoint) -> Void)?
    
    // MARK: - Initializers
    
    public init(
        dataPoints: [BiomarkerDataPoint],
        color: Color = .healthPrimary,
        normalRange: String,
        selectedDataPoint: Binding<BiomarkerDataPoint?>,
        animateChart: Bool = true,
        onPointSelected: ((BiomarkerDataPoint) -> Void)? = nil
    ) {
        self.dataPoints = dataPoints.sorted { $0.date < $1.date }
        self.color = color
        self.normalRange = normalRange
        self._selectedDataPoint = selectedDataPoint
        self.animateChart = animateChart
        self.onPointSelected = onPointSelected
    }

    // MARK: - Body
    
    public var body: some View {
        chartView
    }
    
    // MARK: - Chart View
    
    @ViewBuilder
    private var chartView: some View {
        let parsedNormalRange = parseNormalRange(normalRange)
        
        Chart {
            chartBackgroundRangeMarks(parsedNormalRange)
            chartAreaMarks
            chartLineMarks  
            chartPointMarks(parsedNormalRange)
        }
        .chartXAxis {
            AxisMarks(values: .automatic(desiredCount: 5)) { value in
                AxisGridLine()
                    .foregroundStyle(.tertiary)
                AxisTick()
                    .foregroundStyle(.secondary)
                AxisValueLabel(format: .dateTime.month(.abbreviated).day())
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
    
    // MARK: - Chart Component Views
    
    @ChartContentBuilder
    private func chartBackgroundRangeMarks(_ parsedNormalRange: (min: Double, max: Double)?) -> some ChartContent {
        if let range = parsedNormalRange,
           let startDate = dataPoints.first?.date,
           let endDate = dataPoints.last?.date {
            RectangleMark(
                xStart: .value("Start", startDate),
                xEnd: .value("End", endDate),
                yStart: .value("Min", range.min),
                yEnd: .value("Max", range.max)
            )
            .foregroundStyle(Color.healthSuccess.opacity(0.15))
        }
    }
    
    @ChartContentBuilder
    private var chartAreaMarks: some ChartContent {
        ForEach(dataPoints) { point in
            AreaMark(
                x: .value("Date", point.date),
                y: .value("Value", point.value)
            )
            .foregroundStyle(
                LinearGradient(
                    colors: [color.opacity(0.3), color.opacity(0.1)],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .opacity(animateChart ? 1.0 : 0.0)
        }
    }
    
    @ChartContentBuilder
    private var chartLineMarks: some ChartContent {
        ForEach(dataPoints) { point in
            LineMark(
                x: .value("Date", point.date),
                y: .value("Value", point.value)
            )
            .foregroundStyle(color)
            .lineStyle(StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round))
            .opacity(animateChart ? 1.0 : 0.0)
        }
    }
    
    @ChartContentBuilder
    private func chartPointMarks(_ parsedNormalRange: (min: Double, max: Double)?) -> some ChartContent {
        ForEach(dataPoints) { point in
            let isInRange = isValueInNormalRange(point.value, normalRange: parsedNormalRange)
            let isLatest = point.id == dataPoints.last?.id
            let isSelected = selectedDataPoint?.id == point.id
            
            PointMark(
                x: .value("Date", point.date),
                y: .value("Value", point.value)
            )
            .foregroundStyle(isInRange ? Color.healthSuccess : Color.healthError)
            .symbolSize(isSelected ? 120 : (isLatest ? 80 : 50))
            .opacity(animateChart ? 1.0 : 0.0)
        }
    }
    
    // MARK: - Helper Methods
    
    private func handleChartTap(at location: CGPoint) {
        guard !dataPoints.isEmpty else { return }
        
        let chartWidth = 280.0 // Approximate chart width
        let pointSpacing = chartWidth / Double(max(1, dataPoints.count - 1))
        let selectedIndex = Int(round(location.x / pointSpacing))
        
        if selectedIndex >= 0 && selectedIndex < dataPoints.count {
            let point = dataPoints[selectedIndex]
            selectedDataPoint = point
            onPointSelected?(point)
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
