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
            Image(systemName: "doc.fill")
                .font(.title2)
                .foregroundColor(.red)
            
            Text("Document")
                .font(.headline)
                .fontWeight(.semibold)
            
            Spacer()
            
            Button("View") {
                onViewDocument()
            }
            .font(.subheadline)
            .fontWeight(.medium)
            .foregroundColor(.red)
        }
    }
    
    private var documentInfo: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(document.fileName)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .lineLimit(2)
                
                Text("PDF Document • \(document.fileSize) KB")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Image(systemName: "arrow.up.right.square")
                .font(.title2)
                .foregroundColor(.red)
        }
    }
}

#Preview {
    PrescriptionDocumentCard(prescription: Prescription.samplePrescription)
        .padding()
        .background(Color(.systemGroupedBackground))
}