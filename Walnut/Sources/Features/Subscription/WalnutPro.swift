//
//  WalnutPro.swift
//  Walnut
//
//  Created by Mayank Gandhi on 19/09/25.
//  Copyright © 2025 m. All rights reserved.
//

import SwiftUI
import WalnutDesignSystem
import RevenueCatUI

struct WalnutPro: View {
    @StateObject private var subscriptionService = SubscriptionService.shared
    @State private var showPaywall = false
    @State private var showSubscriptionManagement = false

    var body: some View {
        Button(action: handleTap) {
            HStack(spacing: Spacing.medium) {
                // Content Section
                VStack(alignment: .leading, spacing: Spacing.small) {
                    headerSection
                    subscriptionDetailsSection
                }
                .padding(Spacing.medium)

                Spacer()

                // Image and Action Section
                VStack(spacing: Spacing.small) {
                    Image("health-stack-pro")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 96, height: 96)

                    actionButton
                }
                .padding(.trailing, Spacing.medium)
            }
        }
        .buttonStyle(PlainButtonStyle())
        .background {
            premiumBackgroundGradient
        }
        .cornerRadius(Spacing.large)
        .padding(.horizontal, Spacing.medium)
        .sheet(isPresented: $showPaywall) {
            PaywallView()
        }
        .sheet(isPresented: $showSubscriptionManagement) {
            SubscriptionManagementView()
        }
        .task {
            await subscriptionService.checkSubscriptionStatus()
        }
    }

    // MARK: - View Components

    private var headerSection: some View {
        HStack(spacing: Spacing.small) {
            Text("Walnut Pro")
                .font(.system(.title3, design: .rounded, weight: .bold))
                .foregroundStyle(Color.white)

            if subscriptionService.isSubscribed {
                Image(systemName: "checkmark.circle.fill")
                    .font(.title3)
                    .foregroundStyle(Color.healthSuccess)
            }
        }
    }

    private var subscriptionDetailsSection: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            Text(primarySubscriptionText)
                .font(.system(.body, design: .rounded, weight: .medium))
                .foregroundStyle(Color.white.opacity(0.95))
                .multilineTextAlignment(.leading)

            if subscriptionService.isSubscribed {
                if let renewalInfo = renewalDateText {
                    Text(renewalInfo)
                        .font(.system(.caption, design: .rounded, weight: .regular))
                        .foregroundStyle(Color.white.opacity(0.75))
                }
            } else {
                Text("Transform your healthcare management")
                    .font(.system(.caption, design: .rounded, weight: .regular))
                    .foregroundStyle(Color.white.opacity(0.75))
            }
        }
    }

    @ViewBuilder
    private var actionButton: some View {
        if subscriptionService.isSubscribed {
            Text("Manage")
                .font(.system(.caption2, design: .rounded, weight: .semibold))
                .foregroundStyle(Color.healthPrimary)
                .padding(.horizontal, Spacing.small)
                .padding(.vertical, Spacing.xs)
                .background(.white.opacity(0.9), in: RoundedRectangle(cornerRadius: 8))
        } else {
            Text("Upgrade Now")
                .font(.system(.caption2, design: .rounded, weight: .semibold))
                .foregroundStyle(Color.healthPrimary)
                .padding(.horizontal, Spacing.small)
                .padding(.vertical, Spacing.xs)
                .background(.white.opacity(0.9), in: RoundedRectangle(cornerRadius: 8))
        }
    }

    // MARK: - Private Methods

    private func handleTap() {
        if subscriptionService.isSubscribed {
            showSubscriptionManagement = true
        } else {
            showPaywall = true
        }
    }

    private var primarySubscriptionText: String {
        if subscriptionService.isSubscribed {
            return "All premium features active"
        } else {
            return "Unlock unlimited records, AI parsing & advanced analytics"
        }
    }

    private var renewalDateText: String? {
        guard subscriptionService.isSubscribed,
              let customerInfo = subscriptionService.customerInfo,
              let entitlement = customerInfo.entitlements.active.first?.value,
              let renewalDate = entitlement.expirationDate else {
            return nil
        }
        return "Renews \(renewalDate.formatted(date: .abbreviated, time: .omitted))"
    }

    private var premiumBackgroundGradient: some View {
        LinearGradient(
            colors: [
                Color(uiColor: UIColor(red: 0.12, green: 0.12, blue: 0.12, alpha: 1)),
                Color(uiColor: UIColor(red: 0.18, green: 0.18, blue: 0.22, alpha: 1))
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

#Preview {
    WalnutPro()
}
