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
    @State private var showDemoModeSheet = false
    @Namespace var animation
    
    var body: some View {
        
        VStack(alignment: .center, spacing: Spacing.medium) {
            
            Image("display-app-icon")
                .resizable()
                .scaledToFit()
                .frame(width: 96, height: 96)
                .onLongPressGesture(minimumDuration: 3.0) {
                    showDemoModeSheet = true
                    AnalyticsService.shared.track(.app(.featureUsed))
                }
            
            VStack(alignment: .center, spacing: Spacing.medium) {
                Text("HealthStack")
                    .font(.largeTitle.bold())
                    .foregroundStyle(.primary)
                
                Text("Your comprehensive health management companion")
                    .font(.title3)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)
            }
            
            if showFeatures {
                VStack(alignment: .center, spacing: Spacing.medium) {
                    featureItemView(icon: "ai-sparkle", title: "AI Powered", subtitle: "Automatically extract and organize your health data for easier access.")
                    featureItemView(icon: "graph", title: "Health Trends Tracker", subtitle: "Visualize your health journey with dynamic charts and trends. Stay informed, stay ahead.")
                    featureItemView(icon: "calendar", title: "Never Miss a Dose", subtitle: "Smart reminders for medications, appointments, and check-ups. Your health, always on track.")
                    featureItemView(icon: "journal", title: "Secure Health Vault", subtitle: "Store and organize all your health documents securely.")
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
