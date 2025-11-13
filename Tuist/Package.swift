// swift-tools-version: 5.9
import PackageDescription

#if TUIST
    import ProjectDescription

    let packageSettings = PackageSettings(
        productTypes: [
            "PostHog": .framework,
            "Factory": .framework,
            "Atlantis": .framework,
            "RevenueCat": .framework
        ]
    )
#endif

let package = Package(
    name: "Walnut",
    dependencies: [
        // Analytics - Shared
        .package(url: "https://github.com/PostHog/posthog-ios", exact: "3.31.0"),

        // Dependency Injection
        .package(url: "https://github.com/hmlongco/Factory", exact: "2.5.3"),

        // Networking & Debugging
        .package(url: "https://github.com/ProxymanApp/atlantis", exact: "1.30.1"),

        // Monetization
        .package(url: "https://github.com/RevenueCat/purchases-ios.git", exact: "5.39.2")
    ]
)
