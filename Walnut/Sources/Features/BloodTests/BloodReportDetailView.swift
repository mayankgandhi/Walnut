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
    @State private var headerScale: CGFloat = 1.0
    @State private var selectedCategory: String?
    @State private var showAllTests = false
    @State private var showingDocumentViewer = false
    @State private var documentToView: Document?
    @State private var showingErrorAlert = false
    @State private var errorMessage = ""
    @Namespace private var heroTransition
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Spacing.xl) {
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
                                document: bloodReport.document,
                                title: "Lab Report Document",
                                viewButtonText: "View Report"
                            )
                        }
                        
                        enhancedMetadataCard
                    }
                }
                .padding(.horizontal, Spacing.medium)
                .padding(.top, Spacing.xl)
                .padding(.bottom, Spacing.xl)
            }
            .background(Color(UIColor.systemGroupedBackground))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .font(.system(size: 16, weight: .semibold))
                }
            }
            .fullScreenCover(isPresented: $showingDocumentViewer) {
                if let document = documentToView {
                    DocumentViewerSheet(document: document)
                }
            }
            .alert("Document Error", isPresented: $showingErrorAlert) {
                Button("OK") { }
            } message: {
                Text(errorMessage)
            }
        }
    }
    
    // MARK: - Enhanced Header Card
    private var enhancedHeaderCard: some View {
        HealthCard(padding: Spacing.large) {
            VStack(spacing: Spacing.large) {
                // Hero Section with enhanced specialty visualization
                HStack(spacing: Spacing.large) {
                    // Enhanced Lab Icon with animated background
                    ZStack {
                        // Animated background gradient
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
                            .frame(width: 80, height: 80)
                            .shadow(color: Color.red.opacity(0.3), radius: 8, x: 0, y: 4)
                        
                        // Subtle pulse ring
                        Circle()
                            .stroke(Color.red.opacity(0.2), lineWidth: 2)
                            .frame(width: 88, height: 88)
                            .scaleEffect(headerScale)
                            .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true), value: headerScale)
                            .onAppear { headerScale = 1.1 }
                        
                        // Main icon with enhanced styling
                        Image(systemName: "drop.fill")
                            .font(.system(size: 32, weight: .semibold, design: .rounded))
                            .foregroundStyle(Color.red)
                            .scaleEffect(1.0)
                            .animation(.spring(response: 0.6, dampingFraction: 0.8), value: bloodReport.testName)
                    }
                    .matchedGeometryEffect(id: "lab-icon", in: heroTransition)
                    
                    // Enhanced content with better hierarchy
                    VStack(alignment: .leading, spacing: Spacing.small) {
                        Text(bloodReport.testName)
                            .font(.title.weight(.bold))
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
                LazyVGrid(columns: [
                    GridItem(.flexible(), spacing: Spacing.small),
                    GridItem(.flexible(), spacing: Spacing.small)
                ], spacing: Spacing.medium) {
                    
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
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.secondary)
                    }
                    .padding(Spacing.small)
                    .background(Color(UIColor.secondarySystemGroupedBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    
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
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.secondary)
                    }
                    .padding(Spacing.small)
                    .background(Color(UIColor.secondarySystemGroupedBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
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

    // Enhanced Test Results Grid using BioMarkerGridItemView
    private var enhancedTestResultsGrid: some View {
        VStack(alignment: .leading, spacing: Spacing.medium) {
            // Section Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Test Results")
                        .font(.title2.weight(.bold))
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
            .padding(.horizontal, Spacing.medium)
            
            // Grid of BioMarker Items
            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: Spacing.medium),
                GridItem(.flexible(), spacing: Spacing.medium)
            ], spacing: Spacing.medium) {
                ForEach(convertToBioMarkers(), id: \.id) { biomarker in
                    BioMarkerGridItemView(
                        biomarker: biomarker,
                        isSelected: false,
                        onTap: {
                            // Handle biomarker selection if needed
                            print("Selected: \(biomarker.name)")
                        }
                    )
                    .frame(height: 180)
                }
            }
            .padding(.horizontal, Spacing.medium)
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
                trend: nil, // BloodTestResult doesn't have trend info
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
        HealthCard {
            VStack(alignment: .leading, spacing: Spacing.medium) {
                HStack(spacing: Spacing.small) {
                    Circle()
                        .fill(Color.healthSuccess.opacity(0.2))
                        .frame(width: 36, height: 36)
                        .overlay {
                            Image(systemName: "note.text")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundStyle(Color.healthSuccess)
                        }
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Clinical Notes")
                            .font(.headline.weight(.bold))
                            .foregroundStyle(.primary)
                        
                        Text("\(bloodReport.notes.count) characters")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    
                    Spacer()
                }
                
                Text(bloodReport.notes)
                    .font(.subheadline)
                    .lineSpacing(4)
                    .foregroundStyle(.primary)
                    .padding(Spacing.small)
                    .background(Color.healthSuccess.opacity(0.05))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.healthSuccess.opacity(0.1), lineWidth: 1)
                    )
            }
        }
    }
    
    // Enhanced Metadata Card
    private var enhancedMetadataCard: some View {
        HealthCard {
            VStack(alignment: .leading, spacing: Spacing.medium) {
                HStack(spacing: Spacing.small) {
                    Circle()
                        .fill(Color.purple.opacity(0.2))
                        .frame(width: 36, height: 36)
                        .overlay {
                            Image(systemName: "info.circle.fill")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundStyle(.purple)
                        }
                    
                    Text("Report Information")
                        .font(.headline.weight(.bold))
                        .foregroundStyle(.primary)
                    
                    Spacer()
                }
                
                LazyVGrid(columns: [
                    GridItem(.flexible(), spacing: Spacing.small),
                    GridItem(.flexible(), spacing: Spacing.small)
                ], spacing: Spacing.medium) {
                    
                    // Days since test
                    VStack(alignment: .leading, spacing: Spacing.xs) {
                        HStack {
                            Image(systemName: "clock")
                                .font(.caption.weight(.medium))
                                .foregroundStyle(.orange)
                            
                            Text("Days Ago")
                                .font(.caption2.weight(.medium))
                                .foregroundStyle(.tertiary)
                            
                            Spacer()
                        }
                        
                        let daysAgo = Calendar.current.dateComponents([.day], from: bloodReport.resultDate, to: Date()).day ?? 0
                        Text("\(daysAgo)")
                            .font(.title3.weight(.bold))
                            .foregroundStyle(.orange)
                    }
                    .padding(Spacing.small)
                    .background(Color(UIColor.secondarySystemGroupedBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    
                    // Total tests
                    VStack(alignment: .leading, spacing: Spacing.xs) {
                        HStack {
                            Image(systemName: "list.number")
                                .font(.caption.weight(.medium))
                                .foregroundStyle(.cyan)
                            
                            Text("Total Tests")
                                .font(.caption2.weight(.medium))
                                .foregroundStyle(.tertiary)
                            
                            Spacer()
                        }
                        
                        Text("\(bloodReport.testResults.count)")
                            .font(.title3.weight(.bold))
                            .foregroundStyle(.cyan)
                    }
                    .padding(Spacing.small)
                    .background(Color(UIColor.secondarySystemGroupedBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                }
            }
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
               
                
                // Document preview section
                HStack(spacing: Spacing.medium) {
                    // Document icon
                   
                    
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
                        viewDocument(document)
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
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                    
                    Button(action: {
                        shareDocument(document)
                    }) {
                        HStack(spacing: Spacing.small) {
                            Image(systemName: "square.and.arrow.up")
                                .font(.subheadline)
                            Text("Share")
                                .font(.subheadline.weight(.medium))
                        }
                        .padding(.horizontal, Spacing.medium)
                        .padding(.vertical, Spacing.small)
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
    
    // MARK: - Document Handling Methods
    
    private func viewDocument(_ document: Document) {
        // Validate file exists
        guard FileManager.default.fileExists(atPath: document.fileURL.path) else {
            errorMessage = "Document not found. The file may have been moved or deleted.\n\nPath: \(document.fileURL.path)"
            showingErrorAlert = true
            return
        }
        
        // Check if file is readable
        guard FileManager.default.isReadableFile(atPath: document.fileURL.path) else {
            errorMessage = "Cannot access document. The file may be corrupted or you may not have permission to read it."
            showingErrorAlert = true
            return
        }
        
        // Check file size to ensure it's not empty or corrupted
        do {
            let attributes = try FileManager.default.attributesOfItem(atPath: document.fileURL.path)
            if let fileSize = attributes[.size] as? Int64, fileSize == 0 {
                errorMessage = "Document appears to be empty or corrupted."
                showingErrorAlert = true
                return
            }
        } catch {
            errorMessage = "Cannot read document information: \(error.localizedDescription)"
            showingErrorAlert = true
            return
        }
        
        // All validations passed, show document
        documentToView = document
        showingDocumentViewer = true
    }
    
    private func shareDocument(_ document: Document) {
        // Validate file exists before sharing
        guard FileManager.default.fileExists(atPath: document.fileURL.path) else {
            errorMessage = "Cannot share document. The file may have been moved or deleted."
            showingErrorAlert = true
            return
        }
        
        // Check if file is readable
        guard FileManager.default.isReadableFile(atPath: document.fileURL.path) else {
            errorMessage = "Cannot access document for sharing. The file may be corrupted."
            showingErrorAlert = true
            return
        }
        
        let activityController = UIActivityViewController(activityItems: [document.fileURL], applicationActivities: nil)
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootViewController = windowScene.windows.first?.rootViewController {
            rootViewController.present(activityController, animated: true)
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

