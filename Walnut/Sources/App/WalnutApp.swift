import SwiftUI
import SwiftData

#if DEBUG
import Atlantis
#endif

import PostHog

@main
struct WalnutApp: App {
    
    init() {
#if DEBUG
        Atlantis.start()
#endif
        
        let POSTHOG_API_KEY = "phc_rroYMTGzc0NBbseeG0kMSqvLP8UtrhRXk4l4kcOTrYw"
        let POSTHOG_HOST = "https://us.i.posthog.com"
        
        let config = PostHogConfig(apiKey: POSTHOG_API_KEY, host: POSTHOG_HOST)
        
        PostHogSDK.shared.setup(config)
        
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
