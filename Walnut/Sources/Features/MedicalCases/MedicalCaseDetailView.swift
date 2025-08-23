//
//  MedicalCaseDetailView.swift
//  Walnut-Playground
//
//  Created by Mayank Gandhi on 02/07/25.
//  Copyright © 2025 m. All rights reserved.
//

import SwiftUI
import WalnutDesignSystem

struct MedicalCaseDetailView: View {
    
    let medicalCase: MedicalCase
    @State private var headerScale: CGFloat = 1.0
    @State private var showQuickActions = false
    @Namespace private var heroTransition
    
    var body: some View {
        ScrollView {
            VStack(spacing: Spacing.large) {
                // Modern Hero Header
                heroSection
                
                // Case Overview Cards
                overviewCardsSection
                
                // Clinical Notes Section
                if !medicalCase.notes.isEmpty {
                    clinicalNotesSection
                }
                
                // Case Timeline Section
                MedicalCaseTimeline(medicalCase: medicalCase)
                
                // Unified Documents Section (unchanged)
                UnifiedDocumentsSection(medicalCase: medicalCase)
            }
            .padding(.horizontal, Spacing.medium)
            .padding(.vertical, Spacing.small)
        }
        .background(Color(UIColor.systemGroupedBackground))
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Hero Section

private extension MedicalCaseDetailView {
    
    var heroSection: some View {
        HealthCard(padding: Spacing.large) {
            HStack(spacing: Spacing.medium) {
                // Specialty Icon with Modern Design
                ZStack {
                    // Background circle with gradient
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    medicalCase.specialty.color.opacity(0.15),
                                    medicalCase.specialty.color.opacity(0.05)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 72, height: 72)
                    
                    // Animated pulse ring
                    Circle()
                        .stroke(medicalCase.specialty.color.opacity(0.3), lineWidth: 1.5)
                        .frame(width: 80, height: 80)
                        .scaleEffect(headerScale)
                        .animation(.easeInOut(duration: 2.5).repeatForever(autoreverses: true), value: headerScale)
                        .onAppear { headerScale = 1.05 }
                    
                    // Specialty icon
                    Image(systemName: medicalCase.specialty.icon)
                        .font(.system(size: 28, weight: .medium, design: .rounded))
                        .foregroundStyle(medicalCase.specialty.color)
                }
                .matchedGeometryEffect(id: "specialty-icon", in: heroTransition)
                
                // Content Section
                VStack(alignment: .leading, spacing: Spacing.xs) {
                    // Title
                    Text(medicalCase.title)
                        .font(.title2.weight(.bold))
                        .foregroundStyle(.primary)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                    
                    // Patient Info
                    HStack(spacing: Spacing.xs) {
                        PatientAvatar(
                            initials: String(medicalCase.patient.fullName.prefix(2)),
                            color: medicalCase.specialty.color,
                            size: 20
                        )
                        
                        Text(medicalCase.patient.fullName)
                            .font(.callout.weight(.medium))
                            .foregroundStyle(.secondary)
                    }
                    
                    // Status Badge
                    HStack(spacing: Spacing.xs) {
                        WalnutDesignSystem.StatusIndicator(
                            status: medicalCase.isActive ? .good : .warning,
                            showIcon: false
                        )
                        
                        Text(medicalCase.isActive ? "Active Treatment" : "Case Closed")
                            .font(.caption.weight(.medium))
                            .foregroundStyle(medicalCase.isActive ? Color.healthSuccess : Color.healthWarning)
                    }
                    .padding(.horizontal, Spacing.small)
                    .padding(.vertical, 4)
                    .background(
                        (medicalCase.isActive ? Color.healthSuccess : Color.healthWarning).opacity(0.1),
                        in: Capsule()
                    )
                }
                
                Spacer()
            }
        }
    }
}

// MARK: - Overview Cards Section

private extension MedicalCaseDetailView {
    
    var overviewCardsSection: some View {
        LazyVGrid(
            columns: [
                GridItem(.flexible(), spacing: Spacing.small),
                GridItem(.flexible(), spacing: Spacing.small)
            ],
            spacing: Spacing.small
        ) {
            // Case Type Card
            caseTypeCard
            
            // Date Card
            dateCard
            
            // Specialty Card
            specialtyCard
            
            // Status Card
            statusCard
        }
    }
    
    var caseTypeCard: some View {
        HealthCard(padding: Spacing.medium) {
            VStack(alignment: .leading, spacing: Spacing.xs) {
                HStack {
                    Image(systemName: "folder.badge")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(medicalCase.type.foregroundColor)
                    
                    Text("Type")
                        .font(.caption.weight(.medium))
                        .foregroundStyle(.tertiary)
                    
                    Spacer()
                }
                
                Text(medicalCase.type.displayName)
                    .font(.callout.weight(.semibold))
                    .foregroundStyle(.primary)
                    .lineLimit(1)
            }
        }
    }
    
    var dateCard: some View {
        HealthCard(padding: Spacing.medium) {
            VStack(alignment: .leading, spacing: Spacing.xs) {
                HStack {
                    Image(systemName: "calendar")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(Color.healthPrimary)
                    
                    Text("Created")
                        .font(.caption.weight(.medium))
                        .foregroundStyle(.tertiary)
                    
                    Spacer()
                }
                
                Text(medicalCase.createdAt.formatted(date: .abbreviated, time: .omitted))
                    .font(.callout.weight(.semibold))
                    .foregroundStyle(.primary)
                    .lineLimit(1)
            }
        }
    }
    
    var specialtyCard: some View {
        HealthCard(padding: Spacing.medium) {
            VStack(alignment: .leading, spacing: Spacing.xs) {
                HStack {
                    Image(systemName: "stethoscope")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(medicalCase.specialty.color)
                    
                    Text("Specialty")
                        .font(.caption.weight(.medium))
                        .foregroundStyle(.tertiary)
                    
                    Spacer()
                }
                
                Text(medicalCase.specialty.rawValue)
                    .font(.callout.weight(.semibold))
                    .foregroundStyle(.primary)
                    .lineLimit(1)
            }
        }
    }
    
    var statusCard: some View {
        HealthCard(padding: Spacing.medium) {
            VStack(alignment: .leading, spacing: Spacing.xs) {
                HStack {
                    Image(systemName: "heart.text.square")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(Color.healthSuccess)
                    
                    Text("Priority")
                        .font(.caption.weight(.medium))
                        .foregroundStyle(.tertiary)
                    
                    Spacer()
                }
                
               
            }
        }
    }
}

// MARK: - Clinical Notes Section

private extension MedicalCaseDetailView {
    
    var clinicalNotesSection: some View {
        HealthCard(padding: Spacing.large) {
            VStack(alignment: .leading, spacing: Spacing.medium) {
                // Section Header
                HStack(spacing: Spacing.small) {
                    ZStack {
                        Circle()
                            .fill(Color.healthSuccess.opacity(0.15))
                            .frame(width: 36, height: 36)
                        
                        Image(systemName: "note.text")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundStyle(Color.healthSuccess)
                    }
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Clinical Notes")
                            .font(.headline.weight(.semibold))
                            .foregroundStyle(.primary)
                        
                        Text("\(medicalCase.notes.count) characters")
                            .font(.caption2)
                            .foregroundStyle(.tertiary)
                    }
                    
                    Spacer()
                }
                
                // Notes Content
                Text(medicalCase.notes)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(nil)
                    .multilineTextAlignment(.leading)
            }
        }
    }
}


#Preview(body: {
    MedicalCaseDetailView(
        medicalCase: MedicalCase.sampleCase
    )
})
