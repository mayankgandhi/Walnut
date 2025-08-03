//
//  PrescriptionDocumentCard.swift
//  Walnut
//
//  Created by Mayank Gandhi on 03/08/25.
//  Copyright © 2025 m. All rights reserved.
//

import SwiftUI

struct PrescriptionDocumentCard: View {
    let document: Document
    let onViewDocument: () -> Void
    
    init?(prescription: Prescription, onViewDocument: @escaping () -> Void = {}) {
        guard let document = prescription.document else {
            return nil
        }
        self.document = document
        self.onViewDocument = onViewDocument
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            header
            documentInfo
        }
        .padding(20)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
    
    private var header: some View {
        HStack {
            Image(systemName: documentIcon)
                .font(.title2)
                .foregroundColor(documentColor)
            
            Text("Document")
                .font(.headline)
                .fontWeight(.semibold)
            
            Spacer()
            
            Button("View") {
                onViewDocument()
            }
            .font(.subheadline)
            .fontWeight(.medium)
            .foregroundColor(documentColor)
        }
    }
    
    private var documentIcon: String {
        let fileExtension = document.fileURL.pathExtension.lowercased()
        switch fileExtension {
        case "pdf":
            return "doc.fill"
        case "jpg", "jpeg", "png", "heic", "heif":
            return "photo.fill"
        default:
            return "doc.questionmark.fill"
        }
    }
    
    private var documentColor: Color {
        let fileExtension = document.fileURL.pathExtension.lowercased()
        switch fileExtension {
        case "pdf":
            return .red
        case "jpg", "jpeg", "png", "heic", "heif":
            return .blue
        default:
            return .gray
        }
    }
    
    private var documentInfo: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(document.fileName)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .lineLimit(2)
                
                Text("\(documentTypeDescription) • \(formatFileSize(document.fileSize))")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Image(systemName: "arrow.up.right.square")
                .font(.title2)
                .foregroundColor(documentColor)
        }
    }
    
    private var documentTypeDescription: String {
        let fileExtension = document.fileURL.pathExtension.lowercased()
        switch fileExtension {
        case "pdf":
            return "PDF Document"
        case "jpg", "jpeg":
            return "JPEG Image"
        case "png":
            return "PNG Image"
        case "heic":
            return "HEIC Image"
        case "heif":
            return "HEIF Image"
        default:
            return "\(fileExtension.uppercased()) Document"
        }
    }
    
    private func formatFileSize(_ bytes: Int64) -> String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useKB, .useMB]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: bytes)
    }
}

