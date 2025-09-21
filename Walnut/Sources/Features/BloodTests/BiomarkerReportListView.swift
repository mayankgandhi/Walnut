//
//  BiomarkerReportListView.swift
//  Walnut
//
//  Created by Mayank Gandhi on 20/09/25.
//  Copyright © 2025 m. All rights reserved.
//

import Foundation
import SwiftUI
import SwiftData
import WalnutDesignSystem

struct BiomarkerReportListView: View {
    
    let patient: Patient
    @State private var viewModel: BiomarkerReportListViewModel
    @Environment(\.dismiss) private var dismiss
    
    init(patient: Patient, modelContext: ModelContext) {
        self.patient = patient
        self._viewModel = State(initialValue: BiomarkerReportListViewModel(modelContext: modelContext, patient: patient))
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.medium) {
            
            HStack(spacing: Spacing.small) {
                NavBarHeader(
                    iconName: "health-journal",
                    iconColor: .green,
                    title: "All Biomarker Reports",
                    subtitle: "\(viewModel.biomarkerReports.count) Reports"
                )
                
                Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "xmark")
                }
                .buttonStyle(.glass)
            }
            .padding(.top, Spacing.medium)
            .padding(.trailing, Spacing.medium)
            
            ZStack {
                if viewModel.isLoading {
                    loadingView
                } else if viewModel.biomarkerReports.isEmpty {
                    emptyStateView
                } else {
                    biomarkerReportsContent
                }
            }
        }
        .onAppear {
            viewModel.loadBiomarkerReports()
        }
        .sheet(item: $viewModel.selectedBiomarkerReport) { report in
            NavigationStack {
                BioMarkerReportDetailView(bloodReport: report)
            }
        }
    }
    
    private var loadingView: some View {
        VStack(spacing: Spacing.large) {
            ProgressView()
                .scaleEffect(1.2)
                .progressViewStyle(CircularProgressViewStyle(tint: Color.healthPrimary))
            
            Text("Loading biomarker reports...")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }
    
    private var emptyStateView: some View {
        ContentUnavailableView {
            Label("No Biomarker Reports", systemImage: "testtube.2")
                .symbolRenderingMode(.multicolor)
        } description: {
            Text("This patient currently has no biomarker reports from medical cases.")
                .multilineTextAlignment(.center)
        } actions: {
            Button("Close") {
                dismiss()
            }
            .buttonStyle(.borderedProminent)
            .tint(Color.healthPrimary)
        }
    }
    
    private var biomarkerReportsContent: some View {
        ScrollView {
            LazyVStack(spacing: Spacing.large) {
                biomarkerReportsGroupedList
            }
            .padding(.horizontal, Spacing.medium)
            .padding(.bottom, Spacing.xl)
        }
    }
    
    private var biomarkerReportsGroupedList: some View {
        LazyVStack(spacing: Spacing.large) {
            let groupedReports = viewModel.groupedBiomarkerReports()

            ForEach(Array(groupedReports.enumerated()), id: \.offset) { index, group in
                biomarkerReportGroupSection(
                    key: group.key,
                    reports: group.reports
                )
            }
        }
    }
    
    private func biomarkerReportGroupSection(key: BiomarkerReportListViewModel.BiomarkerReportKey, reports: [BioMarkerReport]) -> some View {
        VStack(alignment: .leading, spacing: Spacing.medium) {
            HStack(alignment: .center, spacing: Spacing.medium) {
                
                if let icon = key.reportSpecialty?.icon {
                    Image(icon)
                        .resizable()
                        .frame(width: 64, height: 64 )
                }
                
                VStack(alignment: .leading, spacing: Spacing.xs) {
                    Text(key.sourceName)
                        .font(.title3.weight(.semibold))
                        .foregroundStyle(.primary)
                    
                    Text("\(reports.count) report\(reports.count == 1 ? "" : "s")")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
            }
            
            LazyVGrid(
                columns: [
                    GridItem(.flexible(), spacing: Spacing.small),
                    GridItem(.flexible(), spacing: Spacing.small)
                ],
                spacing: Spacing.small
            ) {
                ForEach(reports, id: \.id) { report in
                    BiomarkerReportCard(report: report)
                        .onTapGesture {
                            viewModel.selectBiomarkerReport(report)
                        }
                }
            }
        }
    }
    
    
    private func statusBadge(for report: BioMarkerReport) -> some View {
        let status = viewModel.reportStatus(for: report)
        
        return HStack(spacing: Spacing.xs) {
            Circle()
                .fill(status.color)
                .frame(width: 8, height: 8)
            
            Text(status.displayText)
                .font(.caption.weight(.medium))
                .foregroundStyle(status.color)
        }
        .padding(.horizontal, Spacing.small)
        .padding(.vertical, Spacing.xs)
        .background(status.color.opacity(0.1))
        .clipShape(Capsule())
    }
    
}

#Preview {
    BiomarkerReportListView(patient: .samplePatient, modelContext: ModelContext(try! ModelContainer(for: Patient.self)))
}
