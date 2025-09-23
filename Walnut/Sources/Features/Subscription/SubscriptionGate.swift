import SwiftUI
import WalnutDesignSystem
import RevenueCat
import RevenueCatUI

struct SubscriptionGate: ViewModifier {

    @StateObject private var subscriptionService = SubscriptionService.shared
    @State private var showPaywall = false
    
    let feature: PremiumFeature
    let fallbackContent: AnyView?
    
    init(feature: PremiumFeature, fallbackContent: (() -> AnyView)? = nil) {
        self.feature = feature
        self.fallbackContent = fallbackContent?()
    }
    
    func body(content: Content) -> some View {
        Group {
            if subscriptionService.isPremiumFeatureAvailable() {
                content
            } else {
                fallbackContent ?? AnyView(premiumPrompt)
            }
        }
        .presentPaywallIfNeeded(
            requiredEntitlementIdentifier: "pro",
            purchaseCompleted: { customerInfo in
                print("Purchase Completed: \(customerInfo.entitlements)")
                subscriptionService.update(customerInfo: customerInfo)
            },
            restoreCompleted: { customerInfo in
                print("Purchases restored: \(customerInfo.entitlements)")
                subscriptionService.update(customerInfo: customerInfo)
            }
        )
        
    }
    
    private var premiumPrompt: some View {
        HealthCard {
            VStack(spacing: Spacing.medium) {
                Image(systemName: "star.circle.fill")
                    .font(.system(size: 40))
                    .foregroundColor(.healthPrimary)
                
                Text(feature.title)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.center)
                
                Text(feature.description)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                
                DSButton("Upgrade to Premium", style: .primary) {
                    showPaywall = true
                }
            }
            .padding(Spacing.medium)
        }
    }
}

enum PremiumFeature {
    case unlimitedRecords
    case aiDocumentParsing
    case exportSharing
    case prioritySupport
    case advancedAnalytics
    
    var title: String {
        switch self {
            case .unlimitedRecords:
                return "Unlimited Medical Records"
            case .aiDocumentParsing:
                return "AI Document Parsing"
            case .exportSharing:
                return "Export & Sharing"
            case .prioritySupport:
                return "Priority Support"
            case .advancedAnalytics:
                return "Advanced Analytics"
        }
    }
    
    var description: String {
        switch self {
            case .unlimitedRecords:
                return "Store unlimited patient records and medical cases. Upgrade to premium to access this feature."
            case .aiDocumentParsing:
                return "Advanced AI-powered document analysis and parsing. Upgrade to premium to access this feature."
            case .exportSharing:
                return "Export records and share with healthcare providers. Upgrade to premium to access this feature."
            case .prioritySupport:
                return "Get priority customer support and updates. Upgrade to premium to access this feature."
            case .advancedAnalytics:
                return "View detailed analytics and insights about your health data. Upgrade to premium to access this feature."
        }
    }
}

extension View {
    func requiresPremium(_ feature: PremiumFeature, fallback: (() -> AnyView)? = nil) -> some View {
        modifier(SubscriptionGate(feature: feature, fallbackContent: fallback))
    }
}

// Helper for checking subscription status in views
struct SubscriptionStatusView: View {
    @StateObject private var subscriptionService = SubscriptionService.shared
    
    var body: some View {
        Group {
            if subscriptionService.isSubscribed {
                HStack {
                    Image(systemName: "star.circle.fill")
                        .foregroundColor(.healthPrimary)
                    Text("Premium")
                        .font(.caption)
                        .fontWeight(.medium)
                }
            } else {
                HStack {
                    Image(systemName: "star.circle")
                        .foregroundColor(.gray)
                    Text("Free")
                        .font(.caption)
                        .fontWeight(.medium)
                }
            }
        }
    }
}
