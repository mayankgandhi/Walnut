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
struct BiomarkerDetailView: View {
    
    @State var viewModel: BiomarkerDetailViewModel
    @State private var selectedDocument: Document?
    
    init(
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
    
    var body: some View {
        ScrollView {
            VStack(spacing: Spacing.large) {
                
                NavBarHeader(
                    iconName: nil,
                    iconColor: nil,
                    title: viewModel.biomarkerTitle,
                    subtitle: nil
                )
                
                heroSection
                    .padding(.horizontal, Spacing.medium)
                
                chartSection
                    .padding(.horizontal, Spacing.medium)
                
                if viewModel.filteredDataPoints.count > 1 {
                    historicalDataSection
                        .padding(.horizontal, Spacing.medium)
                    
                }
            }
            .padding(.bottom, Spacing.xl)
        }
        .background(ContentBackgroundView(color: .blue))
        .sheet(item: $selectedDocument) { document in
            NavigationView {
                DocumentViewer(document: document)
            }
            .presentationDragIndicator(.visible)
            .presentationCornerRadius(Spacing.large)
        }
    }
    
    // MARK: - Hero Section
    private var heroSection: some View {
        HealthCard {
            VStack(alignment: .leading, spacing: Spacing.medium) {
                // Current value display
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
                
                HStack {
                    Text("Reference Range:")
                        .font(.caption.weight(.medium))
                        .foregroundStyle(.secondary)
                    
                    Text("\(viewModel.normalRangeText) \(viewModel.unitText)")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.primary)
                }
                
                
                // Trend information
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
                    
                }
                
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
    
    // MARK: - Time Frame Selector
    private var timeFrameSelector: some View {
        VStack(alignment: .leading, spacing: Spacing.small) {
            HStack(spacing: Spacing.small) {
                ForEach(viewModel.availableTimeFrames, id: \.self) { timeFrame in
                    Button(action: {
                        viewModel.updateTimeFrame(timeFrame)
                        
                    }) {
                        VStack(spacing: 2) {
                            
                            Text(timeFrame.displayName)
                                .font(.caption2)
                                .foregroundStyle(viewModel.selectedTimeFrame == timeFrame ? .white.opacity(0.8) : .secondary)
                        }
                        .padding(.all, Spacing.xs)
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
            
            
        }
        .frame(maxWidth: .infinity, alignment: .trailing)
    }
    
    // MARK: - Chart Section
    private var chartSection: some View {
        VStack(alignment: .leading, spacing: Spacing.medium)  {
            headingView
            
            // Enhanced chart
            EnhancedBiomarkerChart(
                dataPoints: viewModel.filteredDataPoints.map { point in
                    BiomarkerDataPoint(
                        date: point.date,
                        value: point.value,
                        bloodReport: point.bloodReport,
                        document: point.document
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
                            document: selected.document
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
            )
            .frame(height: 280)
            
            timeFrameSelector
        }
    }
    
    private var headingView: some View {
        
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
    }
    
    private var historicalDataSection: some View {
        HealthCard {
            VStack(alignment: .leading, spacing: Spacing.medium) {
                Text("Recent Readings")
                    .font(.headline.weight(.bold))
                    .foregroundStyle(.primary)
                
                VStack(spacing: Spacing.small) {
                    ForEach(Array(viewModel.filteredDataPoints.reversed())) { dataPoint in
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
                            
                            // Document access button
                            if let document = dataPoint.document {
                                Button(action: {
                                    selectedDocument = document
                                }) {
                                    Image(systemName: "arrow.up.right.square.fill")
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundStyle(Color.healthPrimary)
                                }
                                .buttonStyle(.plain)
                                .contentShape(Rectangle())
                            }
                        }
                        .padding(.vertical, 2)
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
                Text("Lab: \(String(describing: dataPoint.bloodReport))")
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
                    document: Document(
                        fileName: "blood_report_2024_01.pdf",
                        fileURL: "/Documents/blood_report_2024_01.pdf",
                        documentType: .labResult,
                        fileSize: 1024000
                    )
                ),
                BiomarkerDataPoint(
                    date: Calendar.current.date(byAdding: .month, value: -5, to: Date()) ?? Date(),
                    value: 12.5,
                    bloodReport: "Quest Diagnostics",
                    document: Document(
                        fileName: "lab_results_image.jpg",
                        fileURL: "/Documents/lab_results_image.jpg",
                        documentType: .labResult,
                        fileSize: 512000
                    )
                ),
                BiomarkerDataPoint(
                    date: Calendar.current.date(byAdding: .month, value: -4, to: Date()) ?? Date(),
                    value: 14.5,
                    bloodReport: "LabCorp"
                ),
                BiomarkerDataPoint(
                    date: Calendar.current.date(byAdding: .month, value: -3, to: Date()) ?? Date(),
                    value: 14.1,
                    bloodReport: "Hospital Lab"
                ),
                BiomarkerDataPoint(
                    date: Calendar.current.date(byAdding: .month, value: -2, to: Date()) ?? Date(),
                    value: 14.3,
                    bloodReport: "Quest Diagnostics"
                ),
                BiomarkerDataPoint(
                    date: Calendar.current.date(byAdding: .month, value: -1, to: Date()) ?? Date(),
                    value: 13.8,
                    bloodReport: "LabCorp"
                ),
                BiomarkerDataPoint(
                    date: Date(),
                    value: 14.2,
                    bloodReport: "LabCorp"
                )
            ],
            color: .healthPrimary
        )
    }
}
