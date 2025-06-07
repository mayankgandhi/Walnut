//
//  MedicalRecordsListView.swift
//  Walnut
//
//  Created by Mayank Gandhi on 07/06/25.
//  Copyright © 2025 m. All rights reserved.
//

import ComposableArchitecture
import SwiftUI

// MARK: - Medical Records List View
struct MedicalRecordsListView: View {
    @Bindable var store: StoreOf<MedicalRecordsListFeature>
    
    var body: some View {
        FormSection(title: "Medical Records", icon: "doc.text") {
            VStack(spacing: 12) {
                HStack {
                    Text("Recent Records")
                        .font(.subheadline)
                        .foregroundColor(.textSecondary)
                    
                    Spacer()
                    
                    Button("View All") {
                        store.send(.viewAllTapped)
                    }
                    .font(.caption)
                    .foregroundColor(.healthBlue)
                }
                
                if store.isLoading {
                    ProgressView()
                        .frame(height: 80)
                } else if store.medicalRecords.isEmpty {
                    Text("No medical records found")
                        .font(.subheadline)
                        .foregroundColor(.textTertiary)
                        .frame(height: 80)
                } else {
                    ForEach(store.medicalRecords.prefix(4), id: \.id) { record in
                        MedicalRecordRow(record: record) {
                            store.send(.recordTapped(record))
                        }
                    }
                }
            }
        }
        .onAppear {
            store.send(.loadRecords)
        }
    }
}
