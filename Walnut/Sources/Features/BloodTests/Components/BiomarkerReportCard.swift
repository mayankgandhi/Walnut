//
//  BiomarkerReportCard.swift
//  Walnut
//
//  Created by Mayank Gandhi on 20/09/25.
//  Copyright © 2025 m. All rights reserved.
//

import SwiftUI
import WalnutDesignSystem

/// Reusable card component for displaying biomarker report information
struct BiomarkerReportCard: View {

    // MARK: - Properties

    let report: BioMarkerReport

    // MARK: - Body

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.small) {
            // Header with report name/title
            reportHeader

            // Date and category information
            reportDetails

            // Test results count
            testResultsSection

            // Status indicators
            statusSection

            Spacer()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(.thinMaterial)
        .cornerRadius(12)
    }

    // MARK: - Private Views

    private var reportHeader: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            Text(report.testName ?? "Biomarker Report")
                .font(.system(.subheadline, design: .rounded, weight: .semibold))
                .foregroundStyle(.primary)
                .lineLimit(2)
                .multilineTextAlignment(.leading)
        }
    }

    private var reportDetails: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            // Date information
            if let resultDate = report.resultDate {
                Label {
                    Text(resultDate, style: .date)
                        .font(.caption.weight(.medium))
                        .foregroundStyle(Color.healthPrimary)
                } icon: {
                    Image(systemName: "calendar")
                        .font(.caption.weight(.medium))
                        .foregroundStyle(Color.healthPrimary)
                }
                .labelStyle(.titleAndIcon)
            }

            // Category information
            if let category = report.category, !category.isEmpty {
                Label {
                    Text(category)
                        .font(.caption.weight(.medium))
                        .foregroundStyle(Color.healthPrimary)
                } icon: {
                    Image(systemName: "tag")
                        .font(.caption.weight(.medium))
                        .foregroundStyle(Color.healthPrimary)
                }
                .labelStyle(.titleAndIcon)
            }
        }
    }

    private var testResultsSection: some View {
        Group {
            if let testResults = report.testResults, !testResults.isEmpty {
                Label {
                    Text("\(testResults.count) test\(testResults.count == 1 ? "" : "s")")
                        .font(.caption2.weight(.medium))
                        .foregroundStyle(.primary)
                } icon: {
                    Image(systemName: "testtube.2")
                        .font(.caption2)
                        .foregroundStyle(.blue)
                }
                .labelStyle(.titleAndIcon)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }

    private var statusSection: some View {
        Group {
            // Show abnormal results count if any
            let abnormalCount = report.testResults?.filter { $0.isAbnormal == true }.count ?? 0

            if abnormalCount > 0 {
                Label {
                    Text("\(abnormalCount) abnormal")
                        .font(.caption2.weight(.medium))
                        .foregroundStyle(.healthError)
                } icon: {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.caption2)
                        .foregroundStyle(.healthError)
                }
                .labelStyle(.titleAndIcon)
                .frame(maxWidth: .infinity, alignment: .leading)
            } else {
                Label {
                    Text("All normal")
                        .font(.caption2.weight(.medium))
                        .foregroundStyle(.healthSuccess)
                } icon: {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.caption2)
                        .foregroundStyle(.healthSuccess)
                }
                .labelStyle(.titleAndIcon)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }
}


// MARK: - Preview

#Preview {
    VStack(spacing: Spacing.medium) {
        if let sampleReport = BioMarkerReport.sampleReport {
            BiomarkerReportCard(report: sampleReport)
        }
    }
    .padding()
}