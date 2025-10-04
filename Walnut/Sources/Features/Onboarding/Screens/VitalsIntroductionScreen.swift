//
//  VitalsIntroductionScreen.swift
//  Walnut
//
//  Created by Claude on 11/09/25.
//  Copyright © 2025 m. All rights reserved.
//

import SwiftUI
import WalnutDesignSystem

/// Personal health journal introduction screen showcasing wellness tracking features
struct VitalsIntroductionScreen: View {
    @Bindable var viewModel: OnboardingViewModel

    var body: some View {
        VStack(spacing: Spacing.xl) {

            OnboardingHeader(icon: "book.fill", title: "Your Health Journal", subtitle: "Document your wellness journey and track what matters to you")


            // Features Section
            VStack(spacing: Spacing.medium) {
                Text("Powerful Features")
                    .font(.title3.bold())
                    .frame(maxWidth: .infinity, alignment: .leading)

                VStack(spacing: Spacing.medium) {
                    FeatureRow(
                        icon: "chart.line.uptrend.xyaxis",
                        title: "Track Progress",
                        description: "Visualize your wellness trends over time with beautiful charts",
                        color: Color.healthPrimary
                    )

                    FeatureRow(
                        icon: "bell.fill",
                        title: "Daily Reminders",
                        description: "Build healthy habits with gentle reminders",
                        color: Color.healthWarning
                    )

                    FeatureRow(
                        icon: "square.and.arrow.up",
                        title: "Export & Share",
                        description: "Export your journal entries whenever you need them",
                        color: Color.healthSuccess
                    )

                    FeatureRow(
                        icon: "target",
                        title: "Personal Goals",
                        description: "Set wellness goals and celebrate your achievements",
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
