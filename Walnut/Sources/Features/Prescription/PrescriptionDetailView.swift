//
//  PrescriptionDetailView.swift
//  Walnut
//
//  Created by Mayank Gandhi on 12/07/25.
//  Copyright © 2025 m. All rights reserved.
//

import SwiftUI
import SwiftData
import WalnutDesignSystem

struct PrescriptionDetailView: View {
    
    let patient: Patient
    @Bindable var prescription: Prescription
    @Environment(\.dismiss) private var dismiss
    
    @State var showEditor: Bool = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: Spacing.medium) {
                    // Enhanced Hero Header with Prescription Focus
                    enhancedHeaderCard
                    
                    // Medications Section - Most Important
                    if !(prescription.medications?.isEmpty ?? true) {
                        PrescriptionMedicationsCard(
                            medications: prescription.medications ?? []
                        )
                    }
                    
                    // Follow-up Section
                    if prescription.followUpDate != nil ||
                        prescription.followUpTests?.joined(separator: ", ") != "" {
                        enhancedFollowUpCard(
                            followUpTests: prescription.followUpTests ?? []
                        )
                    }
                    
                    // Clinical Notes Section
                    if let notes = prescription.notes,
                       !notes.isEmpty {
                        enhancedNotesCard(notes: notes)
                    }
                    
                    // Document Section
                    if prescription.document != nil {
                        DocumentCard(
                            document: prescription.document!,
                            title: "Prescription Document",
                            viewButtonText: "View Document"
                        )
                    }
                }
                .padding(.horizontal, Spacing.medium)
            }
            .sheet(isPresented: $showEditor) {
                if prescription.medicalCase == nil {
                    ContentUnavailableView(
                        "Unable to edit this prescription.",
                        systemImage: "exclamationmark.triangle.fill"
                    )
                } else {
                    PrescriptionEditor(
                        patient: patient,
                        prescription: prescription,
                        medicalCase: prescription.medicalCase!
                    )
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Menu("", systemImage: "ellipsis") {
                        Button {
                            showEditor = true
                        } label: {
                            Label("Edit", systemImage: "pencil")
                        }
                    }
                }
            }
            .navigationTitle(Text("Prescription"))
        }
    }
    
    // MARK: - Enhanced Header Card
    private var enhancedHeaderCard: some View {
        HealthCard {
            VStack(alignment: .leading, spacing: Spacing.medium) {
                // Hero Section with enhanced prescription visualization
                HStack(alignment: .center, spacing: Spacing.medium) {
                    // Enhanced Prescription Icon with animated background
                    ZStack {
                        // Animated background gradient
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color.healthSuccess.opacity(0.2),
                                        Color.healthSuccess.opacity(0.05)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 64, height: 64)
                            .shadow(color: Color.healthSuccess.opacity(0.3), radius: 8, x: 0, y: 4)
                        
                        // Subtle pulse ring
                        Circle()
                            .stroke(DocumentType.prescription.backgroundColor.opacity(0.2), lineWidth: 2)
                            .frame(width: 64, height: 64)
                        
                        // Main icon with enhanced styling
                        Image(DocumentType.prescription.iconImage)
                            .resizable()
                            .frame(width: 48, height: 48)
                            .scaleEffect(1.0)
                    }
                    
                    // Enhanced content with better hierarchy
                    VStack(alignment: .leading, spacing: Spacing.small) {
                        if let doctorName = prescription.doctorName {
                            Text("\(doctorName)")
                                .font(.headline.weight(.bold))
                                .foregroundStyle(.primary)
                                .lineLimit(2)
                                .multilineTextAlignment(.leading)
                        } else {
                            Text("Medical Prescription")
                                .font(.title.weight(.bold))
                                .foregroundStyle(.primary)
                        }
                        
                        if let facilityName = prescription.facilityName {
                            HStack(spacing: Spacing.xs) {
                                Circle()
                                    .fill(Color.blue.opacity(0.2))
                                    .frame(width: 20, height: 20)
                                    .overlay {
                                        Image(systemName: "building.2")
                                            .font(.caption2.weight(.regular))
                                            .foregroundStyle(.blue)
                                    }
                                
                                Text(facilityName)
                                    .font(.body.weight(.medium))
                                    .foregroundStyle(.secondary)
                            }
                        }
                        
                    }
                    
                }
                
                // Enhanced metadata section with modern card grid
                LazyVGrid(columns: [
                    GridItem(.flexible(), spacing: Spacing.small),
                    GridItem(.flexible(), spacing: Spacing.small)
                ], spacing: Spacing.medium) {
                    
                    // Issue Date Card
                    VStack(alignment: .leading, spacing: Spacing.xs) {
                        HStack {
                            Image(systemName: "calendar")
                                .font(.caption.weight(.medium))
                                .foregroundStyle(.blue)
                            
                            Text("Issued")
                                .font(.caption2.weight(.medium))
                                .foregroundStyle(.tertiary)
                            
                            Spacer()
                        }
                        if let dateIssued = prescription.dateIssued {
                            Text(dateIssued.formatted(date: .abbreviated, time: .omitted))
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(.secondary)
                        }
                    }
                    
                    // Follow-up Card
                    VStack(alignment: .leading, spacing: Spacing.xs) {
                        HStack {
                            Image(systemName: followUpIcon)
                                .font(.caption.weight(.medium))
                                .foregroundStyle(followUpColor)
                            
                            Text("Follow-up")
                                .font(.caption2.weight(.medium))
                                .foregroundStyle(.tertiary)
                            
                            Spacer()
                        }
                        
                        Text(followUpText)
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(followUpColor)
                    }
                    
                }
            }
        }
    }
    
    // MARK: - Enhanced Follow-up Card
    private func enhancedFollowUpCard(followUpTests: [String]) -> some View {
        VStack(alignment: .leading, spacing: Spacing.medium) {
            HealthCardHeader(
                icon: "calendar.badge.clock",
                iconColor: Color.healthWarning,
                title: "Follow-up Required",
                subtitle: prescription.followUpDate != nil ? "Due \(prescription.followUpDate!.formatted(date: .abbreviated, time: .omitted))" : nil,
            )
            
            
                HealthCard {
                    VStack(alignment: .leading, spacing: Spacing.small) {
                        Text("Required Tests:")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.primary)
                        
                        ForEach(followUpTests.indices, id: \.self) { index in
                            HStack(spacing: Spacing.small) {
                                Circle()
                                    .fill(Color.healthWarning)
                                    .frame(width: 6, height: 6)
                                
                                Text(followUpTests[index])
                                    .font(.subheadline)
                                    .foregroundStyle(.primary)
                                
                                Spacer()
                            }
                        }
                    }
                }
            
        }
    }
    
    
    // MARK: - Enhanced Notes Card
    private func enhancedNotesCard(notes: String) -> some View {
        VStack(alignment: .leading, spacing: Spacing.medium) {
            HealthCardHeader.clinicalNotes()
            HealthCard {
                Text(notes)
                    .font(.subheadline)
                    .lineSpacing(4)
                    .foregroundStyle(.primary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }
    
    // MARK: - Computed Properties
    
    private var followUpIcon: String {
        if prescription.followUpDate != nil {
            return "calendar.badge.clock"
        } else {
            return "checkmark.circle"
        }
    }
    
    private var followUpColor: Color {
        if prescription.followUpDate != nil {
            return .healthWarning
        } else {
            return .healthSuccess
        }
    }
    
    private var followUpText: String {
        if let followUpDate = prescription.followUpDate {
            let daysUntil = Calendar.current.dateComponents([.day], from: Date(), to: followUpDate).day ?? 0
            if daysUntil > 0 {
                return "In \(daysUntil) days"
            } else if daysUntil == 0 {
                return "Today"
            } else {
                return "Overdue"
            }
        } else {
            return "No follow-up"
        }
    }
    
}

// MARK: - Comprehensive Preview

#Preview("Complete Prescription") {
    PrescriptionDetailView(
        patient: .samplePatient,
        prescription: .samplePrescription(for: .sampleCase)
    )
        .modelContainer(for: Prescription.self, inMemory: true)
}

