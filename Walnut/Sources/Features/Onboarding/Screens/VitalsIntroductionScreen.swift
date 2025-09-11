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
        ScrollView {
            VStack(spacing: Spacing.xl) {
                // Header
                VStack(spacing: Spacing.medium) {
                    Image(systemName: "heart.text.square.fill")
                        .font(.system(size: 50))
                        .foregroundStyle(Color.healthPrimary)
                    
                    Text("Vitals Tracking")
                        .font(.largeTitle.bold())
                    
                    Text("Track your vital signs and health metrics with ease")
                        .font(.body)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, Spacing.medium)
                }
                .padding(.top, Spacing.large)
                
                // Featured Vitals
                VStack(spacing: Spacing.medium) {
                    Text("Monitor Your Health")
                        .font(.title3.bold())
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: Spacing.medium), count: 2), spacing: Spacing.medium) {
                        VitalCard(
                            title: "Blood Pressure",
                            icon: "heart.circle.fill",
                            color: .heartRate,
                            value: "120/80",
                            unit: "mmHg"
                        )
                        
                        VitalCard(
                            title: "Heart Rate",
                            icon: "heart.fill",
                            color: .red,
                            value: "72",
                            unit: "bpm"
                        )
                        
                        VitalCard(
                            title: "Blood Glucose",
                            icon: "drop.circle.fill",
                            color: .glucose,
                            value: "95",
                            unit: "mg/dL"
                        )
                        
                        VitalCard(
                            title: "Weight",
                            icon: "scalemass.fill",
                            color: .healthPrimary,
                            value: "165",
                            unit: "lbs"
                        )
                        
                        VitalCard(
                            title: "Temperature",
                            icon: "thermometer",
                            color: .orange,
                            value: "98.6",
                            unit: "°F"
                        )
                        
                        VitalCard(
                            title: "Oxygen Sat",
                            icon: "lungs.fill",
                            color: .cyan,
                            value: "98",
                            unit: "%"
                        )
                    }
                }
                
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
                
                // Health Integration
                HealthCard {
                    VStack(spacing: Spacing.medium) {
                        HStack {
                            Image(systemName: "heart.text.square")
                                .font(.title)
                                .foregroundStyle(Color.healthPrimary)
                            
                            VStack(alignment: .leading, spacing: Spacing.xs) {
                                Text("Apple Health Integration")
                                    .font(.headline)
                                    .foregroundStyle(.primary)
                                
                                Text("Automatically sync with Apple Health for a complete picture of your wellness journey.")
                                    .font(.body)
                                    .foregroundStyle(.secondary)
                            }
                            
                            Spacer()
                        }
                    }
                }
                
                Spacer()
                    .frame(height: Spacing.xl)
            }
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
