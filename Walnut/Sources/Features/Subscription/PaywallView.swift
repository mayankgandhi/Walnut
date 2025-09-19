//
//  PaywallView.swift
//  Walnut
//
//  Created by Mayank Gandhi on 19/09/25.
//  Copyright © 2025 m. All rights reserved.
//

import SwiftUI
import WalnutDesignSystem
import RevenueCat
import RevenueCatUI

struct AppPaywallView: View {
    @StateObject private var subscriptionService = SubscriptionService.shared
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        PaywallView(displayCloseButton: true)
            .overlay(alignment: .topTrailing) {
                Button("Done") {
                    dismiss()
                }
                .font(.system(.body, design: .rounded, weight: .medium))
                .foregroundStyle(.primary)
                .padding()
            }
            .task {
                await subscriptionService.loadOfferings()
            }
    }
}

#Preview {
    PaywallView()
}
