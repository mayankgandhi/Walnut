//
//  BloodReportDetailView.swift
//  Walnut
//
//  Created by Mayank Gandhi on 29/07/25.
//  Copyright © 2025 m. All rights reserved.
//

import SwiftUI
import Charts

struct BloodReportDetailView: View {
    let bloodReport: BloodReport
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
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
                    if let reportURL = bloodReport.reportURL {
                        documentCard(reportURL: reportURL)
                    }
                    
                    // Metadata Card
                    metadataCard
                    
                    
                }
                .padding(.horizontal, 20)
                .padding(.vertical)
            }
            .background(Color(UIColor.systemGroupedBackground))
            .navigationTitle("Blood Report Details")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .fontWeight(.medium)
                }
            }
        }
    }
    
    // MARK: - Header Card
    private var headerCard: some View {
        VStack(spacing: 16) {
            // Test Name and Lab Info
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(bloodReport.testName)
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    if !bloodReport.labName.isEmpty {
                        Text(bloodReport.labName)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                // Test Tube Icon
                Image(systemName: "testtube.2")
                    .font(.system(size: 32))
                    .foregroundColor(.red)
            }
            
            Divider()
            
            // Date and Category Information
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Test Date")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .textCase(.uppercase)
                    
                    Text(bloodReport.resultDate, style: .date)
                        .font(.headline)
                        .fontWeight(.medium)
                }
                
                Spacer()
                
                if !bloodReport.category.isEmpty {
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("Category")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .textCase(.uppercase)
                        
                        Text(bloodReport.category)
                            .font(.headline)
                            .fontWeight(.medium)
                    }
                }
            }
            
            if !bloodReport.testResults.isEmpty {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Total Results")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .textCase(.uppercase)
                        
                        Text("\(bloodReport.testResults.count)")
                            .font(.headline)
                            .fontWeight(.medium)
                    }
                    
                    Spacer()
                    
                    let abnormalResults = bloodReport.testResults.filter { $0.isAbnormal }
                    if !abnormalResults.isEmpty {
                        VStack(alignment: .trailing, spacing: 4) {
                            Text("Abnormal")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .textCase(.uppercase)
                            
                            Text("\(abnormalResults.count)")
                                .font(.headline)
                                .fontWeight(.medium)
                                .foregroundColor(.red)
                        }
                    }
                }
            }
        }
        .padding(20)
        .background(Color(UIColor.systemBackground))
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 4)
        .onAppear {
            dump(bloodReport)
        }
    }
    
    // MARK: - Summary Statistics Card
    private var summaryStatsCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "chart.pie.fill")
                    .font(.title2)
                    .foregroundColor(.blue)
                
                Text("Summary Statistics")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Spacer()
            }
            
            let abnormalCount = bloodReport.testResults.filter { $0.isAbnormal }.count
            let normalCount = bloodReport.testResults.count - abnormalCount
            let abnormalPercentage = bloodReport.testResults.isEmpty ? 0 : Double(abnormalCount) / Double(bloodReport.testResults.count) * 100
            
            HStack(spacing: 20) {
                // Normal Results
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Circle()
                            .fill(Color.green)
                            .frame(width: 12, height: 12)
                        Text("Normal")
                            .font(.subheadline)
                            .fontWeight(.medium)
                    }
                    
                    Text("\(normalCount)")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.green)
                    
                    Text("\(String(format: "%.0f", 100 - abnormalPercentage))% of tests")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Abnormal Results
                VStack(alignment: .trailing, spacing: 8) {
                    HStack {
                        Circle()
                            .fill(Color.red)
                            .frame(width: 12, height: 12)
                        Text("Abnormal")
                            .font(.subheadline)
                            .fontWeight(.medium)
                    }
                    
                    Text("\(abnormalCount)")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(abnormalCount > 0 ? .red : .secondary)
                    
                    Text("\(String(format: "%.0f", abnormalPercentage))% of tests")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.vertical, 8)
        }
        .padding(20)
        .background(Color(UIColor.systemBackground))
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 4)
    }
    
    // MARK: - Abnormal Results Alert Card
    private func abnormalResultsCard(abnormalResults: [BloodTestResult]) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.title2)
                    .foregroundColor(.red)
                
                Text("Attention Required")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.red)
                
                Spacer()
                
                Text("\(abnormalResults.count)")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .frame(minWidth: 24, minHeight: 24)
                    .background(Circle().fill(Color.red))
            }
            
            Text("The following test results are outside normal reference ranges and may require medical attention:")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .lineSpacing(2)
            
            LazyVStack(spacing: 12) {
                ForEach(abnormalResults, id: \.id) { testResult in
                    abnormalResultHighlight(testResult: testResult)
                }
            }
        }
        .padding(20)
        .background(Color.red.opacity(0.05))
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.red.opacity(0.2), lineWidth: 1)
        )
        .cornerRadius(20)
    }
    
    private func abnormalResultHighlight(testResult: BloodTestResult) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(testResult.testName)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.red)
                
                Text("Reference: \(testResult.referenceRange)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                HStack(spacing: 4) {
                    Text(testResult.value)
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundColor(.red)
                    
                    Text(testResult.unit)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Image(systemName: "exclamationmark.circle.fill")
                    .font(.caption)
                    .foregroundColor(.red)
            }
        }
        .padding(12)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.red.opacity(0.1), radius: 4, x: 0, y: 2)
    }
    
    // MARK: - Categorized Test Results Card
    private var categorizedTestResultsCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "chart.bar.fill")
                    .font(.title2)
                    .foregroundColor(.blue)
                
                Text("Detailed Results")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Text("\(bloodReport.testResults.count) tests")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            // Group results by category if we can infer categories, otherwise show all results
            let groupedResults = Dictionary(grouping: bloodReport.testResults) { result in
                inferCategory(for: result.testName)
            }
            
            LazyVStack(spacing: 16) {
                ForEach(Array(groupedResults.keys.sorted()), id: \.self) { category in
                    if let results = groupedResults[category] {
                        categorySection(category: category, results: results)
                    }
                }
            }
        }
        .padding(20)
        .background(Color(UIColor.systemBackground))
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 4)
    }
    
    private func categorySection(category: String, results: [BloodTestResult]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(category)
                    .font(.headline)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                
                Spacer()
                
                let abnormalInCategory = results.filter { $0.isAbnormal }.count
                if abnormalInCategory > 0 {
                    HStack(spacing: 4) {
                        Image(systemName: "exclamationmark.circle.fill")
                            .font(.caption)
                            .foregroundColor(.red)
                        
                        Text("\(abnormalInCategory) abnormal")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.red)
                    }
                }
            }
            
            LazyVStack(spacing: 8) {
                ForEach(results, id: \.id) { testResult in
                    enhancedTestResultRow(testResult: testResult)
                }
            }
        }
        .padding(16)
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(16)
    }
    
    private func enhancedTestResultRow(testResult: BloodTestResult) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(testResult.testName)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(testResult.isAbnormal ? .red : .primary)
                
                Text("Ref: \(testResult.referenceRange)")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            HStack(spacing: 8) {
                VStack(alignment: .trailing, spacing: 2) {
                    HStack(spacing: 4) {
                        Text(testResult.value)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(testResult.isAbnormal ? .red : .primary)
                        
                        Text(testResult.unit)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    HStack(spacing: 4) {
                        Image(systemName: testResult.isAbnormal ? "exclamationmark.circle.fill" : "checkmark.circle.fill")
                            .font(.caption2)
                            .foregroundColor(testResult.isAbnormal ? .red : .green)
                        
                        Text(testResult.isAbnormal ? "Abnormal" : "Normal")
                            .font(.caption2)
                            .fontWeight(.medium)
                            .foregroundColor(testResult.isAbnormal ? .red : .green)
                    }
                }
                
                // Visual indicator bar
                Rectangle()
                    .fill(testResult.isAbnormal ? Color.red : Color.green)
                    .frame(width: 3, height: 40)
                    .cornerRadius(1.5)
            }
        }
        .padding(.vertical, 8)
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
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "note.text")
                    .font(.title2)
                    .foregroundColor(.indigo)
                
                Text("Notes")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
            }
            
            Text(bloodReport.notes)
                .font(.subheadline)
                .lineSpacing(4)
        }
        .padding(20)
        .background(Color(UIColor.systemBackground))
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 4)
    }
    
    // MARK: - Document Card
    private func documentCard(reportURL: String) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "doc.richtext.fill")
                    .font(.title2)
                    .foregroundColor(.orange)
                
                Text("Lab Report Document")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Spacer()
            }
            
            // Document preview section
            HStack(spacing: 16) {
                // Document icon
                VStack {
                    Image(systemName: "doc.text.fill")
                        .font(.system(size: 32))
                        .foregroundColor(.orange)
                    
                    Text("PDF")
                        .font(.caption2)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                }
                .frame(width: 60, height: 60)
                .background(Color.orange.opacity(0.1))
                .cornerRadius(12)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("\(bloodReport.testName) Report")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .lineLimit(2)
                    
                    Text("Lab: \(bloodReport.labName)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("Generated: \(bloodReport.resultDate, style: .date)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            
            // Action buttons
            HStack(spacing: 12) {
                Button(action: {
                    if let url = URL(string: reportURL) {
                        UIApplication.shared.open(url)
                    }
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "eye.fill")
                            .font(.subheadline)
                        Text("View Report")
                            .font(.subheadline)
                            .fontWeight(.medium)
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(Color.orange)
                    .cornerRadius(10)
                }
                
                Button(action: {
                    // Handle sharing
                    if let url = URL(string: reportURL) {
                        let activityController = UIActivityViewController(activityItems: [url], applicationActivities: nil)
                        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                           let rootViewController = windowScene.windows.first?.rootViewController {
                            rootViewController.present(activityController, animated: true)
                        }
                    }
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "square.and.arrow.up")
                            .font(.subheadline)
                        Text("Share")
                            .font(.subheadline)
                            .fontWeight(.medium)
                    }
                    .foregroundColor(.orange)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(Color.orange.opacity(0.1))
                    .cornerRadius(10)
                }
                
                Spacer()
            }
        }
        .padding(20)
        .background(Color(UIColor.systemBackground))
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 4)
    }
    
    // MARK: - Metadata Card
    private var metadataCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "info.circle.fill")
                    .font(.title2)
                    .foregroundColor(.blue)
                
                Text("Report Information")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Spacer()
            }
            
            VStack(spacing: 16) {
                // Dates section
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Test Date")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .textCase(.uppercase)
                        
                        Text(bloodReport.resultDate, style: .date)
                            .font(.subheadline)
                            .fontWeight(.medium)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("Days Ago")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .textCase(.uppercase)
                        
                        let daysAgo = Calendar.current.dateComponents([.day], from: bloodReport.resultDate, to: Date()).day ?? 0
                        Text("\(daysAgo) days")
                            .font(.subheadline)
                            .fontWeight(.medium)
                    }
                }
                
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: 1)
                
                // Record dates section
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Added to Records")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .textCase(.uppercase)
                        
                        Text(bloodReport.createdAt, style: .date)
                            .font(.subheadline)
                            .fontWeight(.medium)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("Last Updated")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .textCase(.uppercase)
                        
                        Text(bloodReport.updatedAt, style: .relative)
                            .font(.subheadline)
                            .fontWeight(.medium)
                    }
                }
                
                if !bloodReport.category.isEmpty {
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 1)
                    
                    // Category section
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Test Category")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .textCase(.uppercase)
                            
                            Text(bloodReport.category)
                                .font(.subheadline)
                                .fontWeight(.medium)
                        }
                        
                        Spacer()
                        
                        Image(systemName: "tag.fill")
                            .font(.title2)
                            .foregroundColor(.blue)
                    }
                }
            }
        }
        .padding(20)
        .background(Color(UIColor.systemBackground))
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 4)
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
    let sampleBloodReport = BloodReport(
        testName: "Complete Blood Count with Differential",
        labName: "Quest Diagnostics",
        category: "Hematology",
        resultDate: Date().addingTimeInterval(-86400 * 3),
        reportURL: "https://example.com/report.pdf",
        notes: "Routine annual physical examination. Patient fasting for 12 hours prior to blood draw. All standard precautions followed.",
        medicalCase: sampleCase
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

