
import SwiftUI
import SwiftData
import WalnutDesignSystem

public struct ContentView: View {
    @Query private var patients: [Patient]
    @State private var showOnboarding = false
    
    private var hasPatients: Bool {
        !patients.isEmpty
    }
    
    private var firstPatient: Patient? {
        patients.first
    }

    public var body: some View {
        Group {
            if hasPatients, let patient = firstPatient {
                PatientTabView(patient: patient)
            } else {
                onboardingView
            }
        }
        .onAppear {
            showOnboarding = !hasPatients
        }
    }
    
    private var onboardingView: some View {
        NavigationStack {
            VStack(spacing: 32) {
                Spacer()
                
                VStack(spacing: 16) {
                    Image(systemName: "heart.text.square.fill")
                        .font(.system(size: 80))
                        .foregroundStyle(Color.healthPrimary)
                    
                    VStack(spacing: 8) {
                        Text("Welcome to Walnut")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        Text("Let's create your medical profile to get started")
                            .font(.title3)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                    }
                }
                
                Spacer()
                
                VStack(spacing: 16) {
                    Button(action: {
                        showOnboarding = true
                    }) {
                        Text("Create Profile")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.healthPrimary)
                            .cornerRadius(12)
                    }
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 50)
            }
            .padding(.horizontal, 24)
            .navigationBarHidden(true)
        }
        .sheet(isPresented: $showOnboarding) {
            PatientEditor(patient: nil)
        }
    }
    
}
