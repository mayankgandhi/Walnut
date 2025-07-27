// swift-tools-version: 6.0
@preconcurrency import PackageDescription

let package = Package(
    name: "WalnutDependencies",
    defaultLocalization: "en",
    platforms: [.iOS(.v17)],
    dependencies: [        
        // Analytics
        .package(url: "git@github.com:PostHog/posthog-ios.git", from: "3.25.0"),

        .package(url:"https://github.com/ProxymanApp/atlantis", from: "1.29.2")
    ]
)
