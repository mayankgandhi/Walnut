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
    
    var body: some View {
        ScrollView {
            VStack(spacing: Spacing.medium) {
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
    }
    
    var heroSection: some View {
        HealthCard {
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
                    
                    // Specialty icon
                    Image(systemName: medicalCase.specialty.icon)
                        .font(.system(size: 28, weight: .medium, design: .rounded))
                        .foregroundStyle(medicalCase.specialty.color)
                }
                
                // Content Section
                VStack(alignment: .leading, spacing: Spacing.small) {
                    // Title
                    Text(medicalCase.title)
                        .font(.title2.weight(.bold))
                        .foregroundStyle(.primary)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                    
                    // Patient Info
                    HStack {
                        PatientAvatar(
                            initials: String(medicalCase.patient.fullName.prefix(2)),
                            color: medicalCase.specialty.color,
                            size: 20
                        )
                        
                        Text(medicalCase.patient.fullName)
                            .font(.callout.weight(.medium))
                            .foregroundStyle(.primary)
                    }
                    
                    HStack {
                        Image(systemName: "stethoscope")
                            .font(.callout.weight(.medium))
                            .foregroundStyle(medicalCase.specialty.color)
                        Text(medicalCase.specialty.rawValue)
                            .font(.callout.weight(.medium))
                            .foregroundStyle(.primary)
                            .lineLimit(1)
                    }
                                        
                    Text(medicalCase.isActive ? "Active Treatment" : "Case Closed")
                        .font(.caption.weight(.medium))
                        .foregroundStyle(medicalCase.isActive ? Color.healthSuccess : Color.healthWarning)
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

        }
    }
    
    var caseTypeCard: some View {
        HealthCard {
            VStack(alignment: .leading, spacing: Spacing.xs) {
                HStack {
                    Image(systemName: "folder")
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
        HealthCard {
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
    
    
}

// MARK: - Clinical Notes Section

private extension MedicalCaseDetailView {
    
    var clinicalNotesSection: some View {
        HealthCard {
            VStack(alignment: .leading, spacing: Spacing.medium) {
                HealthCardHeader.clinicalNotes()
                
                // Notes Content
                Text(medicalCase.notes)
                    .font(.body)
                    .foregroundStyle(.primary)
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
