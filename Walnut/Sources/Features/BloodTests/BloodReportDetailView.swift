//
//  BloodReportDetailView.swift
//  Walnut
//
//  Created by Mayank Gandhi on 29/07/25.
//  Copyright © 2025 m. All rights reserved.
//

import SwiftUI
import SwiftData
import Charts
import WalnutDesignSystem

struct BloodReportDetailView: View {
    
    @Bindable var bloodReport: BloodReport
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedCategory: String?
    @State private var showAllTests = false
    @State private var showEditor = false
    
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
        .sheet(isPresented: $showEditor) {
            if bloodReport.medicalCase == nil {
                ContentUnavailableView(
                    "Unable to edit this blood report.",
                    systemImage: "exclamationmark.triangle.fill"
                )
            } else {
                BloodReportEditor(
                    bloodReport: bloodReport,
                    medicalCase: bloodReport.medicalCase!
                )
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu("", systemImage: "ellipsis") {
                    Button {
                        showEditor = true
                    } label: {
                        Label("Edit", systemImage: "pencil")
                    }
                }
            }
        }
        .navigationTitle(Text("Blood Test"))
        .navigationBarTitleDisplayMode(.inline)
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
            
            LazyVStack {
                ForEach(
                    (bloodReport.testResults ?? []).map({ BioMarker.init(from: $0) }),
                    id: \.id
                ) { biomarker in
                    BioMarkerGridItemView(biomarker: biomarker)
                }
            }
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
        BioMarkerResult(
            testName: "Hemoglobin",
            value: "13.8",
            unit: "g/dL",
            referenceRange: "12.0-15.5",
            isAbnormal: false,
            bloodReport: sampleBloodReport
        ),
        BioMarkerResult(
            testName: "Hematocrit",
            value: "41.2",
            unit: "%",
            referenceRange: "36.0-46.0",
            isAbnormal: false,
            bloodReport: sampleBloodReport
        ),
        BioMarkerResult(
            testName: "White Blood Cell Count",
            value: "12.5",
            unit: "K/uL",
            referenceRange: "4.5-11.0",
            isAbnormal: true,
            bloodReport: sampleBloodReport
        ),
        BioMarkerResult(
            testName: "Red Blood Cell Count",
            value: "4.65",
            unit: "M/uL",
            referenceRange: "4.20-5.40",
            isAbnormal: false,
            bloodReport: sampleBloodReport
        ),
        BioMarkerResult(
            testName: "Platelets",
            value: "285",
            unit: "K/uL",
            referenceRange: "150-450",
            isAbnormal: false,
            bloodReport: sampleBloodReport
        ),
        BioMarkerResult(
            testName: "Glucose, Fasting",
            value: "110",
            unit: "mg/dL",
            referenceRange: "70-99",
            isAbnormal: true,
            bloodReport: sampleBloodReport
        ),
        BioMarkerResult(
            testName: "Total Cholesterol",
            value: "195",
            unit: "mg/dL",
            referenceRange: "<200",
            isAbnormal: false,
            bloodReport: sampleBloodReport
        ),
        BioMarkerResult(
            testName: "HDL Cholesterol",
            value: "58",
            unit: "mg/dL",
            referenceRange: ">40",
            isAbnormal: false,
            bloodReport: sampleBloodReport
        ),
        BioMarkerResult(
            testName: "LDL Cholesterol",
            value: "118",
            unit: "mg/dL",
            referenceRange: "<100",
            isAbnormal: true,
            bloodReport: sampleBloodReport
        ),
        BioMarkerResult(
            testName: "Triglycerides",
            value: "95",
            unit: "mg/dL",
            referenceRange: "<150",
            isAbnormal: false,
            bloodReport: sampleBloodReport
        ),
        BioMarkerResult(
            testName: "Creatinine",
            value: "0.95",
            unit: "mg/dL",
            referenceRange: "0.60-1.20",
            isAbnormal: false,
            bloodReport: sampleBloodReport
        ),
        BioMarkerResult(
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
    .modelContainer(for: BloodReport.self, inMemory: true)
}

