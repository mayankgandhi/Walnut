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
            VStack(spacing: 0) {
                // Progress indicator
                ProgressIndicatorView(progress: viewModel.progressPercentage)
                    .padding(.horizontal, Spacing.large)
                    .padding(.top, Spacing.medium)
                
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
                    
                    CompletionScreen(viewModel: viewModel)
                        .tag(OnboardingScreen.completion.rawValue)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.easeInOut(duration: 0.3), value: viewModel.currentScreenIndex)
                
                // Navigation controls
                OnboardingNavigationView(viewModel: viewModel)
                    .padding(Spacing.large)
            }
            .environment(viewModel)
            .navigationBarHidden(true)
            .onReceive(NotificationCenter.default.publisher(for: .onboardingCompleted)) { _ in
                onOnboardingComplete()
            }
        }
    }
}

// MARK: - Progress Indicator
private struct ProgressIndicatorView: View {
    let progress: Double
    
    var body: some View {
        VStack(spacing: Spacing.small) {
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(.quaternary)
                        .frame(height: 4)
                        .clipShape(Capsule())
                    
                    Rectangle()
                        .fill(Color.healthPrimary)
                        .frame(width: geometry.size.width * progress, height: 4)
                        .clipShape(Capsule())
                        .animation(.easeInOut(duration: 0.3), value: progress)
                }
            }
            .frame(height: 4)
            
            HStack {
                Text("Step \(Int(progress * 6)) of 6")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                Spacer()
                
                Text("\(Int(progress * 100))% Complete")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

// MARK: - Navigation Controls
private struct OnboardingNavigationView: View {
     @Bindable var viewModel: OnboardingViewModel
    
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
            } else {
                Spacer()
            }
            
            // Next/Complete button
            DSButton(
                viewModel.isLastScreen ? "Complete Setup" : "Continue",
                style: .primary,
                icon: viewModel.isLastScreen ? "checkmark" : "chevron.right"
            ) {
                viewModel.nextScreen()
            }
            .frame(maxWidth: .infinity, maxHeight: 44)
            .disabled(!viewModel.canProceedToNext || viewModel.isLoading)
            .opacity(viewModel.canProceedToNext ? 1.0 : 0.6)
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
