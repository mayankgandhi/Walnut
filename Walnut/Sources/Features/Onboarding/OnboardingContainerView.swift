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
        
            VStack(alignment: .center, spacing: Spacing.small) {

                if viewModel.currentScreenIndex != 0 {
                    ProgressIndicatorView(
                        progress: viewModel.progressPercentage,
                        currentStep: viewModel.currentScreenIndex + 1,
                        totalSteps: viewModel.availableScreens.count
                    )
                    .padding(.vertical, Spacing.large)
                    .padding(.horizontal, Spacing.medium)
                    .opacity(viewModel.currentScreen != .welcome ? 1 : 0.01)
                }
                
                ZStack {
                    Group {
                        switch viewModel.currentScreen {
                        case .welcome:
                            WelcomeScreen(viewModel: viewModel)
                        case .healthProfile:
                            HealthProfileScreen(viewModel: viewModel)
                        case .permissions:
                            PermissionsScreen(viewModel: viewModel)
                        case .patientName:
                            PatientNameScreen(viewModel: viewModel)
                        case .patientDateOfBirth:
                            PatientDateOfBirthScreen(viewModel: viewModel)
                        case .vitalsIntroduction:
                            VitalsIntroductionScreen(viewModel: viewModel)
                        }
                    }
                    .transition(.opacity.combined(with: .move(edge: .trailing)))
                }
                .frame(
                    maxWidth: .infinity,
                    maxHeight: .infinity,
                    alignment: .top
                )
                .animation(.easeInOut(duration: 0.3), value: viewModel.currentScreen)
                
                OnboardingNavigationView(viewModel: viewModel)
                    .padding(.vertical, Spacing.large)
                    .padding(.horizontal, Spacing.medium)
            }
            .environment(viewModel)
            .navigationBarHidden(true)
            .onReceive(NotificationCenter.default.publisher(for: .onboardingCompleted)) { _ in
                Task { @MainActor in
                    onOnboardingComplete()
                }
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
