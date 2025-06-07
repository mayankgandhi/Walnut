// swift-tools-version: 6.0
@preconcurrency import PackageDescription

let package = Package(
    name: "WalnutDependencies",
    defaultLocalization: "en",
    platforms: [.iOS(.v17)],
    dependencies: [
        // Architecture and State Management
        .package(url: "https://github.com/pointfreeco/swift-composable-architecture", from: "1.19.1"),
        
        // Analytics
        .package(url: "git@github.com:PostHog/posthog-ios.git", from: "3.25.0"),

    ]
)
