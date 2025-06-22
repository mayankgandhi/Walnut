//
//  EditMedicalCaseView.swift
//  Walnut
//
//  Created by Mayank Gandhi on 22/06/25.
//  Copyright © 2025 m. All rights reserved.
//

import ComposableArchitecture
import SwiftUI

// MARK: - Edit Medical Case View
struct EditMedicalCaseView: View {
    @Bindable var store: StoreOf<EditMedicalCaseFeature>
    @Environment(\.dismiss) private var dismiss
    @FocusState private var focusedField: Field?
    
    enum Field {
        case title, notes, treatmentPlan
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    TextField("Case Title", text: $store.title)
                        .focused($focusedField, equals: .title)
                } header: {
                    Text("Basic Information")
                } footer: {
                    if let error = store.validationError {
                        Text(error)
                            .foregroundColor(.red)
                    }
                }
                
                Section("Description") {
                    TextField("Notes (optional)", text: $store.notes, axis: .vertical)
                        .lineLimit(3...6)
                        .focused($focusedField, equals: .notes)
                }
                
                Section("Treatment") {
                    TextField("Treatment Plan (optional)", text: $store.treatmentPlan, axis: .vertical)
                        .lineLimit(3...6)
                        .focused($focusedField, equals: .treatmentPlan)
                    
                    Toggle("Follow-up Required", isOn: $store.followUpRequired)
                }
            }
            .navigationTitle("Edit Case")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        store.send(.saveChanges)
                    }
                    .disabled(!store.isValid || store.isLoading || !store.hasChanges)
                }
            }
        }
        .disabled(store.isLoading)
        
    }
}
