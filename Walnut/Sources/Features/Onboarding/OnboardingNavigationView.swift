//
//  OnboardingNavigationView.swift
//  Walnut
//
//  Created by Mayank Gandhi on 11/09/25.
//  Copyright © 2025 m. All rights reserved.
//

import SwiftUI
import WalnutDesignSystem

// MARK: - Navigation Controls
struct OnboardingNavigationView: View {

    @Bindable var viewModel: OnboardingViewModel
    @Environment(\.modelContext) var modelContext

    var body: some View {
        HStack(spacing: Spacing.medium) {
            // Back button
            if viewModel.currentScreenIndex > 0 {
                DSButton(
                    "Back",
                    style: .secondary,
                    icon: "chevron.left"
                ) {
                    viewModel.previousScreen()
                }
                .frame(maxWidth: .infinity, maxHeight: 44)
            }
            // Next/Complete button
            DSButton(
                viewModel.isLastScreen ? "Complete" : "Continue",
                style: .primary,
                icon: viewModel.isLastScreen ? "checkmark" : "chevron.right"
            ) {
                Task {
                    try? await viewModel.nextScreen(modelContext: modelContext)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: 44)
            .disabled(!viewModel.canProceedToNext || viewModel.isLoading)
            .opacity(viewModel.canProceedToNext ? 1.0 : 0.6)
        }
    }
}
