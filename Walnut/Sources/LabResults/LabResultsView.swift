//
//  LabResultsView.swift
//  Walnut
//
//  Created by Mayank Gandhi on 07/06/25.
//  Copyright © 2025 m. All rights reserved.
//

import SwiftUI
import ComposableArchitecture

// MARK: - Lab Results View
struct LabResultsView: View {
    @Bindable var store: StoreOf<LabResultsFeature>
    
    var body: some View {
        FormSection(title: "Recent Lab Results", icon: "testtube.2") {
            VStack(spacing: 12) {
                HStack {
                    Text("Latest Results")
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
                        .frame(height: 60)
                } else if store.recentLabResults.isEmpty {
                    Text("No recent lab results")
                        .font(.subheadline)
                        .foregroundColor(.textTertiary)
                        .frame(height: 60)
                } else {
                    ForEach(store.recentLabResults.prefix(3), id: \.id) { result in
                        LabResultRow(result: result) {
                            store.send(.resultTapped(result))
                        }
                    }
                }
            }
        }
        .onAppear {
            store.send(.loadRecentResults)
        }
    }
}
