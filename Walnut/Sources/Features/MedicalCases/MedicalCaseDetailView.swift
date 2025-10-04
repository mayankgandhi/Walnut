//
//  MedicalCaseDetailView.swift
//  Walnut-Playground
//
//  Created by Mayank Gandhi on 02/07/25.
//  Copyright © 2025 m. All rights reserved.
//

import SwiftUI
import SwiftData
import WalnutDesignSystem

struct MedicalCaseDetailView: View {
    
    @Environment(\.modelContext) var modelContext
    @Query private var medicalCases: [MedicalCase]
    private let patient: Patient
    
    private var medicalCase: MedicalCase? {
        medicalCases.first
    }
    
    init(patient: Patient, medicalCase: MedicalCase) {
        self.patient = patient
        let id = medicalCase.id
        _medicalCases = Query(
            filter: #Predicate<MedicalCase> { $0.id == id },
            sort: \MedicalCase.updatedAt
        )
    }
    
    var body: some View {
        Group {
            if let medicalCase = medicalCase {
                ScrollView {
                    VStack(spacing: Spacing.medium) {
                        // Modern Hero Header
                        heroSection
                        
                        // Clinical Notes Section
                        if let notes = medicalCase.notes,
                           !notes.isEmpty {
                            clinicalNotesSection
                        }
                        
                        // Case Timeline Section
                        MedicalCaseTimeline(medicalCase: medicalCase)
                        
                        // Unified Documents Section (unchanged)
                        UnifiedDocumentsSection(
                            patient: patient,
                            medicalCase: medicalCase
                        )
                    }
                    .padding(.horizontal, Spacing.medium)
                    .padding(.vertical, Spacing.small)
                }
            } else {
                // Handle case where medical case might be deleted or not found
                ContentUnavailableView(
                    "Case Not Found",
                    systemImage: "exclamationmark.triangle",
                    description: Text("The medical case may have been deleted or is no longer available.")
                )
            }
        }
    }
    
    var heroSection: some View {
        Group {
            if let medicalCase = medicalCase {
                HealthCard {
                    VStack(alignment: .leading, spacing: Spacing.medium) {
                        HStack(spacing: Spacing.medium) {
                            // Specialty Icon with Modern Design
                            OptionalView(medicalCase.specialty) { specialty in
                                Image(specialty.icon)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 96, height: 96, alignment: .center)
                            }
                            
                            // Content Section
                            VStack(alignment: .leading, spacing: Spacing.small) {
                                // Title
                                Text(medicalCase.title ?? "Medical Case")
                                    .font(.title2.weight(.bold))
                                    .foregroundStyle(.primary)
                                    .lineLimit(2)
                                    .multilineTextAlignment(.leading)
                                
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
                        
                        HStack(alignment: .center, spacing: Spacing.medium) {
                            if let type = medicalCase.type {
                                // Case Type Card
                                caseTypeCard(type: type)
                            }
                            
                            if let createdAt = medicalCase.createdAt {
                                dateCard(createdAt: createdAt)
                            }
                        }
                    }
                }
            }
        }
    }
    
    
    func caseTypeCard(type: MedicalCaseType) -> some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            HStack {
                Image(systemName: "folder")
                    .font(.caption2.weight(.medium))
                
                Text("Type")
                    .font(.caption2.weight(.medium))
                    .foregroundStyle(.tertiary)
                
                Spacer()
            }
            
            Text(type.displayName)
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
                .lineLimit(1)
        }
    }
    
    
    func dateCard(createdAt: Date) -> some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            HStack {
                Image(systemName: "calendar")
                    .font(.caption2.weight(.medium))
                    .foregroundStyle(Color.healthPrimary)
                
                Text("Created")
                    .font(.caption2.weight(.medium))
                    .foregroundStyle(.tertiary)
                
                Spacer()
            }
            Text(createdAt.formatted(date: .abbreviated, time: .omitted))
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
                .lineLimit(1)
        }
    }
    
    var clinicalNotesSection: some View {
        Group {
            if let medicalCase = medicalCase {
                OptionalView(medicalCase.notes) { notes in
                    VStack(alignment: .leading, spacing: Spacing.medium) {
                        HealthCardHeader.clinicalNotes()
                        HealthCard {
                            Text(notes)
                                .font(
                                    .system(
                                        .body,
                                        design: .rounded,
                                        weight: .regular
                                    )
                                )
                                .foregroundStyle(.primary)
                                .lineLimit(nil)
                                .multilineTextAlignment(.leading)
                        }
                    }
                }
            }
        }
    }
    
}

#Preview {
    do {
        let container = try ModelContainer(for: Patient.self, MedicalCase.self, Prescription.self, BioMarkerReport.self, Document.self)
        let context = ModelContext(container)
        
        // Insert sample data
        let samplePatient = Patient.samplePatient
        let sampleCase = MedicalCase.sampleCase
        sampleCase.patient = samplePatient
        
        context.insert(samplePatient)
        context.insert(sampleCase)
        try context.save()
        
        return NavigationStack {
            MedicalCaseDetailView(patient: .samplePatient, medicalCase: sampleCase)
                .modelContainer(container)
        }
    } catch {
        return Text("Failed to create preview: \(error.localizedDescription)")
    }
}
