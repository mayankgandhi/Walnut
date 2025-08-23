//
//  DocumentViewerSheet.swift
//  Walnut
//
//  Created by Mayank Gandhi on 03/08/25.
//  Copyright © 2025 m. All rights reserved.
//

import SwiftUI
import PDFKit

struct DocumentViewerSheet: View {
    let document: Document
    @Environment(\.dismiss) private var dismiss
    @State private var shareSheetPresented = false
    
    var body: some View {
        NavigationView {
            documentContentView
                .navigationTitle(document.fileName)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("Done") {
                            dismiss()
                        }
                    }
                    
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {
                            shareSheetPresented = true
                        }) {
                            Image(systemName: "square.and.arrow.up")
                        }
                    }
                }
                .sheet(isPresented: $shareSheetPresented) {
                    ShareSheet(items: [document.fileURL])
                }
        }
    }
    
    @ViewBuilder
    private var documentContentView: some View {
        switch documentFileType {
        case .pdf:
            PDFDocumentView(url: document.fileURL)
        case .image:
            ImageDocumentView(url: document.fileURL)
        case .unsupported:
            UnsupportedDocumentView(document: document)
        }
    }
    
    private var documentFileType: DocumentFileType {
        let pathExtension = document.fileURL.pathExtension.lowercased()
        
        switch pathExtension {
        case "pdf":
            return .pdf
        case "jpg", "jpeg", "png", "heic", "heif":
            return .image
        default:
            return .unsupported
        }
    }
}

// MARK: - Document File Types
private enum DocumentFileType {
    case pdf
    case image
    case unsupported
}

// MARK: - PDF Document View
private struct PDFDocumentView: View {
    let url: URL
    @State private var showingError = false
    @State private var errorMessage = ""
    @State private var isLoading = true
    @State private var pdfLoadFailed = false
    
    var body: some View {
        Group {
            if !FileManager.default.fileExists(atPath: url.path) {
                DocumentErrorView(
                    title: "PDF Not Found",
                    message: "The PDF document could not be located at:\n\(url.path)",
                    systemImage: "doc.text.fill"
                )
            } else if !FileManager.default.isReadableFile(atPath: url.path) {
                DocumentErrorView(
                    title: "Cannot Access PDF",
                    message: "The PDF document exists but cannot be read. It may be corrupted or you may not have permission to access it.",
                    systemImage: "doc.text.fill"
                )
            } else if pdfLoadFailed {
                DocumentErrorView(
                    title: "Invalid PDF",
                    message: "The file appears to be corrupted or is not a valid PDF document.",
                    systemImage: "doc.text.fill"
                )
            } else if isLoading {
                VStack {
                    ProgressView("Loading PDF...")
                        .scaleEffect(1.2)
                    Text("Please wait while the document loads")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.top, 8)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .onAppear {
                    validatePDF()
                }
            } else {
                PDFKitView(url: url)
                    .background(Color(.systemGroupedBackground))
            }
        }
        .alert("Error", isPresented: $showingError) {
            Button("OK") { }
        } message: {
            Text(errorMessage)
        }
    }
    
    private func validatePDF() {
        DispatchQueue.global(qos: .userInitiated).async {
            // Check file size
            do {
                let attributes = try FileManager.default.attributesOfItem(atPath: url.path)
                if let fileSize = attributes[.size] as? Int64, fileSize == 0 {
                    DispatchQueue.main.async {
                        self.pdfLoadFailed = true
                        self.isLoading = false
                    }
                    return
                }
            } catch {
                DispatchQueue.main.async {
                    self.pdfLoadFailed = true
                    self.isLoading = false
                }
                return
            }
            
            // Try to load PDF document to validate it
            if let pdfDocument = PDFDocument(url: url), pdfDocument.pageCount > 0 {
                DispatchQueue.main.async {
                    self.isLoading = false
                }
            } else {
                DispatchQueue.main.async {
                    self.pdfLoadFailed = true
                    self.isLoading = false
                }
            }
        }
    }
}

// MARK: - Image Document View
private struct ImageDocumentView: View {
    let url: URL
    @State private var uiImage: UIImage?
    @State private var isLoading = true
    @State private var loadingError: String?
    
    var body: some View {
        Group {
            if isLoading {
                ProgressView("Loading image...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if let uiImage = uiImage {
                ScrollView([.horizontal, .vertical]) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .padding()
                }
                .background(Color.black)
            } else {
                DocumentErrorView(
                    title: "Image Not Found",
                    message: loadingError ?? "The image could not be loaded.",
                    systemImage: "photo.fill"
                )
            }
        }
        .onAppear {
            loadImage()
        }
    }
    
    private func loadImage() {
        guard FileManager.default.fileExists(atPath: url.path) else {
            loadingError = "Image file not found at path: \(url.path)"
            isLoading = false
            return
        }
        
        DispatchQueue.global(qos: .userInitiated).async {
            if let data = try? Data(contentsOf: url),
               let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    self.uiImage = image
                    self.isLoading = false
                }
            } else {
                DispatchQueue.main.async {
                    self.loadingError = "Failed to load image data"
                    self.isLoading = false
                }
            }
        }
    }
}

// MARK: - Unsupported Document View
private struct UnsupportedDocumentView: View {
    let document: Document
    
    var body: some View {
        DocumentErrorView(
            title: "Unsupported Format",
            message: "This document format (\(document.fileURL.pathExtension.uppercased())) is not supported for preview.",
            systemImage: "doc.questionmark.fill"
        )
    }
}

// MARK: - Document Error View
private struct DocumentErrorView: View {
    let title: String
    let message: String
    let systemImage: String
    
    var body: some View {
        VStack(spacing: 24) {
            // Error Icon
            Image(systemName: systemImage)
                .font(.system(size: 72, weight: .light))
                .foregroundColor(.red.opacity(0.7))
            
            VStack(spacing: 12) {
                // Error Title
                Text(title)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.center)
                
                // Error Message
                Text(message)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .padding(.horizontal, 32)
            }
            
            VStack(spacing: 16) {
                Divider()
                    .padding(.horizontal, 40)
                
                // Helpful suggestions
                VStack(alignment: .leading, spacing: 8) {
                    Text("What you can try:")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Label("Check if the document was moved or deleted", systemImage: "questionmark.circle")
                        Label("Try re-uploading the document", systemImage: "arrow.clockwise")
                        Label("Contact support if the issue persists", systemImage: "envelope")
                    }
                    .font(.caption)
                    .foregroundColor(.secondary)
                }
                .padding(.horizontal, 40)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGroupedBackground))
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

#Preview {
    DocumentViewerSheet(document: Document.document)
}