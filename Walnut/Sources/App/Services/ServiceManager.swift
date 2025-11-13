//
//  ServiceManager.swift
//  Walnut
//
//  Copyright © 2025 m. All rights reserved.
//

import Foundation
import Gate

/// Manages the initialization and lifecycle of all application services
final class ServiceManager {

    static let shared = ServiceManager()

    private var services: [ApplicationService] = []
    private var isInitialized = false

    private init() {
        registerServices()
    }

    // MARK: - Service Registration

    private func registerServices() {
        // Configure UserService with Walnut-specific settings
        UserService.shared.configure(
            userDefaultsKey: "com.walnut.userID",
            userDefaults: .standard
        )

        // Configure Gate SubscriptionService with Walnut-specific settings
        SubscriptionService.shared.configure(
            configuration: .walnut,
            userIDProvider: { UserService.shared.getCurrentUserID() }
        )

        services = [
            UserService.shared,
            AnalyticsService.shared,
            SubscriptionService.shared
        ]
    }

    // MARK: - Lifecycle Management

    /// Initialize all registered services in priority order
    func initializeServices() async throws {
        guard !isInitialized else {
            print("⚠️ ServiceManager: Services already initialized")
            return
        }

        print("🚀 ServiceManager: Initializing \(services.count) services...")

        // Sort services by initialization priority
        let sortedServices = services.sorted { $0.initializationPriority < $1.initializationPriority }

        // Initialize services in priority order
        for service in sortedServices {
            do {
                let serviceName = String(describing: type(of: service))
                print("⏳ ServiceManager: Initializing \(serviceName) (priority: \(service.initializationPriority))")

                try await service.initialize()

                print("✅ ServiceManager: \(serviceName) initialized successfully")
            } catch {
                let serviceName = String(describing: type(of: service))
                print("❌ ServiceManager: Failed to initialize \(serviceName): \(error)")
                throw ServiceManagerError.serviceInitializationFailed(serviceName: serviceName, error: error)
            }
        }

        isInitialized = true
        print("🎉 ServiceManager: All services initialized successfully")
    }

    /// Cleanup all services (called during app termination)
    func cleanupServices() async {
        guard isInitialized else { return }

        print("🧹 ServiceManager: Cleaning up services...")

        // Cleanup in reverse priority order
        let reversedServices = services.sorted { $0.initializationPriority > $1.initializationPriority }

        for service in reversedServices {
            await service.cleanup()
        }

        isInitialized = false
        print("✅ ServiceManager: Service cleanup completed")
    }

    // MARK: - Service Access

    /// Get a specific service instance
    /// This is a convenience method for accessing services after initialization
    func getService<T: ApplicationService>(_ type: T.Type) -> T? {
        return services.first { $0 is T } as? T
    }

    // MARK: - Status

    var servicesInitialized: Bool {
        return isInitialized
    }

    var registeredServicesCount: Int {
        return services.count
    }
}

// MARK: - Error Types

enum ServiceManagerError: LocalizedError {
    case serviceInitializationFailed(serviceName: String, error: Error)

    var errorDescription: String? {
        switch self {
        case .serviceInitializationFailed(let serviceName, let error):
            return "Failed to initialize service '\(serviceName)': \(error.localizedDescription)"
        }
    }
}
