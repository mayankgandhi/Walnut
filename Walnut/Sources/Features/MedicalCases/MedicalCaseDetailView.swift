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
            VStack(spacing: Spacing.large) {
                // Modern Hero Header
                heroSection
                
                // Case Overview Cards
                overviewCardsSection
                
                // Clinical Notes Section
                if let notes = medicalCase.notes,
                    !notes.isEmpty {
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
                OptionalView(medicalCase.specialty) { specialty in
                    ZStack {
                        // Background circle with gradient
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        specialty.color.opacity(0.15),
                                        specialty.color.opacity(0.05)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 72, height: 72)
                        
                        // Animated pulse ring
                        Circle()
                            .stroke(specialty.color.opacity(0.3), lineWidth: 1.5)
                            .frame(width: 80, height: 80)
                        
                        // Specialty icon
                        Image(systemName: specialty.icon)
                            .font(.system(size: 28, weight: .medium, design: .rounded))
                            .foregroundStyle(specialty.color)
                    }
                }
                
                // Content Section
                VStack(alignment: .leading, spacing: Spacing.small) {
                    // Title
                    Text(medicalCase.title ?? "Medical Case")
                        .font(.title2.weight(.bold))
                        .foregroundStyle(.primary)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                    
                    // Patient Info
                    HStack {
                        if let fullName = medicalCase.patient?.fullName,
                           let specialty = medicalCase.specialty {
                            PatientAvatar(
                                initials: String(fullName.prefix(2)),
                                color: specialty.color
                            )
                        }
                        
                        if let fullName = medicalCase.patient?.fullName {
                            Text(fullName ?? "Patient")
                                .font(.callout.weight(.medium))
                                .foregroundStyle(.primary)
                        }
                    }
                    
                    OptionalView(medicalCase.specialty) { specialty in
                        HStack {
                            Image(systemName: "stethoscope")
                                .font(.callout.weight(.medium))
                                .foregroundStyle(specialty.color)
                            Text(specialty.rawValue)
                                .font(.callout.weight(.medium))
                                .foregroundStyle(.primary)
                                .lineLimit(1)
                        }
                    }
                    
                    OptionalView(medicalCase.isActive) { isActive in
                        Text(isActive ? "Active Treatment" : "Case Closed")
                            .font(.caption.weight(.medium))
                            .foregroundStyle(isActive ? Color.healthSuccess : Color.healthWarning)
                            .padding(.horizontal, Spacing.small)
                            .padding(.vertical, 4)
                            .background(
                                (isActive ? Color.healthSuccess : Color.healthWarning).opacity(0.1),
                                in: Capsule()
                            )
                    }
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
        OptionalView(medicalCase.type) { type in
            HealthCard {
                VStack(alignment: .leading, spacing: Spacing.xs) {
                    HStack {
                        Image(systemName: "folder")
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(type.foregroundColor)
                        
                        Text("Type")
                            .font(.caption.weight(.medium))
                            .foregroundStyle(.tertiary)
                        
                        Spacer()
                    }
                    
                    Text(type.displayName)
                        .font(.callout.weight(.semibold))
                        .foregroundStyle(.primary)
                        .lineLimit(1)
                }
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
                OptionalView(medicalCase.createdAt) { createdAt in
                    Text(createdAt.formatted(date: .abbreviated, time: .omitted))
                        .font(.callout.weight(.semibold))
                        .foregroundStyle(.primary)
                        .lineLimit(1)
                }
                
            }
        }
    }
 
    var clinicalNotesSection: some View {
        OptionalView(medicalCase.notes) { notes in
            VStack(alignment: .leading, spacing: Spacing.medium) {
                HealthCardHeader.clinicalNotes()
                HealthCard {
                    Text(notes)
                        .font(.body)
                        .foregroundStyle(.primary)
                        .lineLimit(nil)
                        .multilineTextAlignment(.leading)
                }
            }
        }
    }
    
}

#Preview(body: {
    MedicalCaseDetailView(
        medicalCase: MedicalCase.sampleCase
    )
})
