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
    let document: Document
    let title: String
    let viewButtonText: String
    
    @State private var showingDocumentViewer = false
    @State private var shareSheetPresented = false
    
    init(
        document: Document,
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
                
                HealthCardHeader(
                    icon: "doc.text.fill",
                    iconColor: .blue,
                    title: title,
                    subtitle: document.fileName
                )
                                
                // Action Buttons Section
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
        .sheet(isPresented: $showingDocumentViewer) {
            NavigationStack {
                DocumentViewer(document: document)
                    .navigationTitle(document.fileName)
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarLeading) {
                            Button("Done") {
                                showingDocumentViewer = false
                            }
                        }
                    }
            }
        }
        .sheet(isPresented: $shareSheetPresented) {
            ShareSheet(items: [document.fileURL])
        }
    }
    
    // MARK: - Internal Functions
    
    private func viewDocument(_ document: Document) {
        showingDocumentViewer = true
    }
    
    private func shareDocument(_ document: Document) {
        shareSheetPresented = true
    }
}

// MARK: - Share Sheet

private struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: items, applicationActivities: nil)
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

// MARK: - Preview

#Preview("Document Cards") {
    NavigationStack {
        ScrollView {
            VStack(spacing: Spacing.large) {
                VStack(alignment: .leading, spacing: Spacing.medium) {
                    Text("Document Cards")
                        .font(.title2.weight(.bold))
                        .foregroundStyle(.primary)
                    
                    Text("Interactive document cards with view and share functionality")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                // Prescription Document Card
                DocumentCard(
                    document: Document.samplePDFDocument,
                    title: "Prescription Document",
                    viewButtonText: "View Prescription"
                )
                
                // Blood Report Document Card
                DocumentCard(
                    document: Document.sampleImageDocument,
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
        .navigationTitle("Document Cards")
        .navigationBarTitleDisplayMode(.large)
    }
}

// MARK: - Sample Data Extension

private extension Document {
    static let sampleDocument = Document(
        fileName: "Medical_Document.pdf",
        fileURL: "file://medical_document.pdf",
        documentType: .unknown,
        uploadDate: Date(),
        fileSize: 1024000,
        createdAt: Date(),
        updatedAt: Date()
    )
    
    static let samplePDFDocument = Document(
        fileName: "Prescription_Report_2024.pdf",
        fileURL: "file://prescription.pdf",
        documentType: .prescription,
        uploadDate: Date().addingTimeInterval(-86400 * 2), // 2 days ago
        fileSize: 2048000,
        createdAt: Date().addingTimeInterval(-86400 * 2),
        updatedAt: Date().addingTimeInterval(-86400 * 2)
    )
    
    static let sampleImageDocument = Document(
        fileName: "Blood_Test_Results.jpg",
        fileURL: "file://blood_test.jpg",
        documentType: .labResult,
        uploadDate: Date().addingTimeInterval(-86400), // 1 day ago
        fileSize: 512000,
        createdAt: Date().addingTimeInterval(-86400),
        updatedAt: Date().addingTimeInterval(-86400)
    )
}
