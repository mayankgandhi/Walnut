import SwiftUI
import WalnutDesignSystem
import RevenueCatUI

struct SubscriptionSettingsView: View {
    @StateObject private var subscriptionService = SubscriptionService.shared
    @State private var showPaywall = false
    
    var body: some View {
        HealthCard {
            
            VStack(spacing: Spacing.medium) {
                HStack(spacing: Spacing.medium) {
                    Image(systemName: subscriptionService.isSubscribed ? "star.circle.fill" : "star.circle")
                        .font(.title2)
                        .foregroundColor(subscriptionService.isSubscribed ? .healthPrimary : .gray)
                    
                    VStack(alignment: .leading, spacing: Spacing.xs) {
                        Text("Premium Status")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        Text(subscriptionService.isSubscribed ? "Premium Active" : "Free Plan")
                            .font(.body)
                            .foregroundColor(subscriptionService.isSubscribed ? .healthSuccess : .secondary)
                    }
                    
                    Spacer()
                    
                    if subscriptionService.isSubscribed {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.title2)
                            .foregroundColor(.healthSuccess)
                    } else {
                        DSButton("Upgrade", style: .secondary) {
                            showPaywall = true
                        }
                    }
                }
                
                if subscriptionService.isSubscribed {
                    Divider()
                    
                    VStack(spacing: Spacing.small) {
                        HStack {
                            Text("Current Plan")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            Spacer()
                            Text("Premium")
                                .font(.subheadline)
                                .fontWeight(.medium)
                        }
                        
                        if let customerInfo = subscriptionService.customerInfo,
                           let entitlement = customerInfo.entitlements.active.first?.value {
                            HStack {
                                Text("Renewal Date")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                Spacer()
                                Text(entitlement.expirationDate?.formatted(date: .abbreviated, time: .omitted) ?? "N/A")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                            }
                        }
                        
                        DSButton("Manage Subscription", style: .secondary) {
                            manageSubscription()
                        }
                    }
                } else {
                    Divider()
                    
                    VStack(alignment: .leading, spacing: Spacing.small) {
                        Text("Premium Features")
                            .font(.subheadline)
                            .fontWeight(.medium)
                        
                        VStack(alignment: .leading, spacing: Spacing.xs) {
                            SubFeatureRow(icon: "folder.badge.plus", title: "Unlimited Records")
                            SubFeatureRow(icon: "doc.text.magnifyingglass", title: "AI Document Parsing")
                            SubFeatureRow(icon: "square.and.arrow.up", title: "Export & Sharing")
                            SubFeatureRow(icon: "headphones", title: "Priority Support")
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $showPaywall, onDismiss: {
            Task {
                await subscriptionService.checkSubscriptionStatus()
            }
        }) {
            PaywallView()
        }
        .onAppear {
            Task {
                await subscriptionService.checkSubscriptionStatus()
            }
        }
    }
    
    private func manageSubscription() {
        if let url = URL(string: "https://apps.apple.com/account/subscriptions") {
            UIApplication.shared.open(url)
        }
    }
    
}

struct SubFeatureRow: View {
    let icon: String
    let title: String
    
    var body: some View {
        HStack(spacing: Spacing.small) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundColor(.healthPrimary)
                .frame(width: 16)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Spacer()
        }
    }
}

#Preview {
    SubscriptionSettingsView()
        .padding()
}
