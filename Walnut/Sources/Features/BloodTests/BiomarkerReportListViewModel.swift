//
//  BiomarkerReportListViewModel.swift
//  Walnut
//
//  Created by Mayank Gandhi on 20/09/25.
//  Copyright © 2025 m. All rights reserved.
//

import Foundation
import SwiftUI
import SwiftData

@Observable
class BiomarkerReportListViewModel {

    private let modelContext: ModelContext
    private let patient: Patient
    var biomarkerReports: [BioMarkerReport] = []
    var isLoading = false
    var errorMessage: String?

    // Navigation State
    var selectedBiomarkerReport: BioMarkerReport?

    init(modelContext: ModelContext, patient: Patient) {
        self.modelContext = modelContext
        self.patient = patient
    }

    @MainActor
    func loadBiomarkerReports() {
        isLoading = true
        errorMessage = nil

        do {
            // Fetch all biomarker reports
            let descriptor = FetchDescriptor<BioMarkerReport>()
            let allReports = try modelContext.fetch(descriptor)

            // Use BiomarkerEngine to filter reports for this patient and validate them
            let patientReports = BiomarkerEngine.filterReportsForPatient(from: allReports, patient: patient)
            biomarkerReports = BiomarkerEngine.validateBioMarkerReports(patientReports)

            // Sort by result date (most recent first)
            biomarkerReports.sort {
                guard let date1 = $0.resultDate, let date2 = $1.resultDate else { return false }
                return date1 > date2
            }

        } catch {
            errorMessage = "Failed to load biomarker reports: \(error.localizedDescription)"
        }

        isLoading = false
    }

    func reportStatus(for report: BioMarkerReport) -> BiomarkerReportStatus {
        // Check if report has any abnormal results
        let hasAbnormalResults = report.testResults?.contains { $0.isAbnormal == true } ?? false

        if hasAbnormalResults {
            return .abnormal
        } else {
            return .normal
        }
    }

    struct BiomarkerReportKey: Hashable {
        let sourceName: String
        let reportSpecialty: MedicalSpecialty?

        init(sourceName: String, reportSpecialty: MedicalSpecialty?) {
            self.sourceName = sourceName
            self.reportSpecialty = reportSpecialty
        }
    }

    func groupedBiomarkerReports() -> [(key: BiomarkerReportKey, reports: [BioMarkerReport])] {
        let grouped = Dictionary(grouping: biomarkerReports) { report in
            // Group by medical case first, then by direct patient association
            if let medicalCase = report.medicalCase,
               let title = medicalCase.title {
                return BiomarkerReportKey(
                    sourceName: title,
                    reportSpecialty: medicalCase.specialty
                )
            } else if report.patient != nil {
                // Direct patient association
                return BiomarkerReportKey(
                    sourceName: "Direct Upload",
                    reportSpecialty: nil
                )
            } else {
                return BiomarkerReportKey(
                    sourceName: "Other",
                    reportSpecialty: nil
                )
            }
        }

        // Sort groups by priority and then alphabetically
        return grouped.map { (key: $0.key, reports: $0.value) }
            .sorted { group1, group2 in
                // Priority order: Direct Upload first, then alphabetical by source name
                if group1.key.sourceName == "Direct Upload" && group2.key.sourceName != "Direct Upload" {
                    return true
                } else if group1.key.sourceName != "Direct Upload" && group2.key.sourceName == "Direct Upload" {
                    return false
                } else {
                    // Both are either Direct Upload or medical cases, sort alphabetically
                    return group1.key.sourceName < group2.key.sourceName
                }
            }
            .map { group in
                // Sort reports within each group by date (most recent first)
                let sortedReports = group.reports.sorted { report1, report2 in
                    guard let date1 = report1.resultDate, let date2 = report2.resultDate else {
                        return false
                    }
                    return date1 > date2
                }
                return (key: group.key, reports: sortedReports)
            }
    }

    /// Get reports that have abnormal results
    func getAbnormalReports() -> [BioMarkerReport] {
        return BiomarkerEngine.filterAbnormalReports(from: biomarkerReports)
    }

    /// Get reports that have only normal results
    func getNormalReports() -> [BioMarkerReport] {
        return BiomarkerEngine.filterNormalReports(from: biomarkerReports)
    }

    /// Get the most recent report for the patient
    func getMostRecentReport() -> BioMarkerReport? {
        return BiomarkerEngine.getMostRecentReportForPatient(from: biomarkerReports, patient: patient)
    }

    // MARK: - Navigation Actions

    func selectBiomarkerReport(_ report: BioMarkerReport) {
        selectedBiomarkerReport = report
    }
}

enum BiomarkerReportStatus {
    case normal
    case abnormal

    var color: Color {
        switch self {
        case .normal:
            return .healthSuccess
        case .abnormal:
            return .healthError
        }
    }

    var displayText: String {
        switch self {
        case .normal:
            return "Normal"
        case .abnormal:
            return "Abnormal"
        }
    }
}