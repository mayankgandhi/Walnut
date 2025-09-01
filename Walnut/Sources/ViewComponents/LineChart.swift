//
//  LineChart.swift
//  WalnutDesignSystem
//
//  Created by Mayank Gandhi on 06/08/25.
//  Copyright © 2025 m. All rights reserved.
//

import SwiftUI
import Charts

/// Biomarker chart coordinator that delegates to specialized views based on display mode.
/// This component acts as a factory that creates the appropriate view based on the display context:
/// - .compact: Simple line chart with optional biomarker info for standalone use
/// - .listItem: Compact biomarker list item with mini bar chart
/// - .fullScreen: Full-screen biomarker detail view with comprehensive metrics
public struct LineChart: View {
    private let data: [Double]
    private let color: Color
    private let showPoints: Bool
    private let biomarkerInfo: BiomarkerInfo
    private let biomarkerTrends: BiomarkerTrends
    private let displayMode: DisplayMode
    
    public enum DisplayMode {
        case listItem
        case fullScreen
    }
    
    public init(
        data: [Double],
        color: Color = .healthPrimary,
        showPoints: Bool = true,
        biomarkerInfo: BiomarkerInfo,
        biomarkerTrends: BiomarkerTrends,
        displayMode: DisplayMode
    ) {
        self.data = data
        self.color = color
        self.showPoints = showPoints
        self.biomarkerInfo = biomarkerInfo
        self.biomarkerTrends = biomarkerTrends
        self.displayMode = displayMode
    }
    
    public var body: some View {
        switch displayMode {
        case .fullScreen:
            BiomarkerDetailView(
                biomarkerName: biomarkerInfo.name,
                unit: biomarkerInfo.unit,
                normalRange: biomarkerInfo.normalRange,
                description: biomarkerInfo.description,
                dataPoints: createDataPointsFromArray(data),
                color: color
            )
            
        case .listItem:
            BiomarkerListItemView(
                data: data,
                color: color,
                biomarkerInfo: biomarkerInfo,
                biomarkerTrends: biomarkerTrends
            )
        }
        
    }
    
    // MARK: - Helper Functions
    
    private func createDataPointsFromArray(_ values: [Double]) -> [BiomarkerDetailView.BiomarkerDataPoint] {
        let today = Date()
        return values.enumerated().map { index, value in
            let date = Calendar.current.date(byAdding: .day, value: index - values.count + 1, to: today) ?? today
            return BiomarkerDetailView.BiomarkerDataPoint(
                date: date,
                value: value,
                isAbnormal: false, // Cannot determine from simple array
                bloodReport: "Lab Result"
            )
        }
    }
}

#Preview("Full Screen Detail View") {
    LineChart(
        data: [13.8, 12.5, 14.5, 14.1, 14.3, 13.8, 14.2],
        color: .healthPrimary,
        showPoints: false,
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
        ),
        displayMode: .fullScreen
    )
    .ignoresSafeArea()
}

#Preview("List Item Views") {
    VStack(spacing: 12) {
        LineChart(
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
            ),
            displayMode: .listItem
        )
        
        LineChart(
            data: [95, 88, 92, 89, 94, 91, 96],
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
            ),
            displayMode: .listItem
        )
        
        LineChart(
            data: [120, 125, 118, 122, 119, 124, 121],
            color: .heartRate,
            biomarkerInfo: BiomarkerInfo(
                name: "Blood Pressure",
                description: "Systolic blood pressure",
                normalRange: "90-120",
                unit: "mmHg"
            ),
            biomarkerTrends: BiomarkerTrends(
                currentValue: 121,
                currentValueText: "121",
                comparisonText: "1 mmHg",
                comparisonPercentage: "1%",
                trendDirection: .down,
                normalRange: "90-120"
            ),
            displayMode: .listItem
        )
    }
    .padding()
    .background(Color(.systemGroupedBackground))
}

#Preview("Display Mode Comparison") {
    VStack(spacing: 20) {
            
        
        VStack(alignment: .leading, spacing: 8) {
            Text("List Item Mode")
                .font(.headline)
                .padding(.horizontal)
            
            LineChart(
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
                ),
                displayMode: .listItem
            )
            .padding(.horizontal)
        }
        
        Spacer()
    }
    .background(Color(.systemGroupedBackground))
}
