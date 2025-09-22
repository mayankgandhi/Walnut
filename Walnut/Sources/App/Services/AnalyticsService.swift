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

    // MARK: - Event Tracking

    func track(_ event: AnalyticsEvent) {
        PostHogSDK.shared.capture(event.eventName)
    }

    func track(eventName: String, properties: [String: Any] = [:]) {
        PostHogSDK.shared.capture(eventName, properties: properties)
    }

    func identify(userId: String, properties: [String: Any] = [:]) {
        PostHogSDK.shared.identify(userId, userProperties: properties)
    }

    func setUserProperty(key: String, value: Any) {
        PostHogSDK.shared.identify(PostHogSDK.shared.getDistinctId(), userProperties: [key: value])
    }

    func alias(alias: String) {
        PostHogSDK.shared.alias(alias)
    }

    func reset() {
        PostHogSDK.shared.reset()
    }

    // MARK: - Feature Flags

    func isFeatureEnabled(_ featureFlag: String) -> Bool {
        return PostHogSDK.shared.isFeatureEnabled(featureFlag)
    }

    func getFeatureFlagPayload(_ featureFlag: String) -> Any? {
        return PostHogSDK.shared.getFeatureFlagPayload(featureFlag)
    }

    // MARK: - Debug Helpers

    #if DEBUG
    func trackDebug(_ event: AnalyticsEvent) {
        print("🔍 Analytics Event: \(event.eventName)")
        track(event)
    }
    #endif

    func cleanup() async {
        // PostHog doesn't require explicit cleanup
        // Atlantis stops automatically when the app terminates
    }
}
