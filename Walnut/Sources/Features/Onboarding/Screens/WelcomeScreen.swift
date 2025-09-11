//
//  WelcomeScreen.swift
//  Walnut
//
//  Created by Claude on 11/09/25.
//  Copyright © 2025 m. All rights reserved.
//

import SwiftUI
import WalnutDesignSystem

/// Welcome screen introducing the app's value proposition
struct WelcomeScreen: View {
    
    @Bindable var viewModel: OnboardingViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.medium) {
            Image("app-hero")
                .resizable()
                .scaledToFit()
            VStack(alignment: .leading, spacing: Spacing.small) {
                
                Text("Welcome to")
                    .font(.title2)
                    .foregroundStyle(.secondary)
                
                Text("HealthStack")
                    .font(.largeTitle.bold())
                    .foregroundStyle(.primary)
                
                Text("Your comprehensive health management companion")
                    .font(.title3)
                    .multilineTextAlignment(.leading)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
        }
        .padding(.horizontal, Spacing.medium)
        .frame(
            maxWidth: .infinity,
            maxHeight: .infinity,
            alignment: .center
        )
        
    }
}


// MARK: - Preview
#Preview {
    NavigationStack {
        WelcomeScreen(viewModel: OnboardingViewModel())
    }
}
