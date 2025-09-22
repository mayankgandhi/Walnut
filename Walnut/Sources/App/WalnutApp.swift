import SwiftUI
import SwiftData

@main
struct WalnutApp: App {

    var body: some Scene {
        WindowGroup {
            AppLoadingView()
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


