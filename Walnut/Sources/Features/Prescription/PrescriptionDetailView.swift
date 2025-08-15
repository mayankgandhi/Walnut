//
//  PrescriptionDetailView.swift
//  Walnut
//
//  Created by Mayank Gandhi on 12/07/25.
//  Copyright © 2025 m. All rights reserved.
//

import SwiftUI
import WalnutDesignSystem

struct PrescriptionDetailView: View {
    
    let prescription: Prescription
    
    @Environment(\.dismiss) private var dismiss
    @State private var showingMedicationEditor = false
    @State private var showingDocumentViewer = false
    @State private var documentToView: Document?
    @State private var headerScale: CGFloat = 1.0
    @Namespace private var heroTransition
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Spacing.large) {
                    // Enhanced Hero Header with Prescription Focus
                    enhancedHeaderCard
                    
                    // Enhanced Content Sections
                    VStack(spacing: Spacing.large) {
                        // Medications Section - Most Important
                        if !prescription.medications.isEmpty {
                            PrescriptionMedicationsCard(medications: prescription.medications)
                        }
                        
                        // Follow-up Section
                        if prescription.followUpDate != nil || !(prescription.followUpTests?.isEmpty ?? false) {
                            enhancedFollowUpCard
                        }
                        
                        // Clinical Notes Section
                        if let notes = prescription.notes, !notes.isEmpty {
                            enhancedNotesCard
                        }
                        
                        // Document Section
                        if prescription.document != nil {
                            enhancedDocumentCard
                        }
                        
                        // Metadata Section
                        enhancedMetadataCard
                    }
                }
                .padding(.horizontal, Spacing.medium)
                .padding(.top, Spacing.small)
                .padding(.bottom, Spacing.xl)
            }
            .background(Color(UIColor.systemGroupedBackground))
            .navigationTitle("Prescription")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .font(.system(size: 16, weight: .semibold))
                }
            }
            .sheet(isPresented: $showingMedicationEditor) {
                PrescriptionMedicationEditor(prescription: prescription)
            }
            .fullScreenCover(isPresented: $showingDocumentViewer) {
                if let document = documentToView {
                    DocumentViewerSheet(document: document)
                }
            }
        }
    }
    
    // MARK: - Enhanced Header Card
    private var enhancedHeaderCard: some View {
        HealthCard(padding: Spacing.large) {
            VStack(spacing: Spacing.large) {
                // Hero Section with enhanced prescription visualization
                HStack(spacing: Spacing.large) {
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
                            .frame(width: 80, height: 80)
                            .shadow(color: Color.healthSuccess.opacity(0.3), radius: 8, x: 0, y: 4)
                        
                        // Subtle pulse ring
                        Circle()
                            .stroke(Color.healthSuccess.opacity(0.2), lineWidth: 2)
                            .frame(width: 88, height: 88)
                            .scaleEffect(headerScale)
                            .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true), value: headerScale)
                            .onAppear { headerScale = 1.1 }
                        
                        // Main icon with enhanced styling
                        Image(systemName: "cross.fill")
                            .font(.system(size: 32, weight: .semibold, design: .rounded))
                            .foregroundStyle(Color.healthSuccess)
                            .scaleEffect(1.0)
                            .animation(.spring(response: 0.6, dampingFraction: 0.8), value: prescription.dateIssued)
                    }
                    .matchedGeometryEffect(id: "prescription-icon", in: heroTransition)
                    
                    // Enhanced content with better hierarchy
                    VStack(alignment: .leading, spacing: Spacing.small) {
                        if let doctorName = prescription.doctorName {
                            Text("Dr. \(doctorName)")
                                .font(.title.weight(.bold))
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
                                            .font(.caption2.weight(.medium))
                                            .foregroundStyle(.blue)
                                    }
                                
                                Text(facilityName)
                                    .font(.subheadline.weight(.medium))
                                    .foregroundStyle(.secondary)
                            }
                        }
                        
                        // Enhanced status with medication count
                        HStack(spacing: Spacing.xs) {
                            Circle()
                                .fill(Color.healthSuccess)
                                .frame(width: 8, height: 8)
                                .scaleEffect(prescription.medications.isEmpty ? 0.8 : 1.0)
                                .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: prescription.medications.isEmpty)
                            
                            Text("\(prescription.medications.count) Medications Prescribed")
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(Color.healthSuccess)
                        }
                    }
                    
                    Spacer()
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
                        
                        Text(prescription.dateIssued.formatted(date: .abbreviated, time: .omitted))
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.secondary)
                    }
                    .padding(Spacing.small)
                    .background(Color(UIColor.secondarySystemGroupedBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    
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
                    .padding(Spacing.small)
                    .background(Color(UIColor.secondarySystemGroupedBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                }
            }
        }
    }
    
    // MARK: - Enhanced Follow-up Card
    private var enhancedFollowUpCard: some View {
        HealthCard {
            VStack(alignment: .leading, spacing: Spacing.medium) {
                HStack(spacing: Spacing.small) {
                    Circle()
                        .fill(Color.healthWarning.opacity(0.2))
                        .frame(width: 36, height: 36)
                        .overlay {
                            Image(systemName: "calendar.badge.clock")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundStyle(Color.healthWarning)
                        }
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Follow-up Required")
                            .font(.headline.weight(.bold))
                            .foregroundStyle(.primary)
                        
                        if let followUpDate = prescription.followUpDate {
                            Text("Due \(followUpDate.formatted(date: .abbreviated, time: .omitted))")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                    
                    Spacer()
                }
                
                if let followUpTests = prescription.followUpTests, !followUpTests.isEmpty {
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
                                    .foregroundStyle(.secondary)
                                
                                Spacer()
                            }
                        }
                    }
                    .padding(Spacing.small)
                    .background(Color.healthWarning.opacity(0.05))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.healthWarning.opacity(0.1), lineWidth: 1)
                    )
                }
            }
        }
    }
    
    // MARK: - Enhanced Notes Card
    private var enhancedNotesCard: some View {
        HealthCard {
            VStack(alignment: .leading, spacing: Spacing.medium) {
                HStack(spacing: Spacing.small) {
                    Circle()
                        .fill(Color.healthPrimary.opacity(0.2))
                        .frame(width: 36, height: 36)
                        .overlay {
                            Image(systemName: "note.text")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundStyle(Color.healthPrimary)
                        }
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Clinical Notes")
                            .font(.headline.weight(.bold))
                            .foregroundStyle(.primary)
                        
                        if let notes = prescription.notes {
                            Text("\(notes.count) characters")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                    
                    Spacer()
                }
                
                if let notes = prescription.notes {
                    Text(notes)
                        .font(.subheadline)
                        .lineSpacing(4)
                        .foregroundStyle(.primary)
                        .padding(Spacing.small)
                        .background(Color.healthPrimary.opacity(0.05))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.healthPrimary.opacity(0.1), lineWidth: 1)
                        )
                }
            }
        }
    }
    
    // MARK: - Enhanced Document Card
    private var enhancedDocumentCard: some View {
        HealthCard {
            VStack(alignment: .leading, spacing: Spacing.medium) {
                HStack(spacing: Spacing.small) {
                    Circle()
                        .fill(Color.blue.opacity(0.2))
                        .frame(width: 36, height: 36)
                        .overlay {
                            Image(systemName: "doc.text.fill")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundStyle(.blue)
                        }
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Prescription Document")
                            .font(.headline.weight(.bold))
                            .foregroundStyle(.primary)
                        
                        if let document = prescription.document {
                            Text(document.fileName)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .lineLimit(1)
                        }
                    }
                    
                    Spacer()
                }
                
                if let document = prescription.document {
                    HStack(spacing: Spacing.medium) {
                        Button(action: {
                            documentToView = document
                            showingDocumentViewer = true
                        }) {
                            HStack(spacing: Spacing.xs) {
                                Image(systemName: "eye.fill")
                                    .font(.caption)
                                Text("View Document")
                                    .font(.caption.weight(.medium))
                            }
                            .foregroundStyle(.white)
                            .padding(.horizontal, Spacing.medium)
                            .padding(.vertical, Spacing.small)
                            .background(.blue)
                            .clipShape(Capsule())
                        }
                        
                        Button(action: {
                            let activityController = UIActivityViewController(activityItems: [document.fileURL], applicationActivities: nil)
                            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                               let rootViewController = windowScene.windows.first?.rootViewController {
                                rootViewController.present(activityController, animated: true)
                            }
                        }) {
                            HStack(spacing: Spacing.xs) {
                                Image(systemName: "square.and.arrow.up")
                                    .font(.caption)
                                Text("Share")
                                    .font(.caption.weight(.medium))
                            }
                            .foregroundStyle(.blue)
                            .padding(.horizontal, Spacing.medium)
                            .padding(.vertical, Spacing.small)
                            .background(Color.blue.opacity(0.1))
                            .clipShape(Capsule())
                        }
                        
                        Spacer()
                    }
                }
            }
        }
    }
    
    // MARK: - Enhanced Metadata Card
    private var enhancedMetadataCard: some View {
        HealthCard {
            VStack(alignment: .leading, spacing: Spacing.medium) {
                HStack(spacing: Spacing.small) {
                    Circle()
                        .fill(Color.purple.opacity(0.2))
                        .frame(width: 36, height: 36)
                        .overlay {
                            Image(systemName: "info.circle.fill")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundStyle(.purple)
                        }
                    
                    Text("Prescription Information")
                        .font(.headline.weight(.bold))
                        .foregroundStyle(.primary)
                    
                    Spacer()
                }
                
                LazyVGrid(columns: [
                    GridItem(.flexible(), spacing: Spacing.small),
                    GridItem(.flexible(), spacing: Spacing.small)
                ], spacing: Spacing.medium) {
                    
                    // Days since prescription
                    VStack(alignment: .leading, spacing: Spacing.xs) {
                        HStack {
                            Image(systemName: "clock")
                                .font(.caption.weight(.medium))
                                .foregroundStyle(.orange)
                            
                            Text("Days Ago")
                                .font(.caption2.weight(.medium))
                                .foregroundStyle(.tertiary)
                            
                            Spacer()
                        }
                        
                        let daysAgo = Calendar.current.dateComponents([.day], from: prescription.dateIssued, to: Date()).day ?? 0
                        Text("\(daysAgo)")
                            .font(.title3.weight(.bold))
                            .foregroundStyle(.orange)
                    }
                    .padding(Spacing.small)
                    .background(Color(UIColor.secondarySystemGroupedBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    
                    // Total medications
                    VStack(alignment: .leading, spacing: Spacing.xs) {
                        HStack {
                            Image(systemName: "pills")
                                .font(.caption.weight(.medium))
                                .foregroundStyle(.cyan)
                            
                            Text("Medications")
                                .font(.caption2.weight(.medium))
                                .foregroundStyle(.tertiary)
                            
                            Spacer()
                        }
                        
                        Text("\(prescription.medications.count)")
                            .font(.title3.weight(.bold))
                            .foregroundStyle(.cyan)
                    }
                    .padding(Spacing.small)
                    .background(Color(UIColor.secondarySystemGroupedBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                }
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
            return "Completed"
        }
    }
}

