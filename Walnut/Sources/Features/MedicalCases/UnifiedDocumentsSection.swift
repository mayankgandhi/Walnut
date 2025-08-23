//
//  UnifiedDocumentsSection.swift
//  Walnut
//
//  Created by Mayank Gandhi on 22/08/25.
//  Copyright © 2025 m. All rights reserved.
//

import SwiftUI
import WalnutDesignSystem

struct UnifiedDocumentsSection: View {
    let medicalCase: MedicalCase
    
    @State private var selectedPrescription: Prescription?
    @State private var selectedBloodReport: BloodReport?
    @State private var selectedDocument: Document?
    
    @State private var showAddDocument = false
    @State private var isRetrying = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.medium) {
            // Enhanced Section Header
            
            HStack(spacing: Spacing.medium) {
                // Dynamic icon with gradient background
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.healthPrimary.opacity(0.2),
                                    Color.healthPrimary.opacity(0.05)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 48, height: 48)
                        .shadow(color: Color.healthPrimary.opacity(0.2), radius: 4, x: 0, y: 2)
                    
                    Image(systemName: "folder.fill.badge.plus")
                        .font(.title3.weight(.semibold))
                        .foregroundStyle(Color.healthPrimary)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Medical Documents")
                        .font(.headline.weight(.bold))
                        .foregroundStyle(.primary)
                    
                    HStack {
                        Text("\(totalDocumentCount) documents")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        
                        if unparsedCount > 0 {
                            Text("•")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                            
                            Text("\(unparsedCount) need attention")
                                .font(.subheadline.weight(.medium))
                                .foregroundStyle(.orange)
                        }
                        
                        if abnormalResultsCount > 0 {
                            Text("•")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                            
                            Text("\(abnormalResultsCount) abnormal")
                                .font(.subheadline.weight(.medium))
                                .foregroundStyle(Color.healthError)
                        }
                    }
                }
                
                Spacer()
                
                // Add button with subtle animation
                Button(action: { showAddDocument = true }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                        .foregroundStyle(Color.healthPrimary)
                        .scaleEffect(showAddDocument ? 0.9 : 1.0)
                }
                .buttonStyle(PlainButtonStyle())
                
                
            }
            
            if allDocuments.isEmpty {
                // Modern empty state
                VStack(spacing: Spacing.large) {
                    ZStack {
                        Circle()
                            .fill(Color.healthPrimary.opacity(0.1))
                            .frame(width: 80, height: 80)
                        
                        Image(systemName: "doc.badge.plus")
                            .font(.system(size: 32, weight: .light))
                            .foregroundStyle(Color.healthPrimary.opacity(0.6))
                    }
                    
                    VStack(spacing: Spacing.small) {
                        Text("No documents yet")
                            .font(.title3.weight(.semibold))
                            .foregroundStyle(.primary)
                        
                        Text("Add medical documents to track prescriptions, lab results, and more")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .lineLimit(nil)
                    }
                    
                    Button("Add First Document") {
                        showAddDocument = true
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(Color.healthPrimary)
                    .controlSize(.large)
                }
                .padding(.vertical, Spacing.xl)
                .transition(.opacity.combined(with: .scale(scale: 0.95)))
            } else {
                // Rich document list with grouping
                LazyVStack(spacing: Spacing.small) {
                    ForEach(allDocuments, id: \.id) { item in
                        documentRow(for: item)
                            .transition(.asymmetric(
                                insertion: .move(edge: .top).combined(with: .opacity),
                                removal: .move(edge: .trailing).combined(with: .opacity)
                            ))
                    }
                }
                .transition(.opacity.combined(with: .move(edge: .top)))
                .navigationDestination(item: $selectedPrescription) { prescription in
                    PrescriptionDetailView(prescription: prescription)
                }
                .navigationDestination(item: $selectedBloodReport) { bloodReport in
                    BloodReportDetailView(bloodReport: bloodReport)
                }
                .navigationDestination(item: $selectedDocument) { document in
                    DocumentDetailView(document: document)
                }
                .documentPicker(for: medicalCase, isPresented: $showAddDocument)
            }
            
        }
        .padding(.horizontal)
        
    }
    
    // MARK: - Document Row Builder
    
    @ViewBuilder
    private func documentRow(for item: DocumentItem) -> some View {
        Group {
            switch item {
            case .prescription(let prescription):
                FileIcon(
                    filename: formatPrescriptionTitle(prescription),
                    subtitle: formatPrescriptionSubtitle(prescription),
                    documentType: .prescription
                )
                .onTapGesture {
                    selectedPrescription = prescription
                }
                .contextMenu {
                    prescriptionContextMenu(for: prescription)
                }
                
            case .bloodReport(let bloodReport):
                FileIcon(
                    filename: formatBloodReportTitle(bloodReport),
                    subtitle: formatBloodReportSubtitle(bloodReport),
                    documentType: .labResult
                )
                .onTapGesture {
                    selectedBloodReport = bloodReport
                }
                .contextMenu {
                    bloodReportContextMenu(for: bloodReport)
                }
                
            case .unparsedDocument(let document):
                HStack {
                    FileIcon(
                        filename: formatUnparsedDocumentTitle(document),
                        subtitle: formatUnparsedDocumentSubtitle(document),
                        documentType: .unknown,
                        iconColor: .orange,
                        backgroundColor: .orange
                    )
                    .onTapGesture {
                        selectedDocument = document
                    }
                    
                    Button(action: { retryParsing(document) }) {
                        HStack(spacing: 4) {
                            if isRetrying {
                                ProgressView()
                                    .controlSize(.mini)
                                    .tint(.orange)
                            } else {
                                Image(systemName: "arrow.clockwise.circle.fill")
                                    .font(.title3)
                            }
                        }
                        .foregroundStyle(.orange)
                    }
                    .disabled(isRetrying)
                    .padding(.trailing, Spacing.medium)
                }
                .contextMenu {
                    unparsedDocumentContextMenu(for: document)
                }
            }
        }
    }
    
    // MARK: - Computed Properties
    
    private var allDocuments: [DocumentItem] {
        var items: [DocumentItem] = []
        
        // Add prescriptions
        items.append(contentsOf: medicalCase.prescriptions.map { .prescription($0) })
        
        // Add blood reports
        items.append(contentsOf: medicalCase.bloodReports.map { .bloodReport($0) })
        
        // Add unparsed documents
        items.append(contentsOf: medicalCase.unparsedDocuments.map { .unparsedDocument($0) })
        
        // Sort by date (most recent first)
        return items.sorted { item1, item2 in
            item1.sortDate > item2.sortDate
        }
    }
    
    private var totalDocumentCount: Int {
        medicalCase.prescriptions.count +
        medicalCase.bloodReports.count +
        medicalCase.unparsedDocuments.count
    }
    
    private var unparsedCount: Int {
        medicalCase.unparsedDocuments.count
    }
    
    private var abnormalResultsCount: Int {
        medicalCase.bloodReports.flatMap(\.testResults).filter(\.isAbnormal).count
    }
    
    // MARK: - Helper Methods
    
    private func formatPrescriptionTitle(_ prescription: Prescription) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        return "Prescription - \(dateFormatter.string(from: prescription.dateIssued))"
    }
    
    private func formatPrescriptionSubtitle(_ prescription: Prescription) -> String {
        var components: [String] = []
        
        if let doctorName = prescription.doctorName {
            components.append("Dr. \(doctorName)")
        }
        
        if let facilityName = prescription.facilityName {
            components.append(facilityName)
        }
        
        if prescription.followUpDate != nil {
            components.append("Follow-up required")
        }
        
        return components.isEmpty ? "Prescription document" : components.joined(separator: " • ")
    }
    
    private func formatBloodReportTitle(_ bloodReport: BloodReport) -> String {
        return bloodReport.testName
    }
    
    private func formatBloodReportSubtitle(_ bloodReport: BloodReport) -> String {
        var components: [String] = []
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        components.append(dateFormatter.string(from: bloodReport.resultDate))
        
        if !bloodReport.labName.isEmpty {
            components.append(bloodReport.labName)
        }
        
        let abnormalCount = bloodReport.testResults.filter(\.isAbnormal).count
        if abnormalCount > 0 {
            components.append("\(abnormalCount) abnormal results")
        } else if !bloodReport.testResults.isEmpty {
            components.append("\(bloodReport.testResults.count) results")
        }
        
        return components.joined(separator: " • ")
    }
    
    private func formatUnparsedDocumentTitle(_ document: Document) -> String {
        return document.fileName
    }
    
    private func formatUnparsedDocumentSubtitle(_ document: Document) -> String {
        var components: [String] = []
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        components.append(dateFormatter.string(from: document.uploadDate))
        
        let fileSize = ByteCountFormatter.string(fromByteCount: document.fileSize, countStyle: .file)
        components.append(fileSize)
        
        components.append("Parsing failed")
        
        return components.joined(separator: " • ")
    }
    
    private func retryParsing(_ document: Document) {
        isRetrying = true
        // TODO: Implement retry parsing logic
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            isRetrying = false
        }
    }
    
    // MARK: - Context Menus
    
    @ViewBuilder
    private func prescriptionContextMenu(for prescription: Prescription) -> some View {
        Button {
            // Edit prescription
        } label: {
            Label("Edit Prescription", systemImage: "pencil")
        }
        
        Button {
            selectedPrescription = prescription
        } label: {
            Label("View Details", systemImage: "eye")
        }
        
        Divider()
        
        Button {
            shareDocument(prescription.document)
        } label: {
            Label("Share Document", systemImage: "square.and.arrow.up")
        }
        .disabled(prescription.document == nil)
    }
    
    @ViewBuilder
    private func bloodReportContextMenu(for bloodReport: BloodReport) -> some View {
        Button {
            selectedBloodReport = bloodReport
        } label: {
            Label("View Details", systemImage: "eye")
        }
        
        Divider()
        
        Button {
            shareDocument(bloodReport.document)
        } label: {
            Label("Share Document", systemImage: "square.and.arrow.up")
        }
        .disabled(bloodReport.document == nil)
    }
    
    @ViewBuilder
    private func unparsedDocumentContextMenu(for document: Document) -> some View {
        Button {
            retryParsing(document)
        } label: {
            Label("Retry Parsing", systemImage: "arrow.clockwise")
        }
        
        Button {
            selectedDocument = document
        } label: {
            Label("View Document", systemImage: "eye")
        }
        
        Divider()
        
        Button {
            shareDocument(document)
        } label: {
            Label("Share Document", systemImage: "square.and.arrow.up")
        }
        
    }
    
    private func shareDocument(_ document: Document?) {
        guard let document = document else { return }
        
        let activityController = UIActivityViewController(
            activityItems: [document.fileURL],
            applicationActivities: nil
        )
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootViewController = windowScene.windows.first?.rootViewController {
            rootViewController.present(activityController, animated: true)
        }
    }
}

// MARK: - Supporting Types

enum DocumentItem {
    case prescription(Prescription)
    case bloodReport(BloodReport)
    case unparsedDocument(Document)
    
    var id: String {
        switch self {
        case .prescription(let prescription):
            return "prescription-\(prescription.id)"
        case .bloodReport(let bloodReport):
            return "bloodReport-\(bloodReport.id)"
        case .unparsedDocument(let document):
            return "document-\(document.id)"
        }
    }
    
    var sortDate: Date {
        switch self {
        case .prescription(let prescription):
            return prescription.dateIssued
        case .bloodReport(let bloodReport):
            return bloodReport.resultDate
        case .unparsedDocument(let document):
            return document.uploadDate
        }
    }
}

// MARK: - Placeholder Views

struct DocumentDetailView: View {
    let document: Document
    
    var body: some View {
        Text("Document Detail View for \(document.fileName)")
            .navigationTitle("Document")
    }
}


#Preview {
    UnifiedDocumentsSection(medicalCase: .sampleCase)
}
