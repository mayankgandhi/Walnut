//
//  UnparsedDocumentsSection.swift
//  Walnut
//
//  Created by Mayank Gandhi on 01/08/25.
//  Copyright © 2025 m. All rights reserved.
//

import SwiftUI

// MARK: - Unparsed Documents Section
struct UnparsedDocumentsSection: View {
    
    let medicalCase: MedicalCase
    @State private var selectedDocument: Document?
    @State private var isRetrying = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Section Header
            UnparsedDocumentsSectionHeader(
                documentCount: medicalCase.unparsedDocuments.count
            )
            
            // List
            LazyVStack(spacing: 12) {
                ForEach(medicalCase.unparsedDocuments) { document in
                    UnparsedDocumentListItem(
                        document: document,
                        isRetrying: isRetrying,
                        onRetry: { }
                    )
                }
            }
        }
        .padding(.horizontal, 16)
    }

}

// MARK: - Unparsed Documents Section Header
struct UnparsedDocumentsSectionHeader: View {
    let documentCount: Int
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 8) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.title2)
                        .foregroundColor(.orange)

                    Text("Failed Documents")
                        .font(.title2)
                        .fontWeight(.bold)
                }
                
                Text("\(documentCount) documents failed to parse")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
    }
}

// MARK: - Unparsed Document List Item
struct UnparsedDocumentListItem: View {
    let document: Document
    let isRetrying: Bool
    let onRetry: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header with filename and date
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(document.fileName)
                        .font(.headline)
                        .foregroundColor(.primary)
                        .lineLimit(2)
                    
                    Text(document.uploadDate, style: .date)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Status indicator
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(.orange)
                    .font(.title2)
            }
            
            // File info and retry button
            HStack {
                HStack(spacing: 4) {
                    Image(systemName: "doc")
                        .foregroundColor(.gray)
                        .font(.caption)
                    
                    Text(ByteCountFormatter.string(fromByteCount: document.fileSize, countStyle: .file))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Button(action: onRetry) {
                    HStack(spacing: 4) {
                        if isRetrying {
                            ProgressView()
                                .controlSize(.mini)
                        } else {
                            Image(systemName: "arrow.clockwise")
                                .font(.caption)
                        }
                        
                        Text("Retry")
                            .font(.caption)
                    }
                    .foregroundColor(.blue)
                }
                .disabled(isRetrying)
            }
        }
        .padding(16)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
        .contentShape(Rectangle())
    }
}
