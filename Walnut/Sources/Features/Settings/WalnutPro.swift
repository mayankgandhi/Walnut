import SwiftUI
import Gate

/// Walnut-specific wrapper around Gate's SubscriptionCard
struct WalnutPro: View {
    var body: some View {
        SubscriptionCard(
            configuration: .walnut,
            appIconImage: Image("health-stack-pro")
        )
    }
}

#Preview {
    WalnutPro()
}
