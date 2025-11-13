//
//  AnalyticsService.swift
//  Walnut
//
//  Copyright © 2025 m. All rights reserved.
//

import Foundation
import PostHog
import Telemetry
import Gate

#if DEBUG
import Atlantis
#endif

final class AnalyticsService: ApplicationService {

    static let shared = AnalyticsService()

    // Note: Using PostHog SDK directly for feature flag payloads
    // since Telemetry currently only supports boolean feature flags
    var claudeKey: String {
        PostHogSDK.shared.getFeatureFlagPayload("anthropic-api-key") as? String ?? ""
    }

    var openAIKey: String {
        PostHogSDK.shared.getFeatureFlagPayload("openai-api-key") as? String ?? ""
    }

    var initializationPriority: Int { ServicePriority.analytics }

    private init() {}

    func initialize() async throws {
        await initializeTelemetry()
        initializeDebugTools()
    }

    // MARK: - Private Methods

    private func initializeTelemetry() async {
        let provider = PostHogProvider(
            apiKey: "phc_rroYMTGzc0NBbseeG0kMSqvLP8UtrhRXk4l4kcOTrYw",
            host: "https://us.i.posthog.com"
        )

        TelemetryService.shared.configure(provider: provider)

        // Configure the PostHog provider
        await provider.configure()
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
