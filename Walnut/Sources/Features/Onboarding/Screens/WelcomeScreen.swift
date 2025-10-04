//
//  WelcomeScreen.swift
//  Walnut
//
//  Created by Claude on 11/09/25.
//  Copyright © 2025 m. All rights reserved.
//

import SwiftUI
import SwiftData
import WalnutDesignSystem

/// Welcome screen introducing the app's value proposition
struct WelcomeScreen: View {
    
    @Bindable var viewModel: OnboardingViewModel
    
    @State var showFeatures: Bool = false
    @State var showChildFeatures: Bool = false
    @State var showDisclaimer: Bool = false
    @State private var showDemoModeSheet = false
    @Namespace var animation
    
    var body: some View {
        ScrollView {
            VStack(alignment: .center, spacing: Spacing.medium) {
                VStack(alignment: .center, spacing: Spacing.medium) {
                    
                    Image("NewWalnutAppIcon")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 96, height: 96)
                        .onLongPressGesture(minimumDuration: 2.0) {
                            showDemoModeSheet = true
                        }
                    
                    VStack(alignment: .center) {
                        Text("Walnut")
                            .font(.title2.bold())
                            .foregroundStyle(.primary)
                        
                        Text("Your personal health journal, at your fingertips.")
                            .font(.headline)
                            .multilineTextAlignment(.center)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                }
                
                if showFeatures {
                    VStack(alignment: .center, spacing: Spacing.medium) {
                        featureItemView(icon: "ai-sparkle", title: "AI Powered", subtitle: "Automatically extract and organize your  data for easier access.")
                        featureItemView(icon: "graph", title: "Trends Tracker", subtitle: "Visualise your data over time and identify trends.")
                        featureItemView(icon: "calendar", title: "Never Miss a Dose", subtitle: "Smart reminders for medications, appointments, and check-ups.")
                        featureItemView(icon: "journal", title: "Secure Vault", subtitle: "Store and organize all your documents securely on device.")
                    }
                } else {
                    HStack(alignment: .center, spacing: Spacing.medium) {
                        Image("ai-sparkle")
                            .resizable()
                            .scaledToFit()
                            .matchedGeometryEffect(id: "ai-sparkle", in: animation)
                        Image("graph")
                            .resizable()
                            .scaledToFit()
                            .matchedGeometryEffect(id: "graph", in: animation)
                        Image("calendar")
                            .resizable()
                            .scaledToFit()
                            .matchedGeometryEffect(id: "calendar", in: animation)
                        Image("journal")
                            .resizable()
                            .scaledToFit()
                            .matchedGeometryEffect(id: "journal", in: animation)
                    }
                }
                
                if showDisclaimer {
                    HStack {
                        Image("message")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 64, height: 64)
                        
                        VStack(alignment: .leading, spacing: Spacing.xs) {
                            Text("Not Medical Advice")
                                .font(.headline.bold())
                                .foregroundStyle(.primary)
                            
                            Text("While we're here to support your wellness journey, this app doesn't provide medical advice. Please work with your healthcare provider for personalized medical guidance.")
                                .font(.caption.weight(.light))
                                .foregroundStyle(.primary)
                        }
                    }
                    .padding(Spacing.medium)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .background(.red.opacity(0.1), in: RoundedRectangle(cornerRadius: 8))
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 8))
                }
                
                Spacer()
            }
        }
        .padding(.horizontal, Spacing.medium)
        .task {
            try? await Task.sleep(nanoseconds: 500_000_000)
            withAnimation(.easeInOut(duration: 1.5)) {
                showFeatures = true
            }
        }
        .fullScreenCover(isPresented: $showDemoModeSheet) {
            DemoModeView()
        }
    }
    
    func featureItemView(
        icon: String,
        title: String,
        subtitle: String
    ) -> some View {
        Group {
            if showChildFeatures {
                HStack(alignment: .center, spacing: Spacing.medium) {
                    Image(icon)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 64, height: 64)
                        .matchedGeometryEffect(id: icon, in: animation)
                    
                    VStack(alignment: .leading, spacing: Spacing.xs) {
                        Text(title)
                            .font(.headline.bold())
                            .foregroundStyle(.primary)
                        
                        Text(subtitle)
                            .font(.caption.weight(.light))
                            .foregroundStyle(.primary)
                    }
                    
                }
                .padding(Spacing.small)
                .frame(maxWidth: .infinity, alignment: .leading)
                .subtleCardStyle()
            } else {
                Image(icon)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 64, height: 64)
                    .matchedGeometryEffect(id: icon, in: animation)
                    .padding(.horizontal, Spacing.medium)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .task {
            try? await Task.sleep(nanoseconds: 2_000_000_000)
            withAnimation(.easeInOut(duration: 0.5)) {
                showChildFeatures = true
                showDisclaimer = true
            }
        }
    }
}



// MARK: - Preview
#Preview {
    NavigationStack {
        WelcomeScreen(viewModel: OnboardingViewModel())
    }
}
