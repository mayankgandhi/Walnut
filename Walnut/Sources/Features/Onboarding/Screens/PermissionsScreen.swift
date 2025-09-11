//
//  PermissionsScreen.swift
//  Walnut
//
//  Created by Claude on 11/09/25.
//  Copyright © 2025 m. All rights reserved.
//

import SwiftUI
import WalnutDesignSystem

/// Permissions and data access screen for system permissions
struct PermissionsScreen: View {

     @Bindable var viewModel: OnboardingViewModel
    
    var body: some View {
        ScrollView {
            VStack(spacing: Spacing.xl) {
            
                OnboardingHeader(
                    icon: "lock.shield.fill",
                    title: "Permissions & Privacy",
                    subtitle: "Enable features to get the most out of your health tracking"
                )
                
               
                // Permissions List
                VStack(spacing: Spacing.medium) {
                    Text("Recommended Permissions")
                        .font(.title3.bold())
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    PermissionCard(
                        icon: "bell.fill",
                        title: "Notifications",
                        description: "Get reminders for medications, appointments, and health tracking",
                        isRequired: true,
                        status: viewModel.permissions.notifications
                    ) {
                        Task {
                            await viewModel.requestNotificationPermission()
                        }
                    }
                }
                
                // Additional Information
                HealthCard {
                    VStack(spacing: Spacing.medium) {
                        HStack {
                            Image(systemName: "info.circle.fill")
                                .font(.title2)
                                .foregroundStyle(Color.healthPrimary)
                            
                            VStack(alignment: .leading, spacing: Spacing.xs) {
                                Text("You can change these anytime")
                                    .font(.headline)
                                    .foregroundStyle(.primary)
                                
                                Text("Visit Settings > Privacy & Security to modify permissions later.")
                                    .font(.body)
                                    .foregroundStyle(.secondary)
                            }
                            
                            Spacer()
                        }
                    }
                }
                
                Spacer()
                    .frame(height: Spacing.xl)
            }
        }
        .padding(.horizontal, Spacing.large)
        .onAppear {
            viewModel.checkNotificationPermission()
        }
    }
}

// MARK: - Preview
#Preview {
    NavigationStack {
        PermissionsScreen(viewModel: OnboardingViewModel())
    }
}
