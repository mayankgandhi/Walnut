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
        ScrollView {
            VStack(spacing: Spacing.xl) {
                Spacer()
                    .frame(height: Spacing.large)
                
                // App icon and branding
                VStack(spacing: Spacing.large) {
                    Image(systemName: "heart.text.square.fill")
                        .font(.system(size: 80))
                        .foregroundStyle(Color.healthPrimary)
                        .shadow(color: Color.healthPrimary.opacity(0.3), radius: 10, x: 0, y: 4)
                    
                    VStack(spacing: Spacing.small) {
                        Text("Welcome to")
                            .font(.title2)
                            .foregroundStyle(.secondary)
                        
                        Text("HealthStack")
                            .font(.largeTitle.bold())
                            .foregroundStyle(.primary)
                    }
                }
                
                // Value proposition
                VStack(spacing: Spacing.large) {
                    Text("Your comprehensive health management companion")
                        .font(.title3)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, Spacing.medium)
                    
                    // Feature highlights
                    VStack(spacing: Spacing.medium) {
                        FeatureHighlight(
                            icon: "doc.text.fill",
                            title: "Medical Records",
                            description: "Keep all your health documents organized"
                        )
                        
                        FeatureHighlight(
                            icon: "pills.fill",
                            title: "Medication Tracking",
                            description: "Never miss a dose with smart reminders"
                        )
                        
                        FeatureHighlight(
                            icon: "chart.line.uptrend.xyaxis",
                            title: "Health Analytics",
                            description: "Track your progress and vital signs"
                        )
                        
                        FeatureHighlight(
                            icon: "person.2.fill",
                            title: "Care Team Access",
                            description: "Share information with your healthcare providers"
                        )
                    }
                    .padding(.horizontal, Spacing.medium)
                }
                
                Spacer()
            }
        }
        .padding(.horizontal, Spacing.large)
    }
}

// MARK: - Feature Highlight Component
private struct FeatureHighlight: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: Spacing.medium) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(Color.healthPrimary)
                .frame(width: 30, alignment: .center)
            
            VStack(alignment: .leading, spacing: Spacing.xs) {
                Text(title)
                    .font(.headline)
                    .foregroundStyle(.primary)
                
                Text(description)
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.leading)
            }
            
            Spacer()
        }
        .padding(.vertical, Spacing.small)
    }
}

// MARK: - Preview
#Preview {
    NavigationStack {
        WelcomeScreen(viewModel: OnboardingViewModel())
    }
}
