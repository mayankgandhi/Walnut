//
//  SubscriptionManagementView.swift
//  Walnut
//
//  Created by Mayank Gandhi on 19/09/25.
//  Copyright © 2025 m. All rights reserved.
//

import SwiftUI
import WalnutDesignSystem

struct SubscriptionManagementView: View {
    @StateObject private var subscriptionService = SubscriptionService.shared
    @Environment(\.dismiss) private var dismiss
    @State private var isLoading = false

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: Spacing.large) {
                    subscriptionStatusCard
                    subscriptionDetailsCard
                    subscriptionActionsCard
                }
                .padding(Spacing.medium)
            }
            .navigationTitle("Subscription")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .task {
            await subscriptionService.checkSubscriptionStatus()
        }
    }

    // MARK: - View Components

    private var subscriptionStatusCard: some View {
        HealthCard {
            VStack(spacing: Spacing.medium) {
                HStack {
                    Image(systemName: "star.circle.fill")
                        .font(.largeTitle)
                        .foregroundStyle(Color.healthPrimary)

                    VStack(alignment: .leading, spacing: Spacing.xs) {
                        Text("Walnut Pro")
                            .font(.title2)
                            .fontWeight(.bold)

                        Text("Premium Active")
                            .font(.subheadline)
                            .foregroundStyle(Color.healthSuccess)
                    }

                    Spacer()

                    Image(systemName: "checkmark.circle.fill")
                        .font(.title2)
                        .foregroundStyle(Color.healthSuccess)
                }

                if let customerInfo = subscriptionService.customerInfo,
                   let entitlement = customerInfo.entitlements.active.first?.value {

                    Divider()

                    VStack(spacing: Spacing.small) {
                        subscriptionDetailRow(
                            title: "Plan",
                            value: entitlement.productIdentifier
                        )

                        if let renewalDate = entitlement.expirationDate {
                            subscriptionDetailRow(
                                title: "Renews",
                                value: renewalDate.formatted(date: .abbreviated, time: .omitted)
                            )
                        }

                        if let purchaseDate = entitlement.latestPurchaseDate {
                            subscriptionDetailRow(
                                title: "Purchased",
                                value: purchaseDate.formatted(date: .abbreviated, time: .omitted)
                            )
                        }
                    }
                }
            }
        }
    }

    private var subscriptionDetailsCard: some View {
        HealthCard {
            VStack(alignment: .leading, spacing: Spacing.medium) {
                Text("Premium Features")
                    .font(.headline)
                    .fontWeight(.semibold)

                VStack(spacing: Spacing.small) {
                    featureRow(icon: "folder.badge.plus", title: "Unlimited Medical Records", description: "Store unlimited patient records and medical cases")
                    featureRow(icon: "doc.text.magnifyingglass", title: "AI Document Parsing", description: "Advanced AI-powered document analysis")
                    featureRow(icon: "square.and.arrow.up", title: "Export & Sharing", description: "Export data and share with healthcare providers")
                    featureRow(icon: "headphones", title: "Priority Support", description: "Get priority customer support")
                }
            }
        }
    }

    private var subscriptionActionsCard: some View {
        HealthCard {
            VStack(spacing: Spacing.medium) {
                Text("Manage Subscription")
                    .font(.headline)
                    .fontWeight(.semibold)

                VStack(spacing: Spacing.small) {
                    DSButton("Manage in App Store", style: .secondary) {
                        manageSubscriptionInAppStore()
                    }

                    DSButton("Restore Purchases", style: .secondary) {
                        Task { await restorePurchases() }
                    }
                }

                Text("Changes to your subscription are managed through the App Store. Use the button above to modify or cancel your subscription.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
    }

    // MARK: - Helper Views

    private func subscriptionDetailRow(title: String, value: String) -> some View {
        HStack {
            Text(title)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
        }
    }

    private func featureRow(icon: String, title: String, description: String) -> some View {
        HStack(alignment: .top, spacing: Spacing.small) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(Color.healthPrimary)
                .frame(width: 24)

            VStack(alignment: .leading, spacing: Spacing.xs) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)

                Text(description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer()
        }
    }

    // MARK: - Actions

    private func manageSubscriptionInAppStore() {
        if let url = URL(string: "https://apps.apple.com/account/subscriptions") {
            UIApplication.shared.open(url)
        }
    }

    private func restorePurchases() async {
        isLoading = true
        defer { isLoading = false }

        do {
            _ = try await subscriptionService.restorePurchases()
        } catch {
            // Handle error - could show an alert here
            print("Failed to restore purchases: \(error)")
        }
    }
}

#Preview {
    SubscriptionManagementView()
}
