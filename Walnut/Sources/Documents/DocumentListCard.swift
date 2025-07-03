//
//  DocumentListCard.swift
//  Walnut-Playground
//
//  Created by Mayank Gandhi on 02/07/25.
//  Copyright © 2025 m. All rights reserved.
//

import SwiftUI
import PDFKit

// MARK: - Document List Card
struct DocumentListCard: View {
    let document: DocumentData
    @State private var thumbnailImage: UIImage?
    
    var body: some View {
        HStack(spacing: 16) {
            // Document Thumbnail
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(document.documentType.backgroundColor.opacity(0.1))
                    .frame(width: 60, height: 75)
                
                if let thumbnailImage = thumbnailImage {
                    Image(uiImage: thumbnailImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 60, height: 75)
                        .clipped()
                        .cornerRadius(12)
                } else {
                    VStack(spacing: 4) {
                        Image(systemName: documentIcon)
                            .font(.system(size: 22))
                            .foregroundColor(document.documentType.color)
                        
                        Text(fileExtension.uppercased())
                            .font(.caption2)
                            .fontWeight(.bold)
                            .foregroundColor(document.documentType.color)
                    }
                }
                
                // Document type badge overlay
                VStack {
                    HStack {
                        Spacer()
                        DocumentTypeBadge(documentType: document.documentType)
                            .scaleEffect(0.85)
                            .padding(4)
                    }
                    Spacer()
                }
            }
            
            // Document Information
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(document.fileName)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .lineLimit(2)
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.accentColor)
                }
                
                HStack(spacing: 16) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Date")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        
                        Text(document.documentDate, style: .date)
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.primary)
                    }
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Size")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        
                        Text(formattedFileSize)
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.primary)
                    }
                    
                    Spacer()
                }
                
                HStack(spacing: 4) {
                    Image(systemName: "clock")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    
                    Text("Added \(RelativeDateTimeFormatter().localizedString(for: document.uploadDate, relativeTo: Date()))")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
        }
        .padding(16)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 2)
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
        case "doc", "docx":
            return "doc.text.fill"
        case "xls", "xlsx":
            return "tablecells.fill"
        default:
            return "doc.text.fill"
        }
    }
    
    private var formattedFileSize: String {
        let formatter = ByteCountFormatter()
        formatter.countStyle = .file
        formatter.allowedUnits = [.useKB, .useMB]
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
        let size = CGSize(width: 60, height: 75)
        let renderer = UIGraphicsImageRenderer(size: size)
        
        return renderer.image { ctx in
            UIColor.white.set()
            ctx.fill(CGRect(origin: .zero, size: size))
            
            let aspectRatio = pageRect.width / pageRect.height
            let drawSize = aspectRatio > (size.width / size.height)
            ? CGSize(width: size.width, height: size.width / aspectRatio)
            : CGSize(width: size.height * aspectRatio, height: size.height)
            
            let drawRect = CGRect(
                x: (size.width - drawSize.width) / 2,
                y: (size.height - drawSize.height) / 2,
                width: drawSize.width,
                height: drawSize.height
            )
            
            ctx.cgContext.translateBy(x: drawRect.minX, y: drawRect.maxY)
            ctx.cgContext.scaleBy(x: drawSize.width / pageRect.width, y: -drawSize.height / pageRect.height)
            page.draw(with: .mediaBox, to: ctx.cgContext)
        }
    }
    
    private func loadImageThumbnail() async -> UIImage? {
        guard let data = try? Data(contentsOf: document.fileURL),
              let image = UIImage(data: data) else { return nil }
        
        let size = CGSize(width: 60, height: 75)
        return await image.byPreparingThumbnail(ofSize: size)
    }
}
