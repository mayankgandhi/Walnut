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
                // Header
                VStack(spacing: Spacing.medium) {
                    Image(systemName: "lock.shield.fill")
                        .font(.system(size: 50))
                        .foregroundStyle(Color.healthPrimary)
                    
                    Text("Permissions & Privacy")
                        .font(.largeTitle.bold())
                    
                    Text("Enable features to get the most out of your health tracking")
                        .font(.body)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, Spacing.medium)
                }
                .padding(.top, Spacing.large)
                
                // Privacy Commitment
                HealthCard {
                    VStack(spacing: Spacing.medium) {
                        HStack {
                            Image(systemName: "hand.raised.fill")
                                .font(.title2)
                                .foregroundStyle(Color.healthSuccess)
                            
                            VStack(alignment: .leading, spacing: Spacing.xs) {
                                Text("Your Privacy Matters")
                                    .font(.headline)
                                    .foregroundStyle(.primary)
                                
                                Text("All health data stays on your device. We never share your personal information.")
                                    .font(.body)
                                    .foregroundStyle(.secondary)
                            }
                            
                            Spacer()
                        }
                    }
                }
                
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
                    
                    PermissionCard(
                        icon: "heart.fill",
                        title: "Health Data",
                        description: "Sync with Apple Health for comprehensive tracking",
                        isRequired: false,
                        status: viewModel.permissions.healthKit
                    ) {
                        // HealthKit permission would be requested here
                        // For now, we'll simulate it
                        viewModel.permissions.healthKit = .granted
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

// MARK: - Permission Card
private struct PermissionCard: View {
    let icon: String
    let title: String
    let description: String
    let isRequired: Bool
    let status: PermissionStatus
    let action: () -> Void
    
    var body: some View {
        HealthCard {
            VStack(spacing: Spacing.medium) {
                HStack(spacing: Spacing.medium) {
                    // Icon
                    Image(systemName: icon)
                        .font(.title2)
                        .foregroundStyle(iconColor)
                        .frame(width: 30)
                    
                    // Content
                    VStack(alignment: .leading, spacing: Spacing.xs) {
                        HStack {
                            Text(title)
                                .font(.headline)
                                .foregroundStyle(.primary)
                            
                            if isRequired {
                                Text("Required")
                                    .font(.caption2.weight(.semibold))
                                    .foregroundStyle(.white)
                                    .padding(.horizontal, Spacing.small)
                                    .padding(.vertical, 2)
                                    .background(Color.healthError, in: Capsule())
                            }
                            
                            Spacer()
                        }
                        
                        Text(description)
                            .font(.body)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.leading)
                    }
                    
                    Spacer()
                }
                
                // Action button
                if status == .notDetermined {
                    DSButton(
                        "Allow \(title)",
                        style: .primary,
                        icon: "checkmark"
                    ) {
                        action()
                    }
                } else {
                    HStack {
                        Image(systemName: statusIcon)
                            .foregroundStyle(statusColor)
                        
                        Text(statusText)
                            .font(.body.weight(.medium))
                            .foregroundStyle(statusColor)
                        
                        Spacer()
                    }
                }
            }
        }
    }
    
    private var iconColor: Color {
        switch status {
        case .granted: return .healthSuccess
        case .denied: return .healthError
        case .notDetermined: return .healthPrimary
        }
    }
    
    private var statusIcon: String {
        switch status {
        case .granted: return "checkmark.circle.fill"
        case .denied: return "xmark.circle.fill"
        case .notDetermined: return "questionmark.circle"
        }
    }
    
    private var statusColor: Color {
        switch status {
        case .granted: return .healthSuccess
        case .denied: return .healthError
        case .notDetermined: return .secondary
        }
    }
    
    private var statusText: String {
        switch status {
        case .granted: return "Permission Granted"
        case .denied: return "Permission Denied"
        case .notDetermined: return "Permission Not Set"
        }
    }
}

// MARK: - Preview
#Preview {
    NavigationStack {
        PermissionsScreen(viewModel: OnboardingViewModel())
    }
}
