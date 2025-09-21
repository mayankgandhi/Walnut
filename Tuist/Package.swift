// swift-tools-version: 6.0
@preconcurrency import PackageDescription

let package = Package(
    name: "WalnutDependencies",
    defaultLocalization: "en",
    platforms: [.iOS(.v17)],
    dependencies: [
        // Dependency Injection
        .package(url: "git@github.com:hmlongco/Factory.git", from: "2.5.3")
        // Analytics
        .package(url: "git@github.com:PostHog/posthog-ios.git", from: "3.31.0"),
        // Network Debugging
        .package(url:"https://github.com/ProxymanApp/atlantis", from: "1.30.1"),
        // Subscription Management
        .package(url: "https://github.com/RevenueCat/purchases-ios-spm.git", from: "5.39.2")
    ]
)
