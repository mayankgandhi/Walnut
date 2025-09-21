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
])

let settings: SettingsDictionary = [
    "PRODUCT_NAME": .string("Walnut-Playground"),
    "DISPLAY_NAME": .string("Walnut-Playground"),
    "PRODUCT_BUNDLE_IDENTIFIER": .string("m.Walnut-Playground"),
    "EXECUTABLE_NAME": .string("Walnut-Playground"),
    "CURRENT_PROJECT_VERSION": .string("1.0"),
    "MARKETING_VERSION": "1",
    "OTHER_LDFLAGS": "-ObjC",
    "IPHONEOS_DEPLOYMENT_TARGET": "26.0",
]
    .automaticCodeSigning(devTeam: "Q7HVAVTGUP")

let project = Project(
    name: "Walnut-Playground",
    organizationName: "m",
    settings: .settings(
        defaultSettings: .recommended
    ),
    targets: [
        .target(
            name: "Walnut-Playground",
            destinations: .iOS,
            product: .app,
            bundleId: "m.Walnut-Playground",
            infoPlist: infoPlist,
            sources: [
                "Sources/**",  // This includes files directly in Sources/
                "Sources/**/**",  // This includes files in subdirectories
            ],
            resources: [
                "Resources/**/**",
            ],
            dependencies: [],
            settings: .settings(base: settings,
                                configurations: [
                                    .debug(name: "Debug"),
                                    .release(name: "Release"),
                                ],
                                defaultSettings: .recommended)
        ),
        .target(
            name: "Walnut-PlaygroundTests",
            destinations: .iOS,
            product: .unitTests,
            bundleId: "io.tuist.Walnut-PlaygroundTests",
            infoPlist: .default,
            sources: [
                "Tests/**"
            ],
            resources: [],
            dependencies: [.target(name: "Walnut-Playground")]
        ),
    ]
)
