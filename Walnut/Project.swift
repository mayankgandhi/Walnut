import ProjectDescription

let infoPlist: InfoPlist = .extendingDefault(with: [
    "UILaunchStoryboardName": "LaunchScreen.storyboard",
    "UILaunchStoryboardName~ipad": "Launch Screen-iPAD.storyboard",
    "UILaunchScreen": "LaunchScreen.storyboard",
    "CFBundleName": .string("$(PRODUCT_NAME)"),
    "CFBundleIdentifier": .string("$(PRODUCT_BUNDLE_IDENTIFIER)"),
    "CFBundleVersion": .string("$(MARKETING_VERSION)"),
    "CFBundleShortVersionString": .string("$(CURRENT_PROJECT_VERSION)"),
    "CFBundlePackageType": .string("$(PRODUCT_BUNDLE_PACKAGE_TYPE)"),
    "CFBundleExecutable": .string("$(PRODUCT_NAME)"),
    "CFBundleDisplayName": .string("$(DISPLAY_NAME)"),
    "LSApplicationCategoryType": .string("public.app-category.health"),
    "UISupportedInterfaceOrientations": .array([
        .string("UIInterfaceOrientationPortrait"),
    ]),
    "UISupportedInterfaceOrientations~ipad": .array([
        .string("UIInterfaceOrientationPortrait"),
        .string("UIInterfaceOrientationPortraitUpsideDown"),
        .string("UIInterfaceOrientationLandscapeLeft"),
        .string("UIInterfaceOrientationLandscapeRight"),
    ]),
    "UIStatusBarStyle": .string("UIStatusBarStyleDefault"),
    "UIViewControllerBasedStatusBarAppearance": .boolean(true),
    "UIRequiresFullScreen": .boolean(false),
    "OneSignal_suppress_launch_urls": .boolean(true),
    "BGTaskSchedulerPermittedIdentifiers": .array([
        .string("$(PRODUCT_BUNDLE_IDENTIFIER)"),
    ]),
    "ITSAppUsesNonExemptEncryption": .boolean(false),
    "LSApplicationQueriesSchemes": .array([
    ]),
    "LSEnvironment": .dictionary([:]),
    "NSBonjourServices": .array([
        .string("_Proxyman._tcp"),
    ]),
    "UIBackgroundModes": .array([
        .string("processing"),
        .string("remote-notification"),
    ]),
    "NSAppTransportSecurity": .dictionary(
        [
            "NSAllowsArbitraryLoads" : Plist.Value.boolean(true),
        ]
    ),
    "NSLocalNetworkUsageDescription": .string("Atlantis would use Bonjour Service to discover Proxyman app from your local network. Atlantis uses it to transfer the data from your iOS app to Proxyman macOS for debugging purposes."),
])

let settings: SettingsDictionary = [
    "PRODUCT_NAME": .string("Walnut"),
    "DISPLAY_NAME": .string("Walnut"),
    "PRODUCT_BUNDLE_IDENTIFIER": .string("m.walnut"),
    "EXECUTABLE_NAME": .string("Walnut"),
    "CURRENT_PROJECT_VERSION": .string("1.0"),
    "MARKETING_VERSION": "1",
    "OTHER_LDFLAGS": "-ObjC",
]
    .automaticCodeSigning(devTeam: "Q7HVAVTGUP")

let project = Project(
    name: "Walnut",
    organizationName: "m",
    settings: .settings(
        defaultSettings: .recommended
    ),
    targets: [
        .target(
            name: "Walnut",
            destinations: .iOS,
            product: .app,
            bundleId: "m.walnut",
            infoPlist: infoPlist,
            sources: [
                "Sources/**",  // This includes files directly in Sources/
                "Sources/**/**",  // This includes files in subdirectories
            ],
            resources: [
                "Resources/**/**",
                "Resources/AppIcon.icon/*/**",
            ],
            entitlements: .file(path: .relativeToRoot("Walnut/Walnut.entitlements")),
            dependencies: [
                .external(name: "PostHog"),
                .external(name: "Atlantis"),
            ],
            settings: .settings(base: settings,
                                configurations: [
                                    .debug(name: "Debug"),
                                    .release(name: "Release"),
                                ],
                                defaultSettings: .recommended)
        ),
        .target(
            name: "WalnutTests",
            destinations: .iOS,
            product: .unitTests,
            bundleId: "io.tuist.WalnutTests",
            infoPlist: .default,
            sources: [
                "Tests/**"
            ],
            resources: [],
            dependencies: [
                .target(name: "Walnut")
            ]
        ),
    ]
)
