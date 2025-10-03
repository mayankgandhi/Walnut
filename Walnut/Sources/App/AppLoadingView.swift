//
//  AppLoadingView.swift
//  Walnut
//
//  Created by Mayank Gandhi on 22/09/25.
//  Copyright © 2025 m. All rights reserved.
//

import SwiftUI

struct AppLoadingView: View {

    @State private var isServicesInitialized = false
    @State private var initializationError: Error?

    var body: some View {
        Group {
            if isServicesInitialized {
                ContentView()
            } else if let error = initializationError {
                AppInitializationErrorView(error: error) {
                    initializeServices()
                }
            } else {
                AppSplashView()
            }
        }
        .task {
            initializeServices()
        }
    }

    private func initializeServices() {
        initializationError = nil

        Task.detached(priority: .userInitiated) {
            do {
                try await ServiceManager.shared.initializeServices()

                await MainActor.run {
                    withAnimation(.easeOut(duration: 0.3)) {
                        isServicesInitialized = true
                    }
                }
            } catch {
                print("❌ Failed to initialize services: \(error)")

                await MainActor.run {
                    initializationError = error
                }
            }
        }
    }
}
