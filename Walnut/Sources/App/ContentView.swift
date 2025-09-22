
import SwiftUI
import SwiftData
import WalnutDesignSystem

public struct ContentView: View {

    @Query private var patients: [Patient]
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @State private var showingOnboarding = false
    
    private var firstPatient: Patient? {
        patients.first
    }
    
    public var body: some View {
        Group {
            if hasCompletedOnboarding,
               let patient = firstPatient {
                PatientTabView(patient: patient)
            } else {
                OnboardingContainerView {
                    hasCompletedOnboarding = true
                    AnalyticsService.shared.track(.app(.featureUsed))
                }
            }
        }
        .onAppear {
            // Check if onboarding was completed previously
            if !hasCompletedOnboarding {
                showingOnboarding = true
            }
        }        
    }
    
}
