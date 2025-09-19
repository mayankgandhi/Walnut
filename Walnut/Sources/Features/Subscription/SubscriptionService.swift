import Foundation
import RevenueCat
import Combine

@MainActor
class SubscriptionService: NSObject, ObservableObject, ApplicationService {

    static let shared = SubscriptionService()

    @Published var isSubscribed: Bool = false
    @Published var currentOffering: Offering?
    @Published var customerInfo: CustomerInfo?
    @Published var isLoading: Bool = false

    private var cancellables = Set<AnyCancellable>()

    private override init() {
        super.init()
        // Configuration will be done in initialize() method
    }

    // MARK: - ApplicationService Conformance

    var initializationPriority: Int { ServicePriority.business }

    func initialize() async throws {
        // Configure RevenueCat
        Purchases.logLevel = .debug
        Purchases.configure(withAPIKey: "appl_UyfeaggCisDlNefCGPnvlcPWzcA")

        // Set up delegate
        Purchases.shared.delegate = self

        // Login with user ID from UserService
        let userID = UserService.shared.getCurrentUserID()
        _ = try? await Purchases.shared.logIn(userID)

        // Check initial subscription status and load offerings
        await checkSubscriptionStatus()
        await loadOfferings()
    }

    // MARK: - Subscription Status

    func checkSubscriptionStatus() async {
        isLoading = true

        do {
            let customerInfo = try await Purchases.shared.customerInfo()
            update(customerInfo: customerInfo)
        } catch {
            print("Failed to fetch customer info: \(error)")
            self.isSubscribed = false
        }

        isLoading = false
    }
    
    func update(customerInfo: CustomerInfo) {
        self.customerInfo = customerInfo
        self.isSubscribed = customerInfo.entitlements.active.count > 0
    }

    // MARK: - Server-Driven Paywalls

    func loadOfferings() async {
        do {
            let offerings = try await Purchases.shared.offerings()
            self.currentOffering = offerings.current
        } catch {
            print("Failed to load offerings: \(error)")
        }
    }

    // MARK: - RevenueCat Paywall Integration

    func loadPaywall() async -> PaywallData? {
        do {
            let offerings = try await Purchases.shared.offerings()

            // Get the current offering
            guard let offering = offerings.current else {
                print("No current offering found")
                return nil
            }

            // RevenueCat paywall data is available through the offering's metadata
            return PaywallData(
                offering: offering,
                localization: PaywallData.Localization(
                    title: offering.metadata["title"] as? String ?? "Unlock Premium Features",
                    subtitle: offering.metadata["subtitle"] as? String ?? "Get access to all premium features",
                    callToAction: offering.metadata["cta"] as? String ?? "Subscribe Now"
                )
            )
        } catch {
            print("Failed to load paywall: \(error)")
            return nil
        }
    }

    // MARK: - Purchase Management

    func purchase(package: Package) async throws -> CustomerInfo {
        let (_, customerInfo, _) = try await Purchases.shared.purchase(package: package)
        self.customerInfo = customerInfo
        self.isSubscribed = customerInfo.entitlements.active.count > 0
        return customerInfo
    }

    func restorePurchases() async throws -> CustomerInfo {
        let customerInfo = try await Purchases.shared.restorePurchases()
        self.customerInfo = customerInfo
        self.isSubscribed = customerInfo.entitlements.active.count > 0
        return customerInfo
    }

    // MARK: - Entitlement Checking

    func hasEntitlement(_ entitlementIdentifier: String) -> Bool {
        guard let customerInfo = customerInfo else { return false }
        return customerInfo.entitlements[entitlementIdentifier]?.isActive == true
    }

    func isPremiumFeatureAvailable() -> Bool {
        return hasEntitlement("pro") || isSubscribed
    }
    
    func getPaywallConfiguration() -> PaywallConfiguration? {
        guard let offering = currentOffering else { return nil }

        // This would typically come from your server or RevenueCat dashboard
        // For now, using static configuration
        let features = [
            PaywallFeature(
                title: "Unlimited Medical Records",
                description: "Store unlimited patient records and medical cases",
                icon: "folder.badge.plus"
            ),
            PaywallFeature(
                title: "AI Document Parsing",
                description: "Advanced AI-powered document analysis and parsing",
                icon: "doc.text.magnifyingglass"
            ),
        ]

        return PaywallConfiguration(
            title: "Unlock Full Access",
            subtitle: "Get unlimited access to all Walnut features",
            features: features,
            packages: Array(offering.availablePackages),
            termsURL: URL(string: "https://walnut.app/terms"),
            privacyURL: URL(string: "https://walnut.app/privacy")
        )
    }
    
    func login(userId: String) async {
        _ = try? await Purchases.shared.logIn(userId)
    }
    
    func logout() async {
        _ = try? await Purchases.shared.logOut()
    }
}

// MARK: - PurchasesDelegate

extension SubscriptionService: @MainActor PurchasesDelegate {
    func purchases(_ purchases: Purchases, receivedUpdated customerInfo: CustomerInfo) {
        self.customerInfo = customerInfo
        self.isSubscribed = customerInfo.entitlements.active.count > 0
    }
}

