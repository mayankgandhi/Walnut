//
//  HealthRecordSelectorBottomSheet.swift
//  Walnut
//
//  Created by Mayank Gandhi on 01/09/25.
//  Copyright © 2025 m. All rights reserved.
//

import SwiftUI
import WalnutDesignSystem

struct HealthRecordSelectorBottomSheet: View {
    
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    let medicalCase: MedicalCase
    @State var store: DocumentPickerStore
    @Binding var showModularDocumentPicker: Bool
    
    var body: some View {
        NavigationStack {
            ScrollView {
                DocumentTypeSelector(store: store)
            }
            .toolbar(content: {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                    }
                }
            })
            .toolbar(content: {
                if store.selectedDocumentType != nil {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            dismiss()
                            showModularDocumentPicker  = true
                        } label: {
                            Label("Next", systemImage: "checkmark")
                        }
                        
                    }
                }
            })
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.hidden) // We provide our own
            .presentationCornerRadius(Spacing.large)
            .interactiveDismissDisabled(false)
        }
    }
}
