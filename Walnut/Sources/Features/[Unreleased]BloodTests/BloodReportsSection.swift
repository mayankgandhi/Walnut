//
//  BloodReportsSection.swift
//  Walnut
//
//  Created by Mayank Gandhi on 03/08/25.
//  Copyright © 2025 m. All rights reserved.
//

import SwiftUI

// MARK: - Blood Reports Section
struct BloodReportsSection: View {
    
    @State var selectedBloodReport: BloodReport?
    let medicalCase: MedicalCase
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Section Header
            BloodReportsSectionHeader(
                medicalCase: medicalCase,
                reportCount: medicalCase.bloodReports.count
            )
            
            // List
            LazyVStack(spacing: 12) {
                ForEach(medicalCase.bloodReports) { bloodReport in
                    BloodReportScrollListItem(bloodReport: bloodReport)
                        .onTapGesture {
                            selectedBloodReport = bloodReport
                        }
                }
            }
        }
        .padding(.horizontal, 16)
        .navigationDestination(item: $selectedBloodReport) { bloodReport in
            BloodReportDetailView(bloodReport: bloodReport)
        }
    }
}

// MARK: - Blood Reports Section Header
struct BloodReportsSectionHeader: View {
    
    let medicalCase: MedicalCase
    let reportCount: Int
    @State private var showAddBloodReport = false
    
    init(medicalCase: MedicalCase,
         reportCount: Int,
         showAddBloodReport: Bool = false) {
        self.medicalCase = medicalCase
        self.reportCount = reportCount
        self.showAddBloodReport = showAddBloodReport
    }
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 8) {
                    Image(systemName: "testtube.2")
                        .font(.title2)
                        .foregroundColor(.red)

                    Text("Blood Reports")
                        .font(.title2)
                        .fontWeight(.bold)
                }
                
                Text("\(reportCount) reports")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Button {
                showAddBloodReport = true
            } label: {
                Image(systemName: "doc.badge.plus")
            }
        }
        .bloodReportDocumentPicker(for: medicalCase, isPresented: $showAddBloodReport)
    }
}

// MARK: - Blood Report List Item
struct BloodReportScrollListItem: View {
    let bloodReport: BloodReport
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header with test name and date
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(bloodReport.testName)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text(bloodReport.resultDate, style: .date)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Status indicator
                Image(systemName: "testtube.2")
                    .foregroundColor(.red)
                    .font(.title2)
            }
            
            if !bloodReport.labName.isEmpty {
                Text(bloodReport.labName)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
            
            // Category and results count
            HStack {
                if !bloodReport.category.isEmpty {
                    HStack {
                        Image(systemName: "tag")
                            .foregroundColor(.orange)
                            .font(.caption)
                        
                        Text(bloodReport.category)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                if !bloodReport.testResults.isEmpty {
                    HStack {
                        Image(systemName: "number")
                            .foregroundColor(.blue)
                            .font(.caption)
                        
                        Text("\(bloodReport.testResults.count) results")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        let abnormalCount = bloodReport.testResults.filter(\.isAbnormal).count
                        if abnormalCount > 0 {
                            Text("•")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            Text("\(abnormalCount) abnormal")
                                .font(.caption)
                                .foregroundColor(.red)
                        }
                    }
                }
            }
        }
        .padding(16)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
        .contentShape(Rectangle())
    }
}
