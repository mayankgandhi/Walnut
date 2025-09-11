//
//  OnboardingIntegrationExample.swift
//  Walnut
//
//  Created by Claude on 11/09/25.
//  Copyright © 2025 m. All rights reserved.
//

import SwiftUI
import SwiftData

/// Example of how to integrate the onboarding flow into your app
struct OnboardingIntegrationExample: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @State private var showingOnboarding = false
    
    var body: some View {
        Group {
            if hasCompletedOnboarding {
                MainAppView()
            } else {
                OnboardingContainerView {
                    hasCompletedOnboarding = true
                }
            }
        }
        .onAppear {
            // Check if onboarding was completed previously
            if !hasCompletedOnboarding {
                showingOnboarding = true
            }
        }
    }
}

/// Placeholder for your main app view
private struct MainAppView: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("Welcome to HealthStack!")
                    .font(.largeTitle.bold())
                
                Text("Onboarding completed successfully!")
                    .font(.headline)
                    .foregroundStyle(.secondary)
                
                Button("Reset Onboarding") {
                    UserDefaults.standard.set(false, forKey: "hasCompletedOnboarding")
                }
                .buttonStyle(.bordered)
            }
            .navigationTitle("HealthStack")
        }
    }
}

// MARK: - Preview
#Preview {
    OnboardingIntegrationExample()
        .modelContainer(for: Patient.self, inMemory: true)
}
