import SwiftUI
import SwiftData

@main
struct WalnutApp: App {

    init() {
        Task {
            do {
                try await ServiceManager.shared.initializeServices()
            } catch {
                print("❌ Failed to initialize services: \(error)")
            }
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(for: [
                    Patient.self,
                    MedicalCase.self,
                    Prescription.self,
                    BioMarkerReport.self,
                    BioMarkerResult.self
                ])
                .preferredColorScheme(.light) // Force light mode
        }
    }
}
