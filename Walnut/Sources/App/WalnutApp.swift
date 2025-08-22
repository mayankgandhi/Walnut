import SwiftUI
import SwiftData

#if DEBUG
// 1. Import Atlantis
import Atlantis
#endif


@main
struct WalnutApp: App {

    init() {
        #if DEBUG
        Atlantis.start()
        #endif
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(for: [
                    Patient.self,
                    MedicalCase.self,
                    Prescription.self,
                    BloodReport.self,
                    BloodTestResult.self
                ])
                .preferredColorScheme(.light) // Force light mode
        }
    }
}
