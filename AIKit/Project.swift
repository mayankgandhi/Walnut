import ProjectDescription

let project = Project(
    name: "AIKit",
    organizationName: "m",
    settings: .settings(
        defaultSettings: .recommended
    ),
    targets: [
        .target(
            name: "AIKit",
            destinations: .iOS,
            product: .framework,
            bundleId: "m.walnut.aikit",
            sources: [
                "Sources/**"
            ],
            dependencies: [
                // No external dependencies needed for now
                // Can add SwiftUI implicitly through iOS platform
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
            name: "AIKitTests",
            destinations: .iOS,
            product: .unitTests,
            bundleId: "m.walnut.aikit.tests",
            sources: [
                "Tests/**"
            ],
            dependencies: [
                .target(name: "AIKit")
            ]
        )
    ]
)
