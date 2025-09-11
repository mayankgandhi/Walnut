//
//  WelcomeScreen.swift
//  Walnut
//
//  Created by Claude on 11/09/25.
//  Copyright © 2025 m. All rights reserved.
//

import SwiftUI
import WalnutDesignSystem

/// Welcome screen introducing the app's value proposition
struct WelcomeScreen: View {
    
    @Bindable var viewModel: OnboardingViewModel
    
    @State var showFeatures: Bool = false
    @Namespace var animation
    
    var body: some View {
        
        VStack(alignment: .center, spacing: Spacing.medium) {
            
            Image("display-app-icon")
                .resizable()
                .scaledToFit()
                .frame(width: 96, height: 96)
            
            VStack(alignment: .center, spacing: Spacing.medium) {
                Text("HealthStack")
                    .font(.largeTitle.bold())
                    .foregroundStyle(.primary)
                
                Text("Your comprehensive health management companion")
                    .font(.title3)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)
            }
            .padding(.bottom, Spacing.xl)
            
            
            if showFeatures {
                VStack(alignment: .center, spacing: Spacing.medium) {
                    FeatureItemView(icon: "ai-sparkle", title: "Super AI", subtitle: "Keep track of features")
                        .matchedGeometryEffect(id: "ai-sparkle", in: animation)
                    FeatureItemView(icon: "graph", title: "Trends", subtitle: "Keep track of features")
                        .matchedGeometryEffect(id: "graph", in: animation)
                    FeatureItemView(icon: "calendar", title: "Smart Reminders", subtitle: "Keep track of features")
                        .matchedGeometryEffect(id: "calendar", in: animation)
                    FeatureItemView(icon: "health-journal", title: "Health Journal", subtitle: "Keep track of features")
                        .matchedGeometryEffect(id: "health-journal", in: animation)
                    FeatureItemView(icon: "journal", title: "Health Journal", subtitle: "Keep track of features")
                        .matchedGeometryEffect(id: "journal", in: animation)
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
                    Image("health-journal")
                        .resizable()
                        .scaledToFit()
                        .matchedGeometryEffect(id: "health-journal", in: animation)
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
    }
}

struct FeatureItemView: View {
    
    var icon: String
    var title: String
    var subtitle: String
    
    @State var showFeatures: Bool = false
    @Namespace var itemNamespace
    
    var body: some View {
        Group {
            if showFeatures {
                
                HStack(alignment: .center, spacing: Spacing.medium) {
                    Image(icon)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 64, height: 64)
                        .matchedGeometryEffect(id: icon, in: itemNamespace)
                    
                    VStack(alignment: .leading, spacing: Spacing.xs) {
                        Text(title)
                            .font(.headline.bold())
                            .foregroundStyle(.primary)
                        
                        Text(subtitle)
                            .font(.subheadline)
                            .foregroundStyle(.primary)
                    }
                    
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .subtleCardStyle()
            } else {
                Image(icon)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 64, height: 64)
                    .matchedGeometryEffect(id: icon, in: itemNamespace)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
            }
        }
        .task {
            try? await Task.sleep(nanoseconds: 2_000_000_000)
            withAnimation(.easeInOut(duration: 0.5)) {
                showFeatures = true
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
