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

        // Networking & Debugging
        .package(url: "https://github.com/ProxymanApp/atlantis", exact: "1.30.1"),

        // Roadmap
        .package(url: "https://github.com/AvdLee/Roadmap", exact: "1.1.0"),

        // Gate
        .package(url: "git@github.com:mayankgandhi/Gate.git", from: "1.0.0"),

        // Telemetry
        .package(url: "git@github.com:mayankgandhi/Telemetry.git", from: "1.0.0"),
    ]
)
