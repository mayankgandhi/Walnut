//
//  DocumentProcessingStatusView.swift
//  Walnut
//
//  Created by Mayank Gandhi on 23/08/25.
//  Copyright © 2025 m. All rights reserved.
//

import SwiftUI
import WalnutDesignSystem

// MARK: - Processing Status View

struct DocumentProcessingStatusView: View {
    
    @Binding var isProcessing: Bool
    @Binding var processingProgress: Double
    @Binding var processingStatus: String
    @Binding var lastError: Error?

    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 24) {
            
            // Progress indicator
            
            
            if isProcessing {
                VStack(spacing: 12) {
                    Image(systemName: "square.and.arrow.up.fill")
                        .symbolEffect(.pulse)
                        .symbolRenderingMode(.hierarchical)
                        .font(.largeTitle)
                        .foregroundColor(.blue)
                    
                    Text("Uploading document...")
                        .font(.headline)
                }
            } else {
                VStack(spacing: 12) {
                    Image(systemName: "document.viewfinder.fill")
                        .symbolEffect(.breathe)
                        .font(.largeTitle)
                        .foregroundColor(.green)
                    
                    Text("Parsing document...")
                        .font(.headline)
                }
            }
            
            ProgressView(value: processingProgress)
                .progressViewStyle(LinearProgressViewStyle())
                .frame(maxWidth: 200)
            
            Spacer()
            
            // Error handling
            if let error = lastError {
                VStack(spacing: 12) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.largeTitle)
                        .foregroundColor(.red)
                        .contentTransition(.symbolEffect(.replace))
                    
                    Text("Processing Failed")
                        .font(.headline)
                    
                    Text(error.localizedDescription)
                        .font(.subheadline)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.secondary)
                    
                    Button("Dismiss") {
                        dismiss()
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding()
            } else if processingProgress >= 1.0 && !isProcessing {
                VStack(spacing: 12) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.largeTitle)
                        .foregroundColor(.green)
                        .contentTransition(.symbolEffect(.replace))
                    
                    Text("Document Processed Successfully")
                        .font(.headline)
                    
                    Button("Done") {
                        dismiss()
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding()
            }
        }
    }
}

#Preview {
    DocumentProcessingStatusView(
        isProcessing: .constant(true),
        processingProgress: .constant(0.5),
        processingStatus: .constant("Loading"),
        lastError: .constant(nil)
    )
}
