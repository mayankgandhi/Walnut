//
//  BloodTestsView.swift
//  Walnut
//
//  Created by Mayank Gandhi on 28/07/25.
//  Copyright © 2025 m. All rights reserved.
//

import SwiftUI
import SwiftData

struct BloodTestsView: View {
    
    let patient: Patient
    
    @Query private var bloodReports: [BloodReport]
    @Environment(\.modelContext) private var modelContext
    @State private var selectedBloodReport: BloodReport?
    
    init(patient: Patient) {
        self.patient = patient
        let patientID = patient.id
        _bloodReports = Query(
            filter: #Predicate<BloodReport> { report in
                report.medicalCase.patient.id == patientID
            },
            sort: \BloodReport.resultDate,
            order: .reverse
        )
    }
    
    var body: some View {
        List {
            if bloodReports.isEmpty {
                ContentUnavailableView(
                    "No Blood Reports",
                    systemImage: "testtube.2",
                    description: Text("Upload lab reports to track blood test results")
                )
            } else {
                ForEach(bloodReports) { report in
                    BloodReportListItem(bloodReport: report)
                        .onTapGesture {
                            selectedBloodReport = report
                        }
                }
            }
        }
        .navigationTitle("Blood Tests")
        .navigationDestination(item: $selectedBloodReport) { bloodReport in
            BloodReportDetailView(bloodReport: bloodReport)
        }
    }
}

struct BloodReportListItem: View {
    let bloodReport: BloodReport
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(bloodReport.testName)
                        .font(.headline)
                    Text(bloodReport.labName)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text(bloodReport.category)
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(.blue.opacity(0.1))
                        .foregroundColor(.blue)
                        .clipShape(Capsule())
                    
                    Text(bloodReport.resultDate, style: .date)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            if !bloodReport.notes.isEmpty {
                Text(bloodReport.notes)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
            
            if !bloodReport.testResults.isEmpty {
                HStack {
                    Text("\(bloodReport.testResults.count) test results")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    let abnormalCount = bloodReport.testResults.filter(\.isAbnormal).count
                    if abnormalCount > 0 {
                        Text("\(abnormalCount) abnormal")
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                    
                    // Add chevron to indicate tappable
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(.vertical, 4)
        .contentShape(Rectangle()) // Makes entire area tappable
    }
}

#Preview {
    NavigationStack {
        BloodTestsView(patient: Patient.samplePatient)
    }
}
