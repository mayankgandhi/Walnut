//
//  DocumentTypeSelector.swift
//  Walnut
//
//  Created by Mayank Gandhi on 29/07/25.
//  Copyright © 2025 m. All rights reserved.
//

import SwiftUI

struct DocumentTypeSelector: View {
    
    @Environment(DocumentPickerStore.self) private var store
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Document Type")
                .font(.headline)
                .foregroundColor(.primary)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(store.availableDocumentTypes, id: \.self) { type in
                        DocumentTypeButton(
                            type: type,
                            isSelected: store.selectedDocumentType == type
                        ) {
                            store.selectDocumentType(type)
                        }
                    }
                }
                .padding(.horizontal, 4) // Small padding for scroll content
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
