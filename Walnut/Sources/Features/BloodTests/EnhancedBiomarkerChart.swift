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
struct EnhancedBiomarkerChart: View {
    
    // MARK: - Properties
    
    let dataPoints: [BiomarkerDataPoint]
    let color: Color
    let normalRange: String
    @Binding var selectedDataPoint: BiomarkerDataPoint?
    let animateChart: Bool
    let onPointSelected: ((BiomarkerDataPoint) -> Void)?
    
    // MARK: - Initializers
    
    init(
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

// MARK: - Previews

#Preview("Normal Range - Cholesterol") {
    @Previewable @State var selectedPoint: BiomarkerDataPoint? = nil

    let sampleData = EnhancedBiomarkerChart.createSampleCholesterolData()

    return NavigationView {
        VStack {
            Text("Cholesterol Levels")
                .font(.headline)
                .padding()

            EnhancedBiomarkerChart(
                dataPoints: sampleData,
                color: .healthPrimary,
                normalRange: "150-200",
                selectedDataPoint: $selectedPoint,
                animateChart: true
            ) { dataPoint in
                print("Selected: \(dataPoint.value) on \(dataPoint.date)")
            }
            .frame(height: 250)
            .padding()

            if let selected = selectedPoint {
                Text("Selected: \(selected.value, specifier: "%.1f") on \(selected.date, style: .date)")
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
            }

            Spacer()
        }
    }
}

#Preview("Abnormal Values - Blood Sugar") {
    @Previewable @State var selectedPoint: BiomarkerDataPoint? = nil

    let sampleData = EnhancedBiomarkerChart.createSampleBloodSugarData()

    return VStack {
        Text("Blood Sugar (High Values)")
            .font(.headline)
            .padding()

        EnhancedBiomarkerChart(
            dataPoints: sampleData,
            color: .healthError,
            normalRange: "70-99",
            selectedDataPoint: $selectedPoint,
            animateChart: true
        )
        .frame(height: 250)
        .padding()

        Text("Normal Range: 70-99 mg/dL")
            .font(.caption)
            .foregroundColor(.secondary)

        Spacer()
    }
}

#Preview("Single Data Point") {
    @Previewable @State var selectedPoint: BiomarkerDataPoint? = nil

    let singlePoint = [
        BiomarkerDataPoint(
            date: Date(),
            value: 180.0,
            bloodReport: "Recent Test"
        )
    ]

    return VStack {
        Text("Single Measurement")
            .font(.headline)
            .padding()

        EnhancedBiomarkerChart(
            dataPoints: singlePoint,
            color: .healthSuccess,
            normalRange: "<200",
            selectedDataPoint: $selectedPoint,
            animateChart: true
        )
        .frame(height: 250)
        .padding()

        Spacer()
    }
}

#Preview("Empty Data") {
    @Previewable @State var selectedPoint: BiomarkerDataPoint? = nil

    return VStack {
        Text("No Data Available")
            .font(.headline)
            .padding()

        EnhancedBiomarkerChart(
            dataPoints: [],
            color: .healthPrimary,
            normalRange: "12.0-15.5",
            selectedDataPoint: $selectedPoint,
            animateChart: false
        )
        .frame(height: 250)
        .padding()
        .border(Color.gray.opacity(0.3))

        Text("Chart displays empty when no data points are provided")
            .font(.caption)
            .foregroundColor(.secondary)
            .padding()

        Spacer()
    }
}

#Preview("Long Timeline - Hemoglobin") {
    @Previewable @State var selectedPoint: BiomarkerDataPoint? = nil

    let longTimelineData = EnhancedBiomarkerChart.createSampleHemoglobinData()

    ScrollView {
        VStack {
            Text("Hemoglobin Over 12 Months")
                .font(.headline)
                .padding()

            EnhancedBiomarkerChart(
                dataPoints: longTimelineData,
                color: .healthWarning,
                normalRange: "12.0-15.5",
                selectedDataPoint: $selectedPoint,
                animateChart: true
            )
            .frame(height: 300)
            .padding()

            Text("Normal Range: 12.0-15.5 g/dL")
                .font(.caption)
                .foregroundColor(.secondary)

            Text("Data Points: \(longTimelineData.count)")
                .font(.caption2)
                .foregroundColor(Color.secondary)
                .padding(.top, 5)
        }
    }
}

// MARK: - Sample Data Helpers

extension EnhancedBiomarkerChart {

    static func createSampleCholesterolData() -> [BiomarkerDataPoint] {
        let calendar = Calendar.current
        let today = Date()

        return [
            BiomarkerDataPoint(
                date: calendar.date(byAdding: .month, value: -6, to: today) ?? today,
                value: 185.0,
                bloodReport: "Lab Test 1"
            ),
            BiomarkerDataPoint(
                date: calendar.date(byAdding: .month, value: -4, to: today) ?? today,
                value: 192.0,
                bloodReport: "Lab Test 2"
            ),
            BiomarkerDataPoint(
                date: calendar.date(byAdding: .month, value: -2, to: today) ?? today,
                value: 178.0,
                bloodReport: "Lab Test 3"
            ),
            BiomarkerDataPoint(
                date: today,
                value: 165.0,
                bloodReport: "Lab Test 4"
            )
        ]
    }

    static func createSampleBloodSugarData() -> [BiomarkerDataPoint] {
        let calendar = Calendar.current
        let today = Date()

        return [
            BiomarkerDataPoint(
                date: calendar.date(byAdding: .weekOfYear, value: -8, to: today) ?? today,
                value: 95.0,
                bloodReport: "Routine Check"
            ),
            BiomarkerDataPoint(
                date: calendar.date(byAdding: .weekOfYear, value: -6, to: today) ?? today,
                value: 110.0,
                bloodReport: "Follow-up"
            ),
            BiomarkerDataPoint(
                date: calendar.date(byAdding: .weekOfYear, value: -4, to: today) ?? today,
                value: 125.0,
                bloodReport: "Monitoring"
            ),
            BiomarkerDataPoint(
                date: calendar.date(byAdding: .weekOfYear, value: -2, to: today) ?? today,
                value: 135.0,
                bloodReport: "Alert Test"
            ),
            BiomarkerDataPoint(
                date: today,
                value: 142.0,
                bloodReport: "Latest Test"
            )
        ]
    }

    static func createSampleHemoglobinData() -> [BiomarkerDataPoint] {
        let calendar = Calendar.current
        let today = Date()
        var dataPoints: [BiomarkerDataPoint] = []

        // Create monthly data points for the past year
        for month in (0...11).reversed() {
            let date = calendar.date(byAdding: .month, value: -month, to: today) ?? today
            let baseValue = 13.0
            let variation = Double.random(in: -1.5...2.0)
            let value = max(10.0, min(17.0, baseValue + variation))

            dataPoints.append(
                BiomarkerDataPoint(
                    date: date,
                    value: value,
                    bloodReport: "Monthly Test \(12 - month)"
                )
            )
        }

        return dataPoints
    }
}
