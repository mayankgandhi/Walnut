//
//  DocumentData.swift
//  Walnut-Playground
//
//  Created by Mayank Gandhi on 02/07/25.
//  Copyright © 2025 m. All rights reserved.
//


import SwiftUI
import PDFKit

// Documents Section View
struct MedicalCaseDocumentsSection: View {
    let documents: [DocumentData]
    @State private var selectedDocument: DocumentData?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Section Header
            HStack {
                Label("Documents", systemImage: "doc.text.fill")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Text("\(documents.count)")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
                    .background(Color.gray.opacity(0.15))
                    .cornerRadius(12)
            }
            .padding(.horizontal, 20)
            
            if documents.isEmpty {
                EmptyDocumentsView()
                    .padding(.horizontal, 20)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(documents) { document in
                            DocumentCard(document: document)
                                .onTapGesture {
                                    selectedDocument = document
                                }
                        }
                    }
                    .padding(.horizontal, 20)
                }
            }
        }
        .sheet(item: $selectedDocument) { document in
            DocumentDetailView(document: document)
        }
    }
}

// Individual Document Card
struct DocumentCard: View {
    let document: DocumentData
    @State private var thumbnailImage: UIImage?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Document Preview
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.gray.opacity(0.1))
                    .frame(width: 160, height: 200)
                
                if let thumbnailImage = thumbnailImage {
                    Image(uiImage: thumbnailImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 160, height: 200)
                        .clipped()
                        .cornerRadius(12)
                } else {
                    VStack(spacing: 12) {
                        Image(systemName: documentIcon)
                            .font(.system(size: 48))
                            .foregroundColor(documentColor.opacity(0.7))
                        
                        Text(fileExtension.uppercased())
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.secondary)
                    }
                }
                
                // Document Type Badge (overlay)
                VStack {
                    HStack {
                        DocumentTypeBadge(type: document.documentType)
                            .padding(8)
                        Spacer()
                    }
                    Spacer()
                }
            }
            
            // Document Info
            VStack(alignment: .leading, spacing: 8) {
                Text(document.fileName)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .lineLimit(2)
                    .foregroundColor(.primary)
                
                HStack(spacing: 4) {
                    Image(systemName: "calendar")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    
                    Text(document.documentDate, style: .date)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Text(formattedFileSize)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            .padding(12)
        }
        .frame(width: 160)
        .background(Color(UIColor.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
        .onAppear {
            loadThumbnail()
        }
    }
    
    private var fileExtension: String {
        document.fileURL.pathExtension.lowercased()
    }
    
    private var documentIcon: String {
        switch fileExtension {
        case "pdf":
            return "doc.fill"
        case "jpg", "jpeg", "png", "heic":
            return "photo.fill"
        default:
            return "doc.text.fill"
        }
    }
    
    private var documentColor: Color {
        switch document.documentType.lowercased() {
        case "prescription":
            return .blue
        case "lab result", "blood work":
            return .red
        case "diagnosis":
            return .purple
        case "notes":
            return .orange
        case "imaging", "x-ray", "scan":
            return .green
        default:
            return .gray
        }
    }
    
    private var formattedFileSize: String {
        let formatter = ByteCountFormatter()
        formatter.countStyle = .file
        return formatter.string(fromByteCount: document.fileSize)
    }
    
    private func loadThumbnail() {
        Task {
            if fileExtension == "pdf" {
                thumbnailImage = await generatePDFThumbnail()
            } else if ["jpg", "jpeg", "png", "heic"].contains(fileExtension) {
                thumbnailImage = await loadImageThumbnail()
            }
        }
    }
    
    private func generatePDFThumbnail() async -> UIImage? {
        guard let pdfDocument = PDFDocument(url: document.fileURL),
              let page = pdfDocument.page(at: 0) else { return nil }
        
        let pageRect = page.bounds(for: .mediaBox)
        let renderer = UIGraphicsImageRenderer(size: pageRect.size)
        
        return renderer.image { ctx in
            UIColor.white.set()
            ctx.fill(pageRect)
            ctx.cgContext.translateBy(x: 0.0, y: pageRect.size.height)
            ctx.cgContext.scaleBy(x: 1.0, y: -1.0)
            page.draw(with: .mediaBox, to: ctx.cgContext)
        }
    }
    
    private func loadImageThumbnail() async -> UIImage? {
        guard let data = try? Data(contentsOf: document.fileURL),
              let image = UIImage(data: data) else { return nil }
        
        let size = CGSize(width: 160, height: 200)
        return await image.byPreparingThumbnail(ofSize: size)
    }
}

// Document Type Badge
struct DocumentTypeBadge: View {
    let type: String
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: typeIcon)
                .font(.caption2)
            
            Text(displayName)
                .font(.caption2)
                .fontWeight(.semibold)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(backgroundColor.opacity(0.9))
        .foregroundColor(.white)
        .cornerRadius(8)
    }
    
    private var displayName: String {
        switch type.lowercased() {
        case "prescription":
            return "Rx"
        case "lab result", "blood work":
            return "Lab"
        case "diagnosis":
            return "Diagnosis"
        case "notes":
            return "Notes"
        case "imaging", "x-ray", "scan":
            return "Imaging"
        default:
            return type.capitalized
        }
    }
    
    private var typeIcon: String {
        switch type.lowercased() {
        case "prescription":
            return "pills.fill"
        case "lab result", "blood work":
            return "flask.fill"
        case "diagnosis":
            return "stethoscope"
        case "notes":
            return "note.text"
        case "imaging", "x-ray", "scan":
            return "camera.fill"
        default:
            return "doc.fill"
        }
    }
    
    private var backgroundColor: Color {
        switch type.lowercased() {
        case "prescription":
            return .blue
        case "lab result", "blood work":
            return .red
        case "diagnosis":
            return .purple
        case "notes":
            return .orange
        case "imaging", "x-ray", "scan":
            return .green
        default:
            return .gray
        }
    }
}

// Empty State View
struct EmptyDocumentsView: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "doc.badge.plus")
                .font(.system(size: 48))
                .foregroundColor(.gray.opacity(0.5))
            
            Text("No documents uploaded")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Text("Add prescriptions, lab results, and other medical documents")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
        .background(Color.gray.opacity(0.05))
        .cornerRadius(16)
    }
}

// Document Detail View (Modal)
struct DocumentDetailView: View {
    let document: DocumentData
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack {
                // Document viewer would go here
                // For now, showing a placeholder
                if document.fileURL.pathExtension.lowercased() == "pdf" {
                    PDFKitView(url: document.fileURL)
                } else {
                    AsyncImage(url: document.fileURL) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    } placeholder: {
                        ProgressView()
                    }
                }
            }
            .navigationTitle(document.fileName)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    ShareLink(item: document.fileURL) {
                        Image(systemName: "square.and.arrow.up")
                    }
                }
            }
        }
    }
}

// Simple PDFKit View
struct PDFKitView: UIViewRepresentable {
    let url: URL
    
    func makeUIView(context: Context) -> PDFView {
        let pdfView = PDFView()
        pdfView.document = PDFDocument(url: url)
        pdfView.autoScales = true
        return pdfView
    }
    
    func updateUIView(_ uiView: PDFView, context: Context) {}
}

// Preview
struct MedicalCaseDocumentsSection_Previews: PreviewProvider {
    static var previews: some View {
        let sampleDocuments = [
            DocumentData(
                id: UUID(),
                fileName: "Blood_Test_Results_2024.pdf",
                fileURL: URL(string: "file://")!,
                documentType: "Lab Result",
                documentDate: Date().addingTimeInterval(-86400 * 7),
                uploadDate: Date().addingTimeInterval(-86400 * 2),
                fileSize: 245760
            ),
            DocumentData(
                id: UUID(),
                fileName: "Prescription_Cardiology.pdf",
                fileURL: URL(string: "file://")!,
                documentType: "Prescription",
                documentDate: Date().addingTimeInterval(-86400 * 3),
                uploadDate: Date().addingTimeInterval(-86400 * 1),
                fileSize: 123456
            ),
            DocumentData(
                id: UUID(),
                fileName: "Chest_XRay_Report.jpg",
                fileURL: URL(string: "file://")!,
                documentType: "Imaging",
                documentDate: Date().addingTimeInterval(-86400 * 14),
                uploadDate: Date().addingTimeInterval(-86400 * 10),
                fileSize: 2097152
            )
        ]
        
        ScrollView {
            VStack(spacing: 24) {
                MedicalCaseDocumentsSection(documents: sampleDocuments)
                MedicalCaseDocumentsSection(documents: [])
            }
        }
        .background(Color(UIColor.systemGroupedBackground))
    }
}
