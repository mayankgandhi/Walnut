//
//  DocumentCard.swift
//  Walnut
//
//  Created by Mayank Gandhi on 22/08/25.
//  Copyright © 2025 m. All rights reserved.
//

import SwiftUI
import WalnutDesignSystem

struct DocumentCard: View {
    let document: Document?
    let title: String
    let viewButtonText: String
    
    init(
        document: Document?,
        title: String,
        viewButtonText: String = "View Document"
    ) {
        self.document = document
        self.title = title
        self.viewButtonText = viewButtonText
    }
    
    var body: some View {
        HealthCard {
            VStack(alignment: .leading, spacing: Spacing.medium) {
                // Header Section
                HStack(spacing: Spacing.small) {
                    Circle()
                        .fill(Color.blue.opacity(0.2))
                        .frame(width: 36, height: 36)
                        .overlay {
                            Image(systemName: "doc.text.fill")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundStyle(.blue)
                        }
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(title)
                            .font(.headline.weight(.bold))
                            .foregroundStyle(.primary)
                        
                        if let document = document {
                            Text(document.fileName)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .lineLimit(1)
                        }
                    }
                    
                    Spacer()
                }
                
                // Action Buttons Section
                if let document = document {
                    HStack(spacing: Spacing.medium) {
                        Button(action: {
                            viewDocument(document)
                        }) {
                            HStack(spacing: Spacing.xs) {
                                Image(systemName: "eye.fill")
                                    .font(.caption)
                                Text(viewButtonText)
                                    .font(.caption.weight(.medium))
                            }
                            .foregroundStyle(.white)
                            .padding(.horizontal, Spacing.medium)
                            .padding(.vertical, Spacing.small)
                            .background(.blue)
                            .clipShape(Capsule())
                        }
                        
                        Button(action: {
                            shareDocument(document)
                        }) {
                            HStack(spacing: Spacing.xs) {
                                Image(systemName: "square.and.arrow.up")
                                    .font(.caption)
                                Text("Share")
                                    .font(.caption.weight(.medium))
                            }
                            .foregroundStyle(.blue)
                            .padding(.horizontal, Spacing.medium)
                            .padding(.vertical, Spacing.small)
                            .background(Color.blue.opacity(0.1))
                            .clipShape(Capsule())
                        }
                        
                        Spacer()
                    }
                }
            }
        }
    }
    
    // MARK: - Internal Functions
    
    private func viewDocument(_ document: Document) {
        // Open document using UIDocumentInteractionController
        let documentController = UIDocumentInteractionController(url: document.fileURL)
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootViewController = windowScene.windows.first?.rootViewController {
            documentController.presentPreview(animated: true)
            documentController.delegate = rootViewController as? UIDocumentInteractionControllerDelegate
        }
    }
    
    private func shareDocument(_ document: Document) {
        let activityController = UIActivityViewController(
            activityItems: [document.fileURL],
            applicationActivities: nil
        )
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootViewController = windowScene.windows.first?.rootViewController {
            // For iPad
            if let popoverController = activityController.popoverPresentationController {
                popoverController.sourceView = rootViewController.view
                popoverController.sourceRect = CGRect(x: rootViewController.view.bounds.midX, y: rootViewController.view.bounds.midY, width: 0, height: 0)
                popoverController.permittedArrowDirections = []
            }
            
            rootViewController.present(activityController, animated: true)
        }
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: Spacing.large) {
        // Prescription Document Card
        DocumentCard(
            document: Document.sampleDocument,
            title: "Prescription Document",
            viewButtonText: "View Document"
        )
        
        // Blood Report Document Card
        DocumentCard(
            document: Document.sampleDocument,
            title: "Lab Report Document",
            viewButtonText: "View Report"
        )
        
        // Generic Medical Document Card
        DocumentCard(
            document: Document.sampleDocument,
            title: "X-Ray Results",
            viewButtonText: "View X-Ray"
        )
    }
    .padding()
}

// MARK: - Sample Data Extension

private extension Document {
    static let sampleDocument = Document(
        fileName: "Blood_Test_Results_2024.pdf",
        fileURL: URL(string: "file://sample.pdf")!,
        documentType: .consultation,
        uploadDate: Date(),
        fileSize: 1024000,
        createdAt: Date(),
        updatedAt: Date()
    )
}
