//
//  HealthProfileScreen.swift
//  Walnut
//
//  Created by Claude on 11/09/25.
//  Copyright © 2025 m. All rights reserved.
//

import SwiftUI
import WalnutDesignSystem

/// Health profile setup screen for chronic conditions and emergency contacts
struct HealthProfileScreen: View {
    
    @Bindable var viewModel: OnboardingViewModel
    
    var body: some View {
        
        VStack(spacing: Spacing.xl) {
            
            OnboardingHeader(icon: "heart.circle.fill", title: "Health Profile", subtitle: "Tell us about your health conditions and emergency contacts")
            
            // Chronic Conditions Section
            VStack(spacing: Spacing.medium) {
            
                SectionHeader(
                    title: "Chronic Conditions",
                    subtitle: "Select any that apply (optional)"
                )
                
                LazyVGrid(
                    columns: Array(repeating: .init(), count: 2),
                    spacing: Spacing.small
                ) {
                    ForEach(ChronicCondition.allCases, id: \.self) { condition in
                        ConditionTile(
                            condition: condition,
                            isSelected: viewModel.healthProfile.selectedConditions.contains(condition)
                        ) {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                viewModel.toggleChronicCondition(condition)
                            }
                        }
                    }
                }
                
            }
            
            
            Spacer()
                .frame(height: Spacing.xl)
        }
        .padding(.horizontal, Spacing.large)
        .onAppear {
            AnalyticsService.shared.track(.app(.featureUsed))
        }
    }
    
    
}

// MARK: - Supporting Views
private struct SectionHeader: View {
    let title: String
    let subtitle: String
    
    var body: some View {
        VStack(spacing: Spacing.xs) {
            HStack {
                Text(title)
                    .font(.headline.bold())
                    .foregroundStyle(.primary)
                Spacer()
            }
            
            HStack {
                Text(subtitle)
                    .font(.body)
                    .foregroundStyle(.secondary)
                Spacer()
            }
        }
    }
}

private struct ConditionTile: View {
    
    let condition: ChronicCondition
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: Spacing.small) {
                Image(condition.specialty.icon)
                    .resizable()
                    .frame(width: 32, height: 32)
                    .foregroundStyle(isSelected ? .white : .healthPrimary)
                
                Text(condition.rawValue)
                    .font(.headline.weight(.medium))
                    .foregroundStyle(.primary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.vertical, Spacing.small)
            .padding(.horizontal, Spacing.small)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(
                        isSelected ? Color.healthPrimary.opacity(0.4) : .clear
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.healthPrimary.opacity(1.0) : Color.healthPrimary.opacity(0.1), lineWidth: 2)
            )
            .animation(.easeInOut(duration: 0.2), value: isSelected)
            .contentShape(.rect)
        }
        .buttonStyle(.plain)
    }
    
}

// MARK: - Preview
#Preview {
    NavigationStack {
        HealthProfileScreen(viewModel: OnboardingViewModel())
    }
}
