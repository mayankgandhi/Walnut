//
//  AnalyticsService.swift
//  Walnut
//
//  Copyright © 2025 m. All rights reserved.
//

import Foundation
import PostHog

#if DEBUG
import Atlantis
#endif

/// Service responsible for initializing analytics and debugging tools
@MainActor
final class AnalyticsService: ApplicationService {

    static let shared = AnalyticsService()

    var initializationPriority: Int { ServicePriority.analytics }

    private init() {}

    func initialize() async throws {
        await initializePostHog()
        initializeDebugTools()
    }

    // MARK: - Private Methods

    private func initializePostHog() async {
        let apiKey = "phc_rroYMTGzc0NBbseeG0kMSqvLP8UtrhRXk4l4kcOTrYw"
        let host = "https://us.i.posthog.com"

        let config = PostHogConfig(apiKey: apiKey, host: host)
        PostHogSDK.shared.setup(config)
    }

    private func initializeDebugTools() {
        #if DEBUG
        Atlantis.start()
        #endif
    }

    func cleanup() async {
        // PostHog doesn't require explicit cleanup
        // Atlantis stops automatically when the app terminates
    }
}
