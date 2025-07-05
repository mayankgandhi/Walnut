import SwiftUI
import SwiftData

@main
struct WalnutApp: App {

    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(for: Patient.self)
        }
    }
}
