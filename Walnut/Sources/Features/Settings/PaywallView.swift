import SwiftUI
import Gate

/// Walnut-specific wrapper around Gate's paywall view
struct PaywallView: View {
    var body: some View {
        GatePaywallView()
    }
}

#Preview {
    PaywallView()
}
