//
//  DocumentDetailView.swift
//  Walnut-Playground
//
//  Created by Mayank Gandhi on 02/07/25.
//  Copyright © 2025 m. All rights reserved.
//

import SwiftUI

// MARK: - Document Detail View
struct DocumentDetailView: View {
    let document: Document
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Document Preview
                if document.fileURL.pathExtension.lowercased() == "pdf" {
                    PDFKitView(url: document.fileURL)
                } else {
                    AsyncImage(url: document.fileURL) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    } placeholder: {
                        ProgressView()
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
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
