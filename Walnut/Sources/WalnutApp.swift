import SwiftUI

@main
struct WalnutApp: App {

    @StateObject private var syncMonitor = CloudKitSyncMonitor()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
                .environmentObject(syncMonitor)
        }
    }
}
