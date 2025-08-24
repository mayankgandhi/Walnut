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
        NavigationStack {
            ScrollView {
                VStack(spacing: Spacing.medium) {
                    // Enhanced Hero Header
                    enhancedHeaderCard
                    
                    // Test Results Grid
                    if !bloodReport.testResults.isEmpty {
                        enhancedTestResultsGrid
                    } else {
                        // Show empty state if no test results
                        emptyTestResultsCard
                    }
                    
                    // Enhanced Document & Metadata Section
                    VStack(spacing: Spacing.large) {
                        if !bloodReport.notes.isEmpty {
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
                }
                .padding(.horizontal, Spacing.medium)
            }
            .navigationBarTitleDisplayMode(.inline)
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
                            systemName: bloodReport.document?.documentType.typeIcon ?? "folder"
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
                        Text(bloodReport.testName)
                            .font(.headline)
                            .foregroundStyle(.primary)
                            .lineLimit(3)
                            .multilineTextAlignment(.leading)
                        
                        if !bloodReport.labName.isEmpty {
                            HStack(spacing: Spacing.xs) {
                                Circle()
                                    .fill(Color.blue.opacity(0.2))
                                    .frame(width: 20, height: 20)
                                    .overlay {
                                        Image(systemName: "building.2")
                                            .font(.caption2.weight(.medium))
                                            .foregroundStyle(.blue)
                                    }
                                
                                Text(bloodReport.labName)
                                    .font(.subheadline.weight(.medium))
                                    .foregroundStyle(.secondary)
                            }
                        }
                        
                        // Enhanced status with overall health indicator
                        let abnormalCount = bloodReport.testResults.filter(\.isAbnormal).count
                        HStack(spacing: Spacing.xs) {
                            Circle()
                                .fill(abnormalCount == 0 ? Color.healthSuccess : Color.healthWarning)
                                .frame(width: 8, height: 8)
                                .scaleEffect(abnormalCount > 0 ? 1.0 : 0.8)
                                .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: abnormalCount > 0)
                            
                            Text(abnormalCount == 0 ? "All Results Normal" : "\(abnormalCount) Abnormal Results")
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(abnormalCount == 0 ? Color.healthSuccess : Color.healthWarning)
                        }
                    }
                    
                    Spacer()
                }
                
                // Enhanced metadata section with modern card grid
                HStack {
                    
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
                        
                        Text(bloodReport.resultDate.formatted(date: .abbreviated, time: .omitted))
                            .font(.footnote.weight(.semibold))
                            .foregroundStyle(.secondary)
                    }
                    
                    
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
                        
                        Text(bloodReport.category.isEmpty ? "General" : bloodReport.category)
                            .font(.footnote.weight(.semibold))
                            .foregroundStyle(.secondary)
                    }
                    
                }
            }
        }
    }
    
    // MARK: - Quick Stats Overview
    
    // MARK: - Abnormal Results Alert Card
    private func abnormalResultsCard(abnormalResults: [BloodTestResult]) -> some View {
        HealthCard {
            VStack(alignment: .leading, spacing: Spacing.medium) {
                HStack(spacing: Spacing.small) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.headline)
                        .foregroundStyle(Color.healthError)
                    
                    Text("Attention Required")
                        .font(.headline.weight(.semibold))
                        .foregroundStyle(Color.healthError)
                    
                    Spacer()
                    
                    Text("\(abnormalResults.count)")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(.white)
                        .frame(minWidth: 24, minHeight: 24)
                        .background(Circle().fill(Color.healthError))
                }
                
                Text("The following test results are outside normal reference ranges and may require medical attention:")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineSpacing(2)
                
                VStack(spacing: Spacing.small) {
                    ForEach(abnormalResults, id: \.id) { testResult in
                        abnormalResultHighlight(testResult: testResult)
                    }
                }
            }
        }
    }
    
    private func abnormalResultHighlight(testResult: BloodTestResult) -> some View {
        HealthCard {
            HStack(spacing: Spacing.medium) {
                VStack(alignment: .leading, spacing: Spacing.xs) {
                    Text(testResult.testName)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Color.healthError)
                    
                    Text("Reference: \(testResult.referenceRange)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: Spacing.xs) {
                    HStack(spacing: Spacing.xs) {
                        Text(testResult.value)
                            .font(.subheadline.weight(.bold))
                            .foregroundStyle(Color.healthError)
                        
                        Text(testResult.unit)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    
                    WalnutDesignSystem.StatusIndicator(status: .critical, showIcon: true)
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
                    
                    Text("\(bloodReport.testResults.count) biomarkers measured")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                let abnormalCount = bloodReport.testResults.filter(\.isAbnormal).count
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
            
            // Grid of BioMarker Items
            ForEach(convertToBioMarkers(), id: \.id) { biomarker in
                BioMarkerGridItemView(
                    biomarker: biomarker
                )
            }
        }
    }
    
    // Convert BloodTestResult to BioMarker
    private func convertToBioMarkers() -> [BioMarker] {
        return bloodReport.testResults.map { testResult in
            let healthStatus: HealthStatus = {
                if !testResult.isAbnormal {
                    return .optimal
                } else {
                    // For abnormal results, we could add more logic here
                    // to determine if it's warning or critical based on severity
                    return .warning
                }
            }()
            
            return BioMarker(
                name: testResult.testName,
                currentValue: testResult.value,
                unit: testResult.unit,
                referenceRange: testResult.referenceRange,
                healthStatus: healthStatus,
                iconName: iconForTestName(testResult.testName),
                lastUpdated: bloodReport.resultDate
            )
        }
    }
    
    // Helper function to get appropriate icon for test name
    private func iconForTestName(_ testName: String) -> String {
        let name = testName.lowercased()
        
        if name.contains("hemoglobin") || name.contains("hematocrit") || name.contains("rbc") || name.contains("red blood") {
            return "drop.fill"
        } else if name.contains("wbc") || name.contains("white blood") || name.contains("neutrophil") || name.contains("lymphocyte") {
            return "shield.fill"
        } else if name.contains("platelet") || name.contains("plt") {
            return "circle.dotted"
        } else if name.contains("glucose") || name.contains("sugar") {
            return "cube.fill"
        } else if name.contains("cholesterol") || name.contains("hdl") || name.contains("ldl") || name.contains("triglyceride") {
            return "heart.fill"
        } else if name.contains("liver") || name.contains("alt") || name.contains("ast") || name.contains("bilirubin") {
            return "rectangle.fill"
        } else if name.contains("kidney") || name.contains("creatinine") || name.contains("urea") || name.contains("bun") {
            return "oval.fill"
        } else if name.contains("thyroid") || name.contains("tsh") || name.contains("t3") || name.contains("t4") {
            return "bolt.fill"
        } else if name.contains("pressure") || name.contains("bp") {
            return "waveform.path.ecg"
        } else {
            return "testtube.2"
        }
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
                Text(bloodReport.notes)
                    .font(.subheadline)
                    .lineSpacing(4)
                    .foregroundStyle(.primary)
                
            }
        }
    }
    
}

#Preview {
    // Create sample data for preview
    let sampleCase = MedicalCase.sampleCase
    let sampleDocument = Document(
        fileName: "Complete_Blood_Count_Quest_Diagnostics.pdf",
        fileURL: URL(string: "https://example.com/report.pdf")!,
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

