//
//  DocumentParsingStatusView.swift
//  Walnut
//
//  Created by Mayank Gandhi on 08/07/25.
//  Copyright © 2025 m. All rights reserved.
//

import SwiftUI

struct DocumentParsingStatusView: View {
        
    @StateObject var viewModel: DocumentParsingViewModel
    var coordinator: DocumentParsingViewCoordinator = DocumentParsingViewCoordinator.shared
    
    var body: some View {
        if !viewModel.showAccessory {
            Text("Accessory")
        } else {
            HStack(spacing: 8) {
                statusText
                Spacer()
                statusIcon
            }
            .animation(.easeInOut(duration: 0.3), value: currentState)
            .padding()
        }
    }
    
    private var currentState: DocumentParsingViewModel.DocumentParsingState {
        if viewModel.isProcessing {
            return .processing
        } else if viewModel.parsedDocument != nil {
            return .success
        } else {
            return .idle
        }
    }
    
    @ViewBuilder
    private var statusIcon: some View {
        switch currentState {
        case .idle:
            Image(systemName: "doc.text")
                .foregroundStyle(.secondary)
        case .processing:
            Image(systemName: "doc.text")
                .foregroundStyle(.blue)
                .symbolEffect(.pulse, isActive: true)
        case .success:
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(.green)
                .symbolEffect(.bounce, isActive: true)
        }
    }
    
    @ViewBuilder
    private var statusText: some View {
        switch currentState {
        case .idle:
            Text("Ready to Parse")
                .foregroundStyle(.secondary)
        case .processing:
            Text("Processing...")
                .foregroundStyle(.blue)
        case .success:
            Text("Document Parsed")
                .foregroundStyle(.green)
        }
    }
}

