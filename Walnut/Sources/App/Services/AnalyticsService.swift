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

final class AnalyticsService: ApplicationService {

    static let shared = AnalyticsService()

    var claudeKey: String {
        PostHogSDK.shared.getFeatureFlagPayload("anthropic-api-key") as? String ?? ""
    }

    var openAIKey: String {
        PostHogSDK.shared.getFeatureFlagPayload("openai-api-key") as? String ?? ""
    }

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



    // MARK: - Debug Helpers

    #if DEBUG
    func trackDebug(_ event: AnalyticsEvent) {
        print("🔍 Analytics Event: \(event.eventName)")
    }
    #endif

    func cleanup() async {
        // PostHog doesn't require explicit cleanup
        // Atlantis stops automatically when the app terminates
    }
}
