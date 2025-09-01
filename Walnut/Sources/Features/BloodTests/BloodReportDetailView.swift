//
//  BloodReportDetailView.swift
//  Walnut
//
//  Created by Mayank Gandhi on 29/07/25.
//  Copyright © 2025 m. All rights reserved.
//

import SwiftUI
import Charts
import WalnutDesignSystem

struct BloodReportDetailView: View {
    let bloodReport: BloodReport
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedCategory: String?
    @State private var showAllTests = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: Spacing.large) {
                // Enhanced Hero Header
                enhancedHeaderCard
                
                // Test Results Grid
                if !(bloodReport.testResults?.isEmpty ?? true) {
                    enhancedTestResultsGrid
                } else {
                    // Show empty state if no test results
                    emptyTestResultsCard
                }
                
                // Enhanced Document & Metadata Section
                if bloodReport.notes != nil,
                   !bloodReport.notes!.isEmpty {
                    enhancedNotesCard
                }
                
                if bloodReport.document != nil {
                    DocumentCard(
                        document: bloodReport.document!,
                        title: "Lab Report Document",
                        viewButtonText: "View Report"
                    )
                }
                
            }
            .padding(.horizontal, Spacing.medium)

        }
    }
    
    
    // MARK: - Enhanced Header Card
    private var enhancedHeaderCard: some View {
        HealthCard {
            VStack(spacing: Spacing.large) {
                // Hero Section with enhanced specialty visualization
                HStack(spacing: Spacing.large) {
                    // Enhanced Lab Icon with animated background
                    ZStack {
                        Image(
                            systemName: bloodReport.document?.documentType?.typeIcon ?? "folder"
                        )
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundStyle(Color.red)
                        .background {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [
                                            Color.red.opacity(0.2),
                                            Color.red.opacity(0.05)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 40, height: 40)
                                .shadow(color: Color.red.opacity(0.3), radius: 8, x: 0, y: 4)
                        }
                    }
                    
                    // Enhanced content with better hierarchy
                    VStack(alignment: .leading, spacing: Spacing.small) {
                        if let testName = bloodReport.testName {
                            Text(testName)
                                .font(.headline)
                                .foregroundStyle(.primary)
                                .lineLimit(3)
                                .multilineTextAlignment(.leading)
                        }
                        OptionalView(bloodReport.labName) { labName in
                            HStack(spacing: Spacing.xs) {
                                Circle()
                                    .fill(Color.blue.opacity(0.2))
                                    .frame(width: 20, height: 20)
                                    .overlay {
                                        Image(systemName: "building.2")
                                            .font(.caption2.weight(.medium))
                                            .foregroundStyle(.blue)
                                    }
                                
                                Text(labName)
                                    .font(.subheadline.weight(.medium))
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                    
                    Spacer()
                }
                
                HStack {
                    OptionalView(bloodReport.resultDate) { resultDate in
                        // Test Date Card
                        VStack(alignment: .leading, spacing: Spacing.xs) {
                            HStack {
                                Image(systemName: "calendar")
                                    .font(.caption.weight(.medium))
                                    .foregroundStyle(.blue)
                                
                                Text("Test Date")
                                    .font(.caption2.weight(.medium))
                                    .foregroundStyle(.tertiary)
                                
                                Spacer()
                            }
                            
                            Text(resultDate.formatted(date: .abbreviated, time: .omitted))
                                .font(.footnote.weight(.semibold))
                                .foregroundStyle(.secondary)
                        }
                        
                    }
                    
                    OptionalView(bloodReport.category) { category in
                        // Category Card
                        VStack(alignment: .leading, spacing: Spacing.xs) {
                            
                            HStack {
                                Image(systemName: "tag")
                                    .font(.caption.weight(.medium))
                                    .foregroundStyle(.green)
                                
                                Text("Category")
                                    .font(.caption2.weight(.medium))
                                    .foregroundStyle(.tertiary)
                                
                                Spacer()
                            }
                            
                            Text(category)
                                .font(.footnote.weight(.semibold))
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
        }
    }

    // Enhanced Test Results Grid using BioMarkerGridItemView
    private var enhancedTestResultsGrid: some View {
        VStack(alignment: .leading, spacing: Spacing.small) {
            // Section Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Test Results")
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(.primary)
                    
                    Text(
                        "\(bloodReport.testResults?.count ?? 0) biomarkers measured"
                    )
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                let abnormalCount = bloodReport.testResults?.filter {
                    $0.isAbnormal ?? false
                }.count ?? 0
                if abnormalCount > 0 {
                    HStack(spacing: Spacing.xs) {
                        Circle()
                            .fill(Color.healthError)
                            .frame(width: 8, height: 8)
                        
                        Text("\(abnormalCount) need attention")
                            .font(.caption.weight(.medium))
                            .foregroundStyle(Color.healthError)
                    }
                    .padding(.horizontal, Spacing.small)
                    .padding(.vertical, 4)
                    .background(Color.healthError.opacity(0.1))
                    .clipShape(Capsule())
                }
            }
            .padding(.horizontal, Spacing.small)
            
            // Grid of Aggregated Biomarkers
            LazyVGrid(columns: [
                GridItem(.flexible())
            ], spacing: Spacing.medium) {
                ForEach(convertToAggregatedBiomarkers(), id: \.id) { biomarker in
                    NavigationLink(destination: createBiomarkerDetailView(for: biomarker)) {
                        BiomarkerListItemView(
                            data: biomarker.historicalValues,
                            color: biomarker.healthStatusColor,
                            biomarkerInfo: BiomarkerInfo(
                                name: biomarker.testName,
                                description: biomarker.description,
                                normalRange: biomarker.referenceRange,
                                unit: biomarker.unit
                            ),
                            biomarkerTrends: BiomarkerTrends(
                                currentValue: biomarker.currentNumericValue,
                                currentValueText: biomarker.currentValue,
                                comparisonText: biomarker.trendText,
                                comparisonPercentage: biomarker.trendPercentage,
                                trendDirection: biomarker.trendDirection,
                                normalRange: biomarker.referenceRange
                            )
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(.horizontal, Spacing.small)
        }
    }
    
    // Convert BloodTestResult to AggregatedBiomarker
    private func convertToAggregatedBiomarkers() -> [AggregatedBiomarker] {
        guard let testResults = bloodReport.testResults else { return [] }
        
        let biomarkers: [AggregatedBiomarker?] = testResults.map { testResult in
            guard let testName = testResult.testName,
                  let value = testResult.value,
                  let unit = testResult.unit else {
                return nil
            }
            
            let numericValue = Double(value) ?? 0.0
            let healthStatus: HealthStatus = (testResult.isAbnormal ?? false) ? .warning : .good
            
            return AggregatedBiomarker(
                id: UUID(),
                testName: testName,
                currentValue: value,
                unit: unit,
                referenceRange: testResult.referenceRange ?? "N/A",
                category: bloodReport.category ?? "General",
                latestDate: bloodReport.resultDate ?? Date(),
                historicalValues: [numericValue], // Single value for this report
                healthStatus: healthStatus,
                trendDirection: .stable, // No trend available for single report
                trendText: "--",
                trendPercentage: "--",
                latestBloodReport: bloodReport,
                testCount: 1
            )
        }
        
        return biomarkers.compactMap { $0 }
    }
    
    // Helper function to create BiomarkerDetailView with proper DataPoint conversion
    private func createBiomarkerDetailView(for biomarker: AggregatedBiomarker) -> some View {
        let dataPoints = biomarker.historicalValues.enumerated().map { index, value in
            DataPoint(
                date: Calendar.current.date(byAdding: .day, value: -index, to: biomarker.latestDate) ?? biomarker.latestDate,
                value: value,
                isAbnormal: biomarker.healthStatus == .warning || biomarker.healthStatus == .critical,
                bloodReport: biomarker.latestBloodReport.labName ?? "Lab Report"
            )
        }.reversed()
        
        return BiomarkerDetailView(
            biomarkerName: biomarker.testName,
            unit: biomarker.unit,
            normalRange: biomarker.referenceRange,
            description: biomarker.description,
            dataPoints: Array(dataPoints).map { point in
                BiomarkerDetailView.BiomarkerDataPoint(
                    date: point.date,
                    value: point.value,
                    isAbnormal: point.isAbnormal,
                    bloodReport: point.bloodReport
                )
            },
            color: biomarker.healthStatusColor
        )
    }
    
    // Empty Test Results Card
    private var emptyTestResultsCard: some View {
        HealthCard {
            VStack(spacing: Spacing.medium) {
                Image(systemName: "testtube.2")
                    .font(.system(size: 48))
                    .foregroundStyle(.quaternary)
                
                VStack(spacing: Spacing.xs) {
                    Text("No Test Results Found")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(.secondary)
                    
                    Text("The blood report was created but no test results were saved. This might be a data parsing issue.")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                        .multilineTextAlignment(.center)
                }
            }
            .padding(.vertical, Spacing.large)
        }
    }
    
    // Enhanced Notes Card
    private var enhancedNotesCard: some View {
        VStack(alignment: .leading) {
            HealthCardHeader.clinicalNotes()
            
            HealthCard {
                OptionalView(bloodReport.notes) { notes in
                    Text(notes)
                        .font(.subheadline)
                        .lineSpacing(4)
                        .foregroundStyle(.primary)
                }
            }
        }
    }
    
}

#Preview {
    // Create sample data for preview
    let sampleCase = MedicalCase.sampleCase
    let sampleDocument = Document(
        fileName: "Complete_Blood_Count_Quest_Diagnostics.pdf",
        fileURL: "https://example.com/report.pdf",
        documentType: .labResult,
        fileSize: 245760,
    )
    
    let sampleBloodReport = BloodReport(
        testName: "Complete Blood Count with Differential",
        labName: "Quest Diagnostics",
        category: "Hematology",
        resultDate: Date().addingTimeInterval(-86400 * 3),
        notes: "Routine annual physical examination. Patient fasting for 12 hours prior to blood draw. All standard precautions followed.",
        medicalCase: sampleCase,
        document: sampleDocument
    )
    
    // Add comprehensive test results
    let testResults = [
        BloodTestResult(
            testName: "Hemoglobin",
            value: "13.8",
            unit: "g/dL",
            referenceRange: "12.0-15.5",
            isAbnormal: false,
            bloodReport: sampleBloodReport
        ),
        BloodTestResult(
            testName: "Hematocrit",
            value: "41.2",
            unit: "%",
            referenceRange: "36.0-46.0",
            isAbnormal: false,
            bloodReport: sampleBloodReport
        ),
        BloodTestResult(
            testName: "White Blood Cell Count",
            value: "12.5",
            unit: "K/uL",
            referenceRange: "4.5-11.0",
            isAbnormal: true,
            bloodReport: sampleBloodReport
        ),
        BloodTestResult(
            testName: "Red Blood Cell Count",
            value: "4.65",
            unit: "M/uL",
            referenceRange: "4.20-5.40",
            isAbnormal: false,
            bloodReport: sampleBloodReport
        ),
        BloodTestResult(
            testName: "Platelets",
            value: "285",
            unit: "K/uL",
            referenceRange: "150-450",
            isAbnormal: false,
            bloodReport: sampleBloodReport
        ),
        BloodTestResult(
            testName: "Glucose, Fasting",
            value: "110",
            unit: "mg/dL",
            referenceRange: "70-99",
            isAbnormal: true,
            bloodReport: sampleBloodReport
        ),
        BloodTestResult(
            testName: "Total Cholesterol",
            value: "195",
            unit: "mg/dL",
            referenceRange: "<200",
            isAbnormal: false,
            bloodReport: sampleBloodReport
        ),
        BloodTestResult(
            testName: "HDL Cholesterol",
            value: "58",
            unit: "mg/dL",
            referenceRange: ">40",
            isAbnormal: false,
            bloodReport: sampleBloodReport
        ),
        BloodTestResult(
            testName: "LDL Cholesterol",
            value: "118",
            unit: "mg/dL",
            referenceRange: "<100",
            isAbnormal: true,
            bloodReport: sampleBloodReport
        ),
        BloodTestResult(
            testName: "Triglycerides",
            value: "95",
            unit: "mg/dL",
            referenceRange: "<150",
            isAbnormal: false,
            bloodReport: sampleBloodReport
        ),
        BloodTestResult(
            testName: "Creatinine",
            value: "0.95",
            unit: "mg/dL",
            referenceRange: "0.60-1.20",
            isAbnormal: false,
            bloodReport: sampleBloodReport
        ),
        BloodTestResult(
            testName: "BUN",
            value: "18",
            unit: "mg/dL",
            referenceRange: "7-20",
            isAbnormal: false,
            bloodReport: sampleBloodReport
        )
    ]
    
    // Assign test results to the blood report
    sampleBloodReport.testResults = testResults
    
    return NavigationStack {
        BloodReportDetailView(bloodReport: sampleBloodReport)
    }
}

