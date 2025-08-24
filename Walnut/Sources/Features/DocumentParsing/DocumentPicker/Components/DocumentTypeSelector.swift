//
//  DocumentTypeSelector.swift
//  Walnut
//
//  Created by Mayank Gandhi on 29/07/25.
//  Copyright © 2025 m. All rights reserved.
//

import SwiftUI
import WalnutDesignSystem

struct DocumentTypeSelector: View {
    
    @Environment(DocumentPickerStore.self) private var store
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            
            Text("Select a document Type")
                .font(.headline)
                .foregroundColor(.primary)
            
            LazyVGrid(
                columns: [
                    .init(
                        .flexible(minimum: 20, maximum: .infinity),
                        spacing: Spacing.medium,
                        alignment: .leading
                    ),
                    .init(
                        .flexible(minimum: 20, maximum: .infinity),
                        spacing: Spacing.medium,
                        alignment: .leading
                    )
                ],
                alignment: .leading,
                spacing: Spacing.medium
            ) {
                ForEach(store.availableDocumentTypes, id: \.self) { type in
                    Button {
                        store.selectDocumentType(type)
                    } label: {
                        DocumentTypeButton(
                            type: type,
                            isSelected: store.selectedDocumentType == type
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
    
}

// MARK: - Preview

#Preview("Multiple Types") {
    @Previewable
    @State var store = DocumentPickerStore.forAllDocuments()
    
    VStack {
        DocumentTypeSelector()
            .environment(store)
            .padding()
        
        Spacer()
    }
}

#Preview("Single Type") {
    @Previewable
    @State var store = DocumentPickerStore.forAllDocuments()
    
    VStack {
        DocumentTypeSelector()
            .environment(store)
            .padding()
        
        Spacer()
    }
}
