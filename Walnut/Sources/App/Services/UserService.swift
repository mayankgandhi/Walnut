//
//  UserService.swift
//  Walnut
//
//  Copyright © 2025 m. All rights reserved.
//

import Foundation

/// Service responsible for managing user identity and cross-device synchronization
@MainActor
final class UserService: ApplicationService {

    static let shared = UserService()

    var initializationPriority: Int { ServicePriority.core }

    private let userIDManager: UniversalUserID
    private var cachedUserID: String?

    private init() {
        userIDManager = UniversalUserID()
    }

    func initialize() async throws {
        let userResult = await userIDManager.getUserID()
        cachedUserID = userResult.id
        print("User ID: \(userResult.id) from \(userResult.source)")

        // Start monitoring sync for iCloud users
        userIDManager.startMonitoringSync()
    }

    // MARK: - Public Interface

    /// Get the current user ID (synchronous access after initialization)
    func getCurrentUserID() -> String {
        guard let cachedUserID = cachedUserID else {
            fatalError("UserService.getCurrentUserID() called before initialization completed")
        }
        return cachedUserID
    }

    /// Get the full user ID with source information
    func getUserIDWithSource() async -> (id: String, source: UniversalUserID.UserIDSource) {
        return await userIDManager.getUserID()
    }

    /// Get iCloud availability status and recommendations
    func getiCloudStatus() -> (available: Bool, recommendation: String?) {
        return userIDManager.getiCloudStatus()
    }

    func cleanup() async {
        // Remove any notification observers if needed
        // UniversalUserID manages its own cleanup
    }
}
