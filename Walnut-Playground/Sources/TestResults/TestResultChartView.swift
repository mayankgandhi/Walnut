//
//  TestResultChartView.swift
//  Walnut-Playground
//
//  Created by Mayank Gandhi on 30/06/25.
//  Copyright © 2025 m. All rights reserved.
//


import SwiftUI
import Charts

struct TestResultChartView: View {
    let testResults: [TestResult]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            if testResults.isEmpty {
                ContentUnavailableView(
                    "No Test Results",
                    systemImage: "chart.line.uptrend.xyaxis",
                    description: Text("Add test results to see the chart")
                )
            } else {
                chartHeader
                chartView
            }
        }
        .padding()
    }
    
    private var chartHeader: some View {
        VStack(alignment: .leading, spacing: 4) {
            if let firstResult = testResults.first {
                Text(firstResult.markerName)
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text("Code: \(firstResult.markerCode)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
    
    private var chartView: some View {
        Chart(testResults) { result in
            LineMark(
                x: .value("Date", result.resultDate),
                y: .value("Value", result.numericValue)
            )
            .foregroundStyle(.blue)
            .lineStyle(StrokeStyle(lineWidth: 2))
            
            PointMark(
                x: .value("Date", result.resultDate),
                y: .value("Value", result.numericValue)
            )
            .foregroundStyle(.blue)
            .symbolSize(40)
        }
        .chartXAxis {
            AxisMarks(values: .automatic(desiredCount: 5)) { value in
                AxisGridLine()
                AxisTick()
                AxisValueLabel(format: .dateTime.month().day())
            }
        }
        .chartYAxis {
            AxisMarks { value in
                AxisGridLine()
                AxisTick()
                AxisValueLabel()
            }
        }
        .chartYAxisLabel(position: .leading) {
            if let unit = testResults.first?.unit {
                Text("\(unit)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .chartPlotStyle { plotArea in
            plotArea
                .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 8))
        }
        .frame(height: 150)
    }
}

// MARK: - Preview
struct TestResultChartView_Previews: PreviewProvider {
    static var sampleData: [TestResult] = [
        TestResult(
            id: UUID(),
            createdAt: Date(),
            updatedAt: Date(),
            resultDate: Calendar.current.date(byAdding: .day, value: -30, to: Date()) ?? Date(),
            markerCode: "GLU",
            markerName: "Blood Glucose",
            numericValue: 95.0,
            unit: "mg/dL",
            notes: nil
        ),
        TestResult(
            id: UUID(),
            createdAt: Date(),
            updatedAt: Date(),
            resultDate: Calendar.current.date(byAdding: .day, value: -20, to: Date()) ?? Date(),
            markerCode: "GLU",
            markerName: "Blood Glucose",
            numericValue: 102.0,
            unit: "mg/dL",
            notes: "Post-meal reading"
        ),
        TestResult(
            id: UUID(),
            createdAt: Date(),
            updatedAt: Date(),
            resultDate: Calendar.current.date(byAdding: .day, value: -10, to: Date()) ?? Date(),
            markerCode: "GLU",
            markerName: "Blood Glucose",
            numericValue: 88.0,
            unit: "mg/dL",
            notes: nil
        ),
        TestResult(
            id: UUID(),
            createdAt: Date(),
            updatedAt: Date(),
            resultDate: Date(),
            markerCode: "GLU",
            markerName: "Blood Glucose",
            numericValue: 92.0,
            unit: "mg/dL",
            notes: "Fasting"
        )
    ]
    
    static var previews: some View {
        NavigationView {
            TestResultChartView(testResults: sampleData)
                .navigationTitle("Test Results")
        }
        
        // Empty state preview
        TestResultChartView(testResults: [])
            .previewDisplayName("Empty State")
    }
}
