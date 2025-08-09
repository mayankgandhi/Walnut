import ProjectDescription

let project = Project(
    name: "Atlas",
    targets: [
        // Main iOS App Target
        .target(
            name: "Atlas",
            destinations: .iOS,
            product: .app,
            bundleId: "m.atlas",
            deploymentTargets: .iOS("17.0"),
            infoPlist: .extendingDefault(
                with: [
                    "UISupportedInterfaceOrientations": [
                        "UIInterfaceOrientationPortrait",
                        "UIInterfaceOrientationLandscapeLeft",
                        "UIInterfaceOrientationLandscapeRight"
                    ],
                    "UISupportedInterfaceOrientations~ipad": [
                        "UIInterfaceOrientationPortrait",
                        "UIInterfaceOrientationPortraitUpsideDown",
                        "UIInterfaceOrientationLandscapeLeft",
                        "UIInterfaceOrientationLandscapeRight"
                    ],
                    "CFBundleDisplayName": "Atlas",
                    "CFBundleShortVersionString": "1.0.0",
                    "CFBundleVersion": "1"
                ]
            ),
            sources: ["Sources/**"],
            resources: ["Resources/**"],
            dependencies: [
                .project(target: "WalnutDesignSystem", path: "../WalnutDesignSystem"),
                .project(target: "AIKit", path: "../AIKit"),
            ],
            settings: .settings(
                base: [
                    "DEVELOPMENT_TEAM": "Q7HVAVTGUP",
                    "CODE_SIGN_STYLE": "Automatic"
                ],
                configurations: [
                    .debug(name: "Debug"),
                    .release(name: "Release")
                ]
            )
        ),
        
        // Unit Tests Target
        .target(
            name: "AtlasTests",
            destinations: .iOS,
            product: .unitTests,
            bundleId: "m.atlas.tests",
            deploymentTargets: .iOS("17.0"),
            infoPlist: .default,
            sources: ["Tests/**"],
            dependencies: [
                .target(name: "Atlas")
            ],
            settings: .settings(
                base: [
                    "DEVELOPMENT_TEAM": "Q7HVAVTGUP"
                ]
            )
        )
    ]
)