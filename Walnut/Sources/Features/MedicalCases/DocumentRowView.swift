//
//  DocumentRowView.swift
//  Walnut
//
//  Created by Mayank Gandhi on 29/08/25.
//  Copyright © 2025 m. All rights reserved.
//

import SwiftUI
import WalnutDesignSystem

struct DocumentRowView: View {
    
    let item: DocumentItem
    let viewModel: UnifiedDocumentsSectionViewModel
    
    private var actionHandler: DocumentActionHandler {
        viewModel.createActionHandler(for: item)
    }
    
    private var contextMenuItems: [DocumentContextMenuItem] {
        actionHandler.getContextMenuItems()
    }
    
    var body: some View {
        Group {
            switch item {
                case .prescription(let prescription):
                    prescriptionRow(prescription)
                    
                case .bloodReport(let bloodReport):
                    bloodReportRow(bloodReport)
                    
                case .document(let document):
                    documentRow(document)
            }
        }
        .glassEffect(.clear, in: RoundedRectangle(cornerRadius: 12))
    }
    
    // MARK: - Row Components
    
    @ViewBuilder
    private func prescriptionRow(_ prescription: Prescription) -> some View {
        FileIcon(
            filename: viewModel.formatPrescriptionTitle(prescription),
            subtitle: viewModel.formatPrescriptionSubtitle(prescription),
            documentType: .prescription
        )
        .contentShape(Rectangle())
        .onTapGesture {
            viewModel.selectPrescription(prescription)
        }
        .documentContextMenu(items: contextMenuItems)
    }
    
    @ViewBuilder
    private func bloodReportRow(_ bloodReport: BioMarkerReport) -> some View {
        FileIcon(
            filename: viewModel.formatBioMarkerReportTitle(bloodReport),
            subtitle: viewModel.formatBioMarkerReportSubtitle(bloodReport),
            documentType: .biomarkerReport
        )
        .contentShape(Rectangle())
        .onTapGesture {
            viewModel.selectBioMarkerReport(bloodReport)
        }
        .documentContextMenu(items: contextMenuItems)
    }
    
    @ViewBuilder
    private func documentRow(_ document: Document) -> some View {
        HStack {
            FileIcon(
                filename: viewModel.formatDocumentTitle(document),
                subtitle: viewModel.formatDocumentSubtitle(document),
                documentType: document.documentType ?? .unknown,
                iconColor: document.documentType?.color,
                backgroundColor: document.documentType?.backgroundColor
            )
            .contentShape(Rectangle())
            .onTapGesture {
                viewModel.selectDocument(document)
            }
        }
        .documentContextMenu(items: contextMenuItems)
    }
}

#Preview {
    DocumentRowView(
        item: .prescription(.samplePrescription(for: .sampleCase)),
        viewModel: UnifiedDocumentsSectionViewModel(patient: .samplePatient)
    )
    .padding()
}
