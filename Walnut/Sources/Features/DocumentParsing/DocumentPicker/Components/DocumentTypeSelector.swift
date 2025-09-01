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
    
    private var store: DocumentPickerStore
    
    init(store: DocumentPickerStore) {
        self.store = store
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.medium) {
            
            HealthCardHeader(title: "Select a Document Type")
            
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
        .padding(.horizontal, Spacing.medium)
    }
    
}

// MARK: - Preview

#Preview("Multiple Types") {
    DocumentTypeSelector(
        store: DocumentPickerStore.forAllDocuments()
    )
}
