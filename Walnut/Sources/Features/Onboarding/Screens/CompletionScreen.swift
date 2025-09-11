//
//  CompletionScreen.swift
//  Walnut
//
//  Created by Claude on 11/09/25.
//  Copyright © 2025 m. All rights reserved.
//

import SwiftUI
import SwiftData
import WalnutDesignSystem

/// Onboarding completion screen with celebration and summary
struct CompletionScreen: View {
     @Bindable var viewModel: OnboardingViewModel
    @Environment(\.modelContext) private var modelContext
    @State private var showingConfetti = false
    @State private var createdPatient: Patient?
    
    var body: some View {
        ScrollView {
            VStack(spacing: Spacing.xl) {
                Spacer()
                    .frame(height: Spacing.large)
                
                // Success Animation
                VStack(spacing: Spacing.large) {
                    ZStack {
                        Circle()
                            .fill(Color.healthSuccess.opacity(0.1))
                            .frame(width: 120, height: 120)
                        
                        Circle()
                            .fill(Color.healthSuccess.opacity(0.2))
                            .frame(width: 100, height: 100)
                        
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 60))
                            .foregroundStyle(Color.healthSuccess)
                    }
                    .scaleEffect(showingConfetti ? 1.0 : 0.8)
                    .animation(.spring(response: 0.6, dampingFraction: 0.8, blendDuration: 0), value: showingConfetti)
                    
                    VStack(spacing: Spacing.medium) {
                        Text("All Set!")
                            .font(.largeTitle.bold())
                            .foregroundStyle(.primary)
                        
                        Text("Your health journey starts now")
                            .font(.title3)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                    }
                }
                
                // Setup Summary
                VStack(spacing: Spacing.medium) {
                    Text("Setup Summary")
                        .font(.title3.bold())
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    HealthCard {
                        VStack(spacing: Spacing.medium) {
                            // Patient Info
                            SummaryRow(
                                icon: "person.circle.fill",
                                title: "Patient Profile",
                                value: viewModel.patientSetupData.name.isEmpty ? "Not set" : viewModel.patientSetupData.name
                            )
                            
                            Divider()
                            
                            // Emergency Contact
                            SummaryRow(
                                icon: "phone.circle.fill",
                                title: "Emergency Contact",
                                value: viewModel.healthProfile.emergencyContact?.name ?? "Not set"
                            )
                            
                            Divider()
                            
                            // Health Conditions
                            SummaryRow(
                                icon: "heart.circle.fill",
                                title: "Health Conditions",
                                value: viewModel.healthProfile.selectedConditions.isEmpty 
                                    ? "None selected" 
                                    : "\(viewModel.healthProfile.selectedConditions.count) selected"
                            )
                            
                            Divider()
                            
                            // Permissions
                            SummaryRow(
                                icon: "bell.circle.fill",
                                title: "Notifications",
                                value: viewModel.permissions.notifications == .granted ? "Enabled" : "Disabled"
                            )
                        }
                    }
                }
                
                // What's Next Section
                VStack(spacing: Spacing.medium) {
                    Text("What's Next?")
                        .font(.title3.bold())
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    VStack(spacing: Spacing.medium) {
                        NextStepCard(
                            icon: "plus.circle.fill",
                            title: "Add Your First Medication",
                            description: "Start tracking your medications and get reminders"
                        )
                        
                        NextStepCard(
                            icon: "chart.line.uptrend.xyaxis.circle.fill",
                            title: "Record Your First Vital Signs",
                            description: "Begin monitoring your health metrics"
                        )
                        
                        NextStepCard(
                            icon: "doc.text.fill",
                            title: "Upload Medical Documents",
                            description: "Store and organize your health records"
                        )
                    }
                }
                
                // Encouragement
                HealthCard {
                    VStack(spacing: Spacing.medium) {
                        HStack {
                            Image(systemName: "sparkles")
                                .font(.title)
                                .foregroundStyle(Color.healthPrimary)
                            
                            VStack(alignment: .leading, spacing: Spacing.xs) {
                                Text("You're in control of your health!")
                                    .font(.headline)
                                    .foregroundStyle(.primary)
                                
                                Text("Take it one step at a time. Every small action contributes to better health outcomes.")
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
        .onAppear {
            withAnimation(.easeInOut(duration: 0.5)) {
                showingConfetti = true
            }
            createPatientProfile()
        }
    }
    
    @MainActor
    private func createPatientProfile() {
        do {
            let patient = try viewModel.createPatient(modelContext: modelContext)
            createdPatient = patient
        } catch {
            print("Error creating patient: \(error)")
        }
    }
}

// MARK: - Supporting Views
private struct SummaryRow: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(Color.healthPrimary)
                .frame(width: 24)
            
            Text(title)
                .font(.body.weight(.medium))
                .foregroundStyle(.primary)
            
            Spacer()
            
            Text(value)
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.trailing)
        }
    }
}

private struct NextStepCard: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HealthCard {
            HStack(spacing: Spacing.medium) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundStyle(Color.healthPrimary)
                
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
                
                Image(systemName: "chevron.right")
                    .font(.body)
                    .foregroundStyle(.tertiary)
            }
        }
    }
}

// MARK: - Preview
#Preview {
    NavigationStack {
        CompletionScreen(viewModel: OnboardingViewModel())
            .modelContainer(for: Patient.self, inMemory: true)
    }
}
