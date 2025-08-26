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
    
    @Environment(\.modelContext) private var modelContext
    
    let medicalCase: MedicalCase
    
    @State private var showAddDocument = false
    @State private var navigationState = NavigationState()
    
    private let factory = DocumentFactory.shared
    
    var body: some View {
        VStack(
            alignment: .leading,
            spacing: Spacing.medium
        ) {
            
            HealthCardHeader.medicalDocuments(
                count: totalDocumentCount,
                onAddTap: { showAddDocument = true }
            )
            Group {
                if allDocuments.isEmpty {
                    // Modern empty state
                    VStack(alignment: .center, spacing: Spacing.large) {
                        ZStack {
                            Circle()
                                .fill(Color.healthPrimary.opacity(0.1))
                                .frame(width: 80, height: 80)
                            
                            Image(systemName: "doc.badge.plus")
                                .font(.system(size: 32, weight: .light))
                                .foregroundStyle(Color.healthPrimary.opacity(0.6))
                        }
                        
                        VStack(alignment: .center, spacing: Spacing.small) {
                            Text("No documents yet")
                                .font(.headline.weight(.semibold))
                                .foregroundStyle(.primary)
                            
                            Text("Add medical documents to track prescriptions, lab results, and more")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.center)
                                .lineLimit(nil)
                        }
                        
                        Button {
                            showAddDocument = true
                        } label: {
                            Text("Add First Document")
                                .font(.body)
                                .foregroundStyle(.primary)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(Color.healthPrimary)
                        .controlSize(.large)
                    }
                    .padding(.vertical, Spacing.xl)
                    .transition(.opacity.combined(with: .scale(scale: 0.95)))
                } else {
                    // Rich document list with grouping
                    LazyVStack(alignment: .center, spacing: Spacing.small) {
                        ForEach(allDocuments, id: \.id) { item in
                            documentRow(for: item)
                                .transition(.asymmetric(
                                    insertion: .move(edge: .top).combined(with: .opacity),
                                    removal: .move(edge: .trailing).combined(with: .opacity)
                                ))
                        }
                    }
                    .transition(.opacity.combined(with: .move(edge: .top)))
                    .navigationDestination(item: $navigationState.selectedPrescription) { prescription in
                        PrescriptionDetailView(prescription: prescription)
                    }
                    .navigationDestination(item: $navigationState.selectedBloodReport) { bloodReport in
                        BloodReportDetailView(bloodReport: bloodReport)
                    }
                    .navigationDestination(item: $navigationState.selectedDocument) { document in
                        DocumentViewer(document: document)
                    }
                    
                }
            }
            .sheet(isPresented: $showAddDocument) {
                ModularDocumentPickerView(
                    medicalCase: medicalCase,
                    modelContext: modelContext
                )
            }
        }
    }
    
    // MARK: - Document Row Builder
    
    @ViewBuilder
    private func documentRow(for item: DocumentItem) -> some View {
        let actionHandler = factory.createActionHandler(for: item)
        let contextMenuItems = actionHandler.getContextMenuItems()
        
        Group {
            switch item {
            case .prescription(let prescription):
                FileIcon(
                    filename: formatPrescriptionTitle(prescription),
                    subtitle: formatPrescriptionSubtitle(prescription),
                    documentType: .prescription
                )
                .onTapGesture {
                    navigationState.selectedPrescription = prescription
                }
                .documentContextMenu(items: contextMenuItems)
                
            case .bloodReport(let bloodReport):
                FileIcon(
                    filename: formatBloodReportTitle(bloodReport),
                    subtitle: formatBloodReportSubtitle(bloodReport),
                    documentType: .labResult
                )
                .onTapGesture {
                    navigationState.selectedBloodReport = bloodReport
                }
                .documentContextMenu(items: contextMenuItems)
                
            case .document(let document):
                HStack {
                    FileIcon(
                        filename: formatUnparsedDocumentTitle(document),
                        subtitle: formatUnparsedDocumentSubtitle(document),
                        documentType: document.documentType,
                        iconColor: document.documentType.color,
                        backgroundColor: document.documentType.backgroundColor
                    )
                    .onTapGesture {
                        navigationState.selectedDocument = document
                    }
                }
                .documentContextMenu(items: contextMenuItems)
                
            case .unparsedDocument(let document):
                HStack {
                    FileIcon(
                        filename: formatUnparsedDocumentTitle(document),
                        subtitle: formatUnparsedDocumentSubtitle(document),
                        documentType: document.documentType,
                        iconColor: .orange,
                        backgroundColor: .orange
                    )
                    .onTapGesture {
                        navigationState.selectedDocument = document
                    }
                    
                    // Get retry button from the unparsed document handler
                    if let unparsedHandler = actionHandler as? UnparsedDocumentActionHandler {
                        unparsedHandler.getRetryButton()
                    }
                }
                .documentContextMenu(items: contextMenuItems)
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
        
        items.append(contentsOf: medicalCase.otherDocuments.map { .document($0) })
        
        // Sort by date (most recent first)
        return items.sorted { item1, item2 in
            item1.sortDate > item2.sortDate
        }
    }
    
    private var totalDocumentCount: Int {
        allDocuments.count
    }
    
    private var unparsedCount: Int {
        medicalCase.unparsedDocuments.count
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
            components.append("\(doctorName)")
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
}

// MARK: - Supporting Types

enum DocumentItem {
    case prescription(Prescription)
    case bloodReport(BloodReport)
    case document(Document)
    case unparsedDocument(Document)
    
    var id: String {
        switch self {
        case .prescription(let prescription):
            return "prescription-\(prescription.id)"
        case .bloodReport(let bloodReport):
            return "bloodReport-\(bloodReport.id)"
        case .document(let document):
            return "document-\(document.id)"
        case .unparsedDocument(let document):
            return "unparsedDocument-\(document.id)"
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
        case .document(let document):
            return document.uploadDate
        }
    }
}



#Preview {
    UnifiedDocumentsSection(medicalCase: .sampleCase)
        .padding(Spacing.medium)
    
}
