//
//  DocumentData.swift
//  Walnut-Playground
//
//  Created by Mayank Gandhi on 02/07/25.
//  Copyright © 2025 m. All rights reserved.
//

import SwiftUI
import PDFKit
import SwiftUI
import PDFKit

// MARK: - Documents Section
struct DocumentsSection: View {
    let documents: [DocumentData]
    @State private var selectedDocument: DocumentData?
    @State private var searchText = ""
    
    private var filteredDocuments: [DocumentData] {
        if searchText.isEmpty {
            return documents
        } else {
            return documents.filter {
                $0.fileName.localizedCaseInsensitiveContains(searchText) ||
                $0.documentType.displayName.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Section Header
            DocumentsSectionHeader(
                documentCount: documents.count
            )
            
            // Documents Content
            if filteredDocuments.isEmpty {
                if documents.isEmpty {
                    ContentUnavailableView(
                        "No Documents",
                        systemImage: "doc.badge.plus",
                        description: Text("Add medical documents, prescriptions, and lab results")
                    )
                } else {
                    ContentUnavailableView(
                        "No documents found",
                        systemImage: "magnifyingglass",
                        description: Text("Try adjusting your search terms")
                    )
                }
            } else {
                LazyVStack(spacing: 12) {
                    ForEach(filteredDocuments) { document in
                        DocumentListCard(document: document)
                            .onTapGesture {
                                selectedDocument = document
                            }
                    }
                }
            }
        }
        .padding(.horizontal, 16)
        .sheet(item: $selectedDocument) { document in
            DocumentDetailView(document: document)
        }
    }
}



// MARK: - Section Header
struct DocumentsSectionHeader: View {
    let documentCount: Int
    
    @State private var showAddDocument = false
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 8) {
                    Image(systemName: "doc.text.fill")
                        .font(.title2)
                        .foregroundColor(.blue)

                    Text("Documents")
                        .font(.title2)
                        .fontWeight(.bold)
                }
                
                Text("\(documentCount) documents")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Menu {
                Button {
                    showAddDocument = true
                } label: {
                    Label("Add Document", systemImage: "doc.badge.plus")
                }
                
                Button {
                    // Add lab result
                } label: {
                    Label("Add Lab Result", systemImage: "flask")
                }
            } label: {
                Label("Add", systemImage: "plus")
            }
            
        }
        .sheet(isPresented: $showAddDocument) {
            DocumentPickerView()
        }
    }
}








// MARK: - Preview
struct DocumentsSection_Previews: PreviewProvider {
    static var previews: some View {
        ScrollView {
            VStack(spacing: 24) {
                DocumentsSection(documents: DocumentData.documents)
                DocumentsSection(documents: [])
            }
            .padding(.vertical)
        }
        .background(Color(.systemGroupedBackground))
    }
}
