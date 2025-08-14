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
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Spacing.large) {
                    // Header Card
                    headerCard
                    
                    // Summary Statistics Card
                    if !bloodReport.testResults.isEmpty {
                        summaryStatsCard
                    }
                    
                    // Abnormal Results Alert Card (if any)
                    let abnormalResults = bloodReport.testResults.filter { $0.isAbnormal }
                    if !abnormalResults.isEmpty {
                        abnormalResultsCard(abnormalResults: abnormalResults)
                    }
                    
                    // Test Results by Category
                    if !bloodReport.testResults.isEmpty {
                        categorizedTestResultsCard
                    }
                    
                    // Notes Card
                    if !bloodReport.notes.isEmpty {
                        notesCard
                    }
                    
                    // Document Card
                    if let document = bloodReport.document {
                        documentCard(document: document)
                    }
                    
                    // Metadata Card
                    metadataCard
                }
                .padding(.horizontal, Spacing.medium)
                .padding(.top, Spacing.medium)
                .padding(.bottom, Spacing.xl)
            }
            .background(Color(UIColor.systemGroupedBackground))
            .navigationTitle("Blood Report Details")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .font(.system(size: 16, weight: .semibold))
                }
            }
        }
    }
    
    // MARK: - Header Card
    private var headerCard: some View {
        HealthCard {
            VStack(spacing: Spacing.medium) {
                // Test Name and Lab Info
                HStack(spacing: Spacing.medium) {
                    Circle()
                        .fill(Color.healthError.opacity(0.15))
                        .frame(width: Size.avatarLarge, height: Size.avatarLarge)
                        .overlay {
                            Image(systemName: "testtube.2")
                                .font(.system(size: 24, weight: .semibold))
                                .foregroundStyle(Color.healthError)
                        }
                    
                    VStack(alignment: .leading, spacing: Spacing.xs) {
                        Text(bloodReport.testName)
                            .font(.title2.weight(.semibold))
                            .foregroundStyle(.primary)
                        
                        if !bloodReport.labName.isEmpty {
                            Text(bloodReport.labName)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                    
                    Spacer()
                }
                
                // Metrics Row
                HStack(spacing: Spacing.large) {
                    HealthMetric(
                        value: bloodReport.resultDate.formatted(.dateTime.day().month().year()),
                        label: "Test Date",
                        status: .good
                    )
                    
                    if !bloodReport.category.isEmpty {
                        HealthMetric(
                            value: bloodReport.category,
                            label: "Category",
                            status: .good
                        )
                    }
                    
                    Spacer()
                }
                
                if !bloodReport.testResults.isEmpty {
                    let abnormalResults = bloodReport.testResults.filter { $0.isAbnormal }
                    
                    HStack(spacing: Spacing.large) {
                        HealthMetric(
                            value: "\(bloodReport.testResults.count)",
                            label: "Total Results",
                            status: .good
                        )
                        
                        if !abnormalResults.isEmpty {
                            HealthMetric(
                                value: "\(abnormalResults.count)",
                                label: "Abnormal",
                                status: .warning
                            )
                        }
                        
                        Spacer()
                    }
                }
            }
        }
    }
    
    // MARK: - Summary Statistics Card
    private var summaryStatsCard: some View {
        HealthCard {
            VStack(alignment: .leading, spacing: Spacing.medium) {
                HStack(spacing: Spacing.small) {
                    Image(systemName: "chart.pie.fill")
                        .font(.headline)
                        .foregroundStyle(Color.healthPrimary)
                    
                    Text("Summary Statistics")
                        .font(.headline.weight(.semibold))
                    
                    Spacer()
                }
                
                let abnormalCount = bloodReport.testResults.filter { $0.isAbnormal }.count
                let normalCount = bloodReport.testResults.count - abnormalCount
                let abnormalPercentage = bloodReport.testResults.isEmpty ? 0 : Double(abnormalCount) / Double(bloodReport.testResults.count) * 100
                
                HStack(spacing: Spacing.xl) {
                    // Normal Results
                    VStack(alignment: .leading, spacing: Spacing.small) {
                        HStack(spacing: Spacing.xs) {
                            WalnutDesignSystem.StatusIndicator(status: .good, showIcon: false)
                            Text("Normal")
                                .font(.subheadline.weight(.medium))
                        }
                        
                        Text("\(normalCount)")
                            .font(.healthMetricLarge)
                            .foregroundStyle(Color.healthSuccess)
                        
                        Text("\(String(format: "%.0f", 100 - abnormalPercentage))% of tests")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    
                    Spacer()
                    
                    // Abnormal Results
                    VStack(alignment: .trailing, spacing: Spacing.small) {
                        HStack(spacing: Spacing.xs) {
                            WalnutDesignSystem.StatusIndicator(
                                status: abnormalCount > 0 ? .warning : .good, 
                                showIcon: false
                            )
                            Text("Abnormal")
                                .font(.subheadline.weight(.medium))
                        }
                        
                        Text("\(abnormalCount)")
                            .font(.healthMetricLarge)
                            .foregroundStyle(abnormalCount > 0 ? Color.healthError : .secondary)
                        
                        Text("\(String(format: "%.0f", abnormalPercentage))% of tests")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
    }
    
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
        HealthCard(padding: Spacing.medium) {
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
    
    // MARK: - Categorized Test Results Card
    private var categorizedTestResultsCard: some View {
        HealthCard {
            VStack(alignment: .leading, spacing: Spacing.medium) {
                HStack(spacing: Spacing.small) {
                    Image(systemName: "chart.bar.fill")
                        .font(.headline)
                        .foregroundStyle(Color.healthPrimary)
                    
                    Text("Detailed Results")
                        .font(.headline.weight(.semibold))
                    
                    Spacer()
                    
                    Text("\(bloodReport.testResults.count) tests")
                        .font(.caption.weight(.medium))
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, Spacing.small)
                        .padding(.vertical, Spacing.xs)
                        .background(Color.healthPrimary.opacity(0.1))
                        .clipShape(Capsule())
                }
                
                // Group results by category if we can infer categories, otherwise show all results
                let groupedResults = Dictionary(grouping: bloodReport.testResults) { result in
                    inferCategory(for: result.testName)
                }
                
                VStack(spacing: Spacing.medium) {
                    ForEach(Array(groupedResults.keys.sorted()), id: \.self) { category in
                        if let results = groupedResults[category] {
                            categorySection(category: category, results: results)
                        }
                    }
                }
            }
        }
    }
    
    private func categorySection(category: String, results: [BloodTestResult]) -> some View {
        HealthCard(padding: Spacing.medium) {
            VStack(alignment: .leading, spacing: Spacing.medium) {
                HStack(spacing: Spacing.small) {
                    Text(category)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.primary)
                    
                    Spacer()
                    
                    let abnormalInCategory = results.filter { $0.isAbnormal }.count
                    if abnormalInCategory > 0 {
                        HStack(spacing: Spacing.xs) {
                            WalnutDesignSystem.StatusIndicator(status: .critical, showIcon: true)
                            Text("\(abnormalInCategory) abnormal")
                                .font(.caption.weight(.medium))
                                .foregroundStyle(Color.healthError)
                        }
                    }
                }
                
                VStack(spacing: Spacing.small) {
                    ForEach(results, id: \.id) { testResult in
                        enhancedTestResultRow(testResult: testResult)
                    }
                }
            }
        }
    }
    
    private func enhancedTestResultRow(testResult: BloodTestResult) -> some View {
        HStack(spacing: Spacing.medium) {
            VStack(alignment: .leading, spacing: Spacing.xs) {
                Text(testResult.testName)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(testResult.isAbnormal ? Color.healthError : .primary)
                
                Text("Ref: \(testResult.referenceRange)")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            HStack(spacing: Spacing.small) {
                VStack(alignment: .trailing, spacing: Spacing.xs) {
                    HStack(spacing: Spacing.xs) {
                        Text(testResult.value)
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(testResult.isAbnormal ? Color.healthError : .primary)
                        
                        Text(testResult.unit)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    
                    WalnutDesignSystem.StatusIndicator(
                        status: testResult.isAbnormal ? .critical : .good, 
                        showIcon: true
                    )
                }
                
                // Visual indicator bar
                Rectangle()
                    .fill(testResult.isAbnormal ? Color.healthError : Color.healthSuccess)
                    .frame(width: 3, height: 40)
                    .cornerRadius(1.5)
            }
        }
        .padding(.vertical, Spacing.small)
    }
    
    // Helper function to infer category from test name
    private func inferCategory(for testName: String) -> String {
        let name = testName.lowercased()
        
        if name.contains("hemoglobin") || name.contains("hematocrit") || name.contains("rbc") || name.contains("red blood") {
            return "Red Blood Cells"
        } else if name.contains("wbc") || name.contains("white blood") || name.contains("neutrophil") || name.contains("lymphocyte") {
            return "White Blood Cells"
        } else if name.contains("platelet") || name.contains("plt") {
            return "Platelets"
        } else if name.contains("glucose") || name.contains("sugar") {
            return "Glucose"
        } else if name.contains("cholesterol") || name.contains("hdl") || name.contains("ldl") || name.contains("triglyceride") {
            return "Lipid Profile"
        } else if name.contains("liver") || name.contains("alt") || name.contains("ast") || name.contains("bilirubin") {
            return "Liver Function"
        } else if name.contains("kidney") || name.contains("creatinine") || name.contains("urea") || name.contains("bun") {
            return "Kidney Function"
        } else if name.contains("thyroid") || name.contains("tsh") || name.contains("t3") || name.contains("t4") {
            return "Thyroid Function"
        } else {
            return "Other Tests"
        }
    }
    
    // MARK: - Notes Card
    private var notesCard: some View {
        HealthCard {
            VStack(alignment: .leading, spacing: Spacing.medium) {
                HStack(spacing: Spacing.small) {
                    Image(systemName: "note.text")
                        .font(.headline)
                        .foregroundStyle(Color.healthPrimary)
                    
                    Text("Notes")
                        .font(.headline.weight(.semibold))
                    
                    Spacer()
                }
                
                Text(bloodReport.notes)
                    .font(.subheadline)
                    .lineSpacing(4)
                    .foregroundStyle(.primary)
            }
        }
    }
    
    // MARK: - Document Card
    private func documentCard(document: Document) -> some View {
        HealthCard {
            VStack(alignment: .leading, spacing: Spacing.medium) {
                HStack(spacing: Spacing.small) {
                    Image(systemName: document.documentType.typeIcon)
                        .font(.headline)
                        .foregroundStyle(document.documentType.backgroundColor)
                    
                    Text("Lab Report Document")
                        .font(.headline.weight(.semibold))
                    
                    Spacer()
                }
                
                // Document preview section
                HStack(spacing: Spacing.medium) {
                    // Document icon
                    VStack(spacing: Spacing.xs) {
                        Circle()
                            .fill(document.documentType.backgroundColor.opacity(0.15))
                            .frame(width: Size.avatarLarge, height: Size.avatarLarge)
                            .overlay {
                                Image(systemName: document.documentType.typeIcon)
                                    .font(.system(size: 24, weight: .semibold))
                                    .foregroundStyle(document.documentType.backgroundColor)
                            }
                        
                        Text(document.documentType.displayName)
                            .font(.caption2.weight(.medium))
                            .foregroundStyle(.secondary)
                    }
                    
                    VStack(alignment: .leading, spacing: Spacing.xs) {
                        Text(document.fileName)
                            .font(.subheadline.weight(.medium))
                            .lineLimit(2)
                        
                        Text("Lab: \(bloodReport.labName)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        
                        Text("Uploaded: \(document.uploadDate, style: .date)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        
                        if document.fileSize > 0 {
                            Text("Size: \(ByteCountFormatter.string(fromByteCount: document.fileSize, countStyle: .file))")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    
                    Spacer()
                }
                
                // Action buttons
                HStack(spacing: Spacing.medium) {
                    Button(action: {
                        UIApplication.shared.open(document.fileURL)
                    }) {
                        HStack(spacing: Spacing.small) {
                            Image(systemName: "eye.fill")
                                .font(.subheadline)
                            Text("View Report")
                                .font(.subheadline.weight(.medium))
                        }
                        .foregroundStyle(.white)
                        .padding(.horizontal, Spacing.medium)
                        .padding(.vertical, Spacing.small)
                        .background(document.documentType.backgroundColor)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                    
                    Button(action: {
                        // Handle sharing
                        let activityController = UIActivityViewController(activityItems: [document.fileURL], applicationActivities: nil)
                        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                           let rootViewController = windowScene.windows.first?.rootViewController {
                            rootViewController.present(activityController, animated: true)
                        }
                    }) {
                        HStack(spacing: Spacing.small) {
                            Image(systemName: "square.and.arrow.up")
                                .font(.subheadline)
                            Text("Share")
                                .font(.subheadline.weight(.medium))
                        }
                        .foregroundStyle(document.documentType.backgroundColor)
                        .padding(.horizontal, Spacing.medium)
                        .padding(.vertical, Spacing.small)
                        .background(document.documentType.backgroundColor.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                    
                    Spacer()
                }
            }
        }
    }
    
    // MARK: - Metadata Card
    private var metadataCard: some View {
        HealthCard {
            VStack(alignment: .leading, spacing: Spacing.medium) {
                HStack(spacing: Spacing.small) {
                    Image(systemName: "info.circle.fill")
                        .font(.headline)
                        .foregroundStyle(Color.healthPrimary)
                    
                    Text("Report Information")
                        .font(.headline.weight(.semibold))
                    
                    Spacer()
                }
                
                VStack(spacing: Spacing.medium) {
                    // Dates section
                    HStack(spacing: Spacing.large) {
                        HealthMetric(
                            value: bloodReport.resultDate.formatted(.dateTime.day().month().year()),
                            label: "Test Date",
                            status: .good
                        )
                        
                        let daysAgo = Calendar.current.dateComponents([.day], from: bloodReport.resultDate, to: Date()).day ?? 0
                        HealthMetric(
                            value: "\(daysAgo)",
                            unit: "days",
                            label: "Days Ago",
                            status: .good
                        )
                        
                        Spacer()
                    }
                    
                    Rectangle()
                        .fill(Color.secondary.opacity(0.2))
                        .frame(height: 1)
                    
                    // Record dates section
                    HStack(spacing: Spacing.large) {
                        HealthMetric(
                            value: bloodReport.createdAt.formatted(.dateTime.day().month().year()),
                            label: "Added to Records",
                            status: .good
                        )
                        
                        HealthMetric(
                            value: bloodReport.updatedAt.formatted(.relative(presentation: .named)),
                            label: "Last Updated",
                            status: .good
                        )
                        
                        Spacer()
                    }
                    
                    if !bloodReport.category.isEmpty {
                        Rectangle()
                            .fill(Color.secondary.opacity(0.2))
                            .frame(height: 1)
                        
                        // Category section
                        HStack(spacing: Spacing.medium) {
                            HealthMetric(
                                value: bloodReport.category,
                                label: "Test Category",
                                status: .good
                            )
                            
                            Spacer()
                            
                            Image(systemName: "tag.fill")
                                .font(.headline)
                                .foregroundStyle(Color.healthPrimary)
                        }
                    }
                }
            }
        }
    }
    
    private func testDataRow(testResult: BloodTestResult, index: Int) -> some View {
        HStack {
            // Test Name
            VStack(alignment: .leading, spacing: 2) {
                Text(testResult.testName)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(testResult.isAbnormal ? .red : .primary)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            // Result Value
            VStack(alignment: .center, spacing: 2) {
                Text(testResult.value)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(testResult.isAbnormal ? .red : .primary)
                    .lineLimit(1)
            }
            .frame(width: 80)
            
            // Unit
            VStack(alignment: .center, spacing: 2) {
                Text(testResult.unit)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
            .frame(width: 50)
            
            // Reference Range
            VStack(alignment: .trailing, spacing: 2) {
                Text(testResult.referenceRange)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                    .multilineTextAlignment(.trailing)
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
            
            // Status
            VStack(alignment: .center, spacing: 2) {
                Image(systemName: testResult.isAbnormal ? "exclamationmark.circle.fill" : "checkmark.circle.fill")
                    .font(.subheadline)
                    .foregroundColor(testResult.isAbnormal ? .red : .green)
            }
            .frame(width: 60)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(index % 2 == 0 ? Color(UIColor.systemBackground) : Color(UIColor.secondarySystemGroupedBackground))
    }
    
    private func exportTestData() {
        // Create CSV content
        var csvContent = "Test Name,Result,Unit,Reference Range,Status\n"
        
        for testResult in bloodReport.testResults {
            let status = testResult.isAbnormal ? "Abnormal" : "Normal"
            csvContent += "\"\(testResult.testName)\",\(testResult.value),\(testResult.unit),\"\(testResult.referenceRange)\",\(status)\n"
        }
        
        // Create temporary file and share
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("\(bloodReport.testName)_TestData.csv")
        
        do {
            try csvContent.write(to: tempURL, atomically: true, encoding: .utf8)
            
            let activityController = UIActivityViewController(activityItems: [tempURL], applicationActivities: nil)
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let rootViewController = windowScene.windows.first?.rootViewController {
                rootViewController.present(activityController, animated: true)
            }
        } catch {
            print("Error exporting test data: \(error)")
        }
    }
}

#Preview {
    // Create sample data for preview
    let sampleCase = MedicalCase.sampleCase
    let sampleDocument = Document(
        fileName: "Complete_Blood_Count_Quest_Diagnostics.pdf",
        fileURL: URL(string: "https://example.com/report.pdf")!,
        documentType: .bloodWork,
        fileSize: 245760
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

