//
//  AppInitializationErrorView.swift
//  Walnut
//
//  Created by Mayank Gandhi on 22/09/25.
//  Copyright © 2025 m. All rights reserved.
//

import SwiftUI

struct AppInitializationErrorView: View {
    let error: Error
    let onRetry: () -> Void

    var body: some View {
        ZStack {
            Color(.systemBackground)
                .ignoresSafeArea()

            VStack(spacing: 24) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 48))
                    .foregroundStyle(.orange)

                VStack(spacing: 8) {
                    Text("Initialization Failed")
                        .font(.title2.bold())
                        .foregroundStyle(.primary)

                    Text("Unable to start the app services")
                        .font(.body)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }

                Button("Try Again", action: onRetry)
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
            }
            .padding(.horizontal, 32)
        }
    }
}
