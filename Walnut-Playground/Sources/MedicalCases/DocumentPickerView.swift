//
//  DocumentPickerView.swift
//  Walnut-Playground
//
//  Created by Mayank Gandhi on 02/07/25.
//  Copyright © 2025 m. All rights reserved.
//

import SwiftUI
import PDFKit

// Document Picker View
struct DocumentPickerView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedDocumentType: DocumentType = .billing
    
    let documentTypes = DocumentType.allCases
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                // Document Type Selector
                VStack(alignment: .leading, spacing: 12) {
                    Text("Document Type")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(documentTypes, id: \.self) { type in
                                DocumentTypeButton(
                                    type: type,
                                    isSelected: selectedDocumentType == type
                                ) {
                                    selectedDocumentType = type
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal)
                
                // Upload Area
                VStack(spacing: 16) {
                    Image(systemName: "doc.badge.arrow.up.fill")
                        .font(.system(size: 56))
                        .foregroundColor(.blue)
                    
                    Text("Tap to select a document")
                        .font(.headline)
                    
                    Text("Supports PDF, JPG, PNG, and HEIC files")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 200)
                .background(Color.blue.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .strokeBorder(style: StrokeStyle(lineWidth: 2, dash: [10]))
                        .foregroundColor(.blue.opacity(0.3))
                )
                .cornerRadius(16)
                .padding(.horizontal)
                .onTapGesture {
                    // Present document picker
                }
                
                Spacer()
            }
            .navigationTitle("Add Document")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}
