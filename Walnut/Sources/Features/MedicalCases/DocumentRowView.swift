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
                documentRow(document, isUnparsed: false)
                
            case .unparsedDocument(let document):
                documentRow(document, isUnparsed: true)
            }
        }
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
    private func bloodReportRow(_ bloodReport: BloodReport) -> some View {
        FileIcon(
            filename: viewModel.formatBloodReportTitle(bloodReport),
            subtitle: viewModel.formatBloodReportSubtitle(bloodReport),
            documentType: .labResult
        )
        .contentShape(Rectangle())
        .onTapGesture {
            viewModel.selectBloodReport(bloodReport)
        }
        .documentContextMenu(items: contextMenuItems)
    }
    
    @ViewBuilder
    private func documentRow(_ document: Document, isUnparsed: Bool) -> some View {
        HStack {
            FileIcon(
                filename: viewModel.formatUnparsedDocumentTitle(document),
                subtitle: viewModel.formatUnparsedDocumentSubtitle(document),
                documentType: document.documentType ?? .unknown,
                iconColor: isUnparsed ? .orange : document.documentType?.color,
                backgroundColor: isUnparsed ? .orange : document.documentType?.backgroundColor
            )
            .contentShape(Rectangle())
            .onTapGesture {
                viewModel.selectDocument(document)
            }
            
            // Show retry button for unparsed documents
            if isUnparsed, let unparsedHandler = actionHandler as? UnparsedDocumentActionHandler {
                unparsedHandler.getRetryButton()
            }
        }
        .documentContextMenu(items: contextMenuItems)
    }
}

#Preview {
    DocumentRowView(
        item: .prescription(.samplePrescription(for: .sampleCase)),
        viewModel: UnifiedDocumentsSectionViewModel()
    )
    .padding()
}
