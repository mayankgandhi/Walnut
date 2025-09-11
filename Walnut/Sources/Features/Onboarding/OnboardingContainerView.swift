//
//  OnboardingContainerView.swift
//  Walnut
//
//  Created by Claude on 11/09/25.
//  Copyright © 2025 m. All rights reserved.
//

import SwiftUI
import SwiftData
import WalnutDesignSystem

/// Main onboarding container managing the flow between screens
struct OnboardingContainerView: View {

    @Environment(\.modelContext) private var modelContext
    @State private var viewModel = OnboardingViewModel()
    
    var onOnboardingComplete: () -> Void
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .center, spacing: .zero) {
                // Progress indicator
                ProgressIndicatorView(progress: viewModel.progressPercentage)
                    .padding(.vertical, Spacing.large)
                    .padding(.horizontal, Spacing.medium)
                
                // Main content with page navigation
                TabView(selection: $viewModel.currentScreenIndex) {
                    WelcomeScreen(viewModel: viewModel)
                        .tag(OnboardingScreen.welcome.rawValue)
                    
                    HealthProfileScreen(viewModel: viewModel)
                        .tag(OnboardingScreen.healthProfile.rawValue)
                    
                    PermissionsScreen(viewModel: viewModel)
                        .tag(OnboardingScreen.permissions.rawValue)
                    
                    PatientSetupScreen(viewModel: viewModel)
                        .tag(OnboardingScreen.patientSetup.rawValue)
                    
                    VitalsIntroductionScreen(viewModel: viewModel)
                        .tag(OnboardingScreen.vitalsIntroduction.rawValue)
                    
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.spring(duration: 0.1), value: viewModel.currentScreenIndex)
                
                // Navigation controls
                OnboardingNavigationView(viewModel: viewModel)
                    .padding(.vertical, Spacing.large)
                    .padding(.horizontal, Spacing.medium)
            }
            .background(
                Color(hex: "#B8D4F0")
                    .edgesIgnoringSafeArea(.all)
            )
            .environment(viewModel)
            .navigationBarHidden(true)
            .onReceive(NotificationCenter.default.publisher(for: .onboardingCompleted)) { _ in
                onOnboardingComplete()
            }
        }
    }
}


// MARK: - Preview
#Preview {
    OnboardingContainerView {
        print("Onboarding completed")
    }
    .modelContainer(for: Patient.self, inMemory: true)
}
