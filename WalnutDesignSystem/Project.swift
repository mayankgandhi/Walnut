import ProjectDescription

let project = Project(
    name: "WalnutDesignSystem",
    organizationName: "m",
    settings: .settings(
        defaultSettings: .recommended
    ),
    targets: [
        .target(
            name: "WalnutDesignSystem",
            destinations: .iOS,
            product: .framework,
            bundleId: "m.walnut.designsystem",
            sources: [
                "Sources/**"
            ],
            dependencies: [
                // No external dependencies - pure SwiftUI
            ],
            settings: .settings(
                base: [
                    "SWIFT_VERSION": "5.0",
                    "IPHONEOS_DEPLOYMENT_TARGET": "26.0"
                ],
                configurations: [
                    .debug(name: "Debug"),
                    .release(name: "Release")
                ],
                defaultSettings: .recommended
            )
        ),
        .target(
            name: "WalnutDesignSystemTests",
            destinations: .iOS,
            product: .unitTests,
            bundleId: "m.walnut.designsystem.tests",
            sources: [
                "Tests/**"
            ],
            dependencies: [
                .target(name: "WalnutDesignSystem")
            ]
        )
    ]
)