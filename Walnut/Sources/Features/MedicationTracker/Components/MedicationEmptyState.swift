//
//  MedicationEmptyState.swift
//  Walnut
//
//  Created by Mayank Gandhi on 10/09/25.
//  Copyright © 2025 m. All rights reserved.
//

import SwiftUI
import WalnutDesignSystem

/// Empty state view for when no medications are scheduled
struct MedicationEmptyState: View {
    // MARK: - Body

    var body: some View {
        VStack(spacing: Spacing.large) {
            ContentUnavailableView {
                Label("Start Tracking Medications", systemImage: "pills")
            } description: {
                Text("Keep track of your daily medications and supplements. Add them to get started with your health journal.")
            } actions: {

            }
            .padding(Spacing.large)
        }
    }
}

// MARK: - Preview

#Preview {
    MedicationEmptyState()
}
