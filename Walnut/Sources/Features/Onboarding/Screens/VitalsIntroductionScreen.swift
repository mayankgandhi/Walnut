//
//  VitalsIntroductionScreen.swift
//  Walnut
//
//  Created by Claude on 11/09/25.
//  Copyright © 2025 m. All rights reserved.
//

import SwiftUI
import WalnutDesignSystem

/// Vitals tracking introduction screen showcasing health monitoring features
struct VitalsIntroductionScreen: View {
    @Bindable var viewModel: OnboardingViewModel
    
    var body: some View {
        VStack(spacing: Spacing.xl) {
            
            OnboardingHeader(icon: "heart.text.square.fill", title: "Vitals Tracking", subtitle: "Track your vital signs and health metrics with ease")
            
            
            // Features Section
            VStack(spacing: Spacing.medium) {
                Text("Powerful Features")
                    .font(.title3.bold())
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                VStack(spacing: Spacing.medium) {
                    FeatureRow(
                        icon: "chart.line.uptrend.xyaxis",
                        title: "Trend Analysis",
                        description: "Visualize your health data over time with interactive charts",
                        color: .healthPrimary
                    )
                    
                    FeatureRow(
                        icon: "bell.fill",
                        title: "Smart Reminders",
                        description: "Get reminded to take measurements at optimal times",
                        color: .healthWarning
                    )
                    
                    FeatureRow(
                        icon: "share",
                        title: "Share with Doctors",
                        description: "Export reports to share with your healthcare team",
                        color: .healthSuccess
                    )
                    
                    FeatureRow(
                        icon: "target",
                        title: "Personal Goals",
                        description: "Set targets and track your progress toward better health",
                        color: .purple
                    )
                }
            }
            
            
            
            Spacer()
                .frame(height: Spacing.xl)
        }
        
        .padding(.horizontal, Spacing.large)
    }
}

// MARK: - Supporting Views
private struct VitalCard: View {
    let title: String
    let icon: String
    let color: Color
    let value: String
    let unit: String
    
    var body: some View {
        HealthCard {
            VStack(spacing: Spacing.small) {
                HStack {
                    Image(systemName: icon)
                        .font(.title2)
                        .foregroundStyle(color)
                    
                    Spacer()
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.caption.weight(.medium))
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    HStack(alignment: .lastTextBaseline, spacing: 2) {
                        Text(value)
                            .font(.title2.weight(.semibold))
                            .foregroundStyle(.primary)
                        
                        Text(unit)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        
                        Spacer()
                    }
                }
            }
        }
        .aspectRatio(1.2, contentMode: .fit)
    }
}

private struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String
    let color: Color
    
    var body: some View {
        HealthCard {
            HStack(spacing: Spacing.medium) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundStyle(color)
                    .frame(width: 30)
                
                VStack(alignment: .leading, spacing: Spacing.xs) {
                    Text(title)
                        .font(.headline)
                        .foregroundStyle(.primary)
                    
                    Text(description)
                        .font(.body)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.leading)
                }
                
                Spacer()
            }
        }
    }
}

// MARK: - Preview
#Preview {
    NavigationStack {
        VitalsIntroductionScreen(viewModel: OnboardingViewModel())
    }
}
