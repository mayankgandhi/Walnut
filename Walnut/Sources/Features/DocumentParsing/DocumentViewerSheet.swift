//
//  DocumentViewer.swift
//  Walnut
//
//  Created by Mayank Gandhi on 03/08/25.
//  Copyright © 2025 m. All rights reserved.
//

import SwiftUI
import PDFKit

struct DocumentViewer: View {
    
    let document: Document
    @Environment(\.dismiss) private var dismiss
    @State private var shareSheetPresented = false
    
    var body: some View {
        documentContentView()
            .navigationTitle(document.fileName)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
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
    
    @ViewBuilder
    private func documentContentView() -> some View {
        switch documentFileType {
        case .pdf:
            let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                .appendingPathComponent("WalnutMedicalRecords")
                .appendingPathComponent(document.fileURL)
            return AnyView(PDFDocumentView(url: url))
        case .image:
            let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                .appendingPathComponent("WalnutMedicalRecords")
                .appendingPathComponent(document.fileURL)
            return AnyView(ImageDocumentView(url: url))
        case .unsupported:
            return AnyView(UnsupportedDocumentView(document: document))
        }
    }
    
    private var documentFileType: DocumentFileType {
        let pathExtension = document.fileURL.components(separatedBy: ".").last
        
        switch pathExtension {
        case "pdf", "PDF":
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
    
    private let documentFileManager = DocumentFileManager()
    
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
            message: "This document format (\(document.fileURL) is not supported for preview.",
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
        ContentUnavailableView(
            title,
            systemImage: systemImage,
            description: Text(message)
        )
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
    DocumentViewer(document: Document.document)
}
