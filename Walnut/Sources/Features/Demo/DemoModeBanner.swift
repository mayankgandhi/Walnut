//
//  DemoModeBanner.swift
//  Walnut
//
//  Created by Claude Code on 21/09/25.
//  Copyright © 2025 m. All rights reserved.
//

import SwiftUI
import WalnutDesignSystem

public struct DemoModeBanner: View {

    @State private var demoManager = DemoModeManager.shared

    public init() {}

    public var body: some View {
        if demoManager.isDemoModeEnabled {
            HStack(spacing: Spacing.small) {
                Image(systemName: "play.circle.fill")
                    .foregroundStyle(.orange)
                    .font(.caption.weight(.semibold))

                Text("Demo Mode Active")
                    .font(.caption.weight(.medium))
                    .foregroundStyle(.primary)

                Spacer()

                Text("Sample Data")
                    .font(.caption2.weight(.medium))
                    .foregroundStyle(.orange)
                    .padding(.horizontal, Spacing.xs)
                    .padding(.vertical, 2)
                    .background(.orange.opacity(0.15))
                    .cornerRadius(4)
            }
            .padding(.horizontal, Spacing.medium)
            .padding(.vertical, Spacing.xs)
            .background(.orange.opacity(0.1))
            .border(.orange.opacity(0.3), width: 0.5)
        }
    }
}

#Preview {
    VStack {
        DemoModeBanner()
        Spacer()
    }
}