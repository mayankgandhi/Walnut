import SwiftUI

@main
struct WalnutApp: App {

    @StateObject private var syncMonitor = CloudKitSyncMonitor()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
