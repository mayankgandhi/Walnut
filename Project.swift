import ProjectDescription

let project = Project(
    name: "Walnut",
    targets: [
        .target(
            name: "Walnut",
            destinations: .iOS,
            product: .app,
            bundleId: "io.tuist.Walnut",
            infoPlist: .extendingDefault(
                with: [
                    "UILaunchScreen": [
                        "UIColorName": "",
                        "UIImageName": "",
                    ],
                ]
            ),
            sources: ["Walnut/Sources/**"],
            resources: ["Walnut/Resources/**"],
            dependencies: []
        ),
        .target(
            name: "WalnutTests",
            destinations: .iOS,
            product: .unitTests,
            bundleId: "io.tuist.WalnutTests",
            infoPlist: .default,
            sources: ["Walnut/Tests/**"],
            resources: [],
            dependencies: [.target(name: "Walnut")]
        ),
    ]
)
