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
    @State private var isExpanded = false
    @State private var headerScale: CGFloat = 1.0
    @State private var showQuickActions = false
    @Namespace private var heroTransition
    
    var body: some View {
        ScrollView {
            VStack(spacing: Spacing.large) {
                // Enhanced Hero Header with dynamic visuals
                HealthCard(padding: Spacing.large) {
                    VStack(spacing: Spacing.large) {
                        // Hero Section with enhanced specialty visualization
                        HStack(spacing: Spacing.large) {
                            // Enhanced Specialty Icon with animated background
                            ZStack {
                                // Animated background gradient
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            colors: [
                                                medicalCase.specialty.color.opacity(0.2),
                                                medicalCase.specialty.color.opacity(0.05)
                                            ],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(width: 80, height: 80)
                                    .shadow(color: medicalCase.specialty.color.opacity(0.3), radius: 8, x: 0, y: 4)
                                
                                // Subtle pulse ring
                                Circle()
                                    .stroke(medicalCase.specialty.color.opacity(0.2), lineWidth: 2)
                                    .frame(width: 88, height: 88)
                                    .scaleEffect(headerScale)
                                    .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true), value: headerScale)
                                    .onAppear { headerScale = 1.1 }
                                
                                // Main icon with enhanced styling
                                Image(systemName: medicalCase.specialty.icon)
                                    .font(.system(size: 32, weight: .semibold, design: .rounded))
                                    .foregroundStyle(medicalCase.specialty.color)
                                    .scaleEffect(1.0)
                                    .animation(.spring(response: 0.6, dampingFraction: 0.8), value: medicalCase.specialty.icon)
                            }
                            .matchedGeometryEffect(id: "specialty-icon", in: heroTransition)
                            
                            // Enhanced content with better hierarchy
                            VStack(alignment: .leading, spacing: Spacing.small) {
                                Text(medicalCase.title)
                                    .font(.title.weight(.bold))
                                    .foregroundStyle(.primary)
                                    .lineLimit(3)
                                    .multilineTextAlignment(.leading)
                                
                                HStack(spacing: Spacing.xs) {
                                    PatientAvatar(
                                        initials: String(medicalCase.patient.fullName.prefix(2)),
                                        color: medicalCase.specialty.color,
                                        size: 24
                                    )
                                    
                                    Text(medicalCase.patient.fullName)
                                        .font(.subheadline.weight(.medium))
                                        .foregroundStyle(.secondary)
                                }
                                
                                // Enhanced status with context
                                HStack(spacing: Spacing.xs) {
                                    Circle()
                                        .fill(medicalCase.isActive ? Color.healthSuccess : Color.healthWarning)
                                        .frame(width: 8, height: 8)
                                        .scaleEffect(medicalCase.isActive ? 1.0 : 0.8)
                                        .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: medicalCase.isActive)
                                    
                                    Text(medicalCase.isActive ? "Active Treatment" : "Case Closed")
                                        .font(.caption.weight(.semibold))
                                        .foregroundStyle(medicalCase.isActive ? Color.healthSuccess : Color.healthWarning)
                                }
                            }
                            
                            Spacer()
                        }
                        
                        // Enhanced metadata section with modern card grid
                        LazyVGrid(columns: [
                            GridItem(.flexible(), spacing: Spacing.small),
                            GridItem(.flexible(), spacing: Spacing.small)
                        ], spacing: Spacing.medium) {
                            
                            // Case Type Card
                            VStack(alignment: .leading, spacing: Spacing.xs) {
                                HStack {
                                    Image(systemName: "folder.badge")
                                        .font(.caption.weight(.medium))
                                        .foregroundStyle(medicalCase.type.foregroundColor)
                                    
                                    Text("Type")
                                        .font(.caption2.weight(.medium))
                                        .foregroundStyle(.tertiary)
                                    
                                    Spacer()
                                }
                                
                                Text(medicalCase.type.displayName)
                                    .font(.caption.weight(.semibold))
                                    .foregroundStyle(medicalCase.type.foregroundColor)
                                    .padding(.horizontal, Spacing.small)
                                    .padding(.vertical, 2)
                                    .background(medicalCase.type.backgroundColor)
                                    .clipShape(Capsule())
                            }
                            .padding(Spacing.small)
                            .background(Color(UIColor.secondarySystemGroupedBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                            
                            // Date Card
                            VStack(alignment: .leading, spacing: Spacing.xs) {
                                HStack {
                                    Image(systemName: "calendar")
                                        .font(.caption.weight(.medium))
                                        .foregroundStyle(.secondary)
                                    
                                    Text("Created")
                                        .font(.caption2.weight(.medium))
                                        .foregroundStyle(.tertiary)
                                    
                                    Spacer()
                                }
                                
                                Text(medicalCase.createdAt.formatted(date: .abbreviated, time: .omitted))
                                    .font(.caption.weight(.semibold))
                                    .foregroundStyle(.secondary)
                            }
                            .padding(Spacing.small)
                            .background(Color(UIColor.secondarySystemGroupedBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                        
                        // Enhanced Treatment Plan & Notes Section
                        VStack(spacing: Spacing.medium) {
                            // Treatment Plan with enhanced card design
                            if !medicalCase.treatmentPlan.isEmpty {
                                VStack(alignment: .leading, spacing: Spacing.small) {
                                    Button(action: { 
                                        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) { 
                                            isExpanded.toggle() 
                                        } 
                                    }) {
                                        HStack {
                                            HStack(spacing: Spacing.xs) {
                                                Circle()
                                                    .fill(Color.healthPrimary.opacity(0.2))
                                                    .frame(width: 32, height: 32)
                                                    .overlay {
                                                        Image(systemName: "list.clipboard.fill")
                                                            .font(.caption.weight(.medium))
                                                            .foregroundStyle(Color.healthPrimary)
                                                    }
                                                
                                                VStack(alignment: .leading, spacing: 2) {
                                                    Text("Treatment Plan")
                                                        .font(.subheadline.weight(.semibold))
                                                        .foregroundStyle(.primary)
                                                    
                                                    Text(isExpanded ? "Tap to collapse" : "Tap to view details")
                                                        .font(.caption2)
                                                        .foregroundStyle(.secondary)
                                                }
                                            }
                                            
                                            Spacer()
                                            
                                            Image(systemName: isExpanded ? "chevron.up.circle.fill" : "chevron.down.circle.fill")
                                                .font(.title3)
                                                .foregroundStyle(.secondary)
                                                .rotationEffect(.degrees(isExpanded ? 180 : 0))
                                        }
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                    
                                    if isExpanded {
                                        Text(medicalCase.treatmentPlan)
                                            .font(.subheadline)
                                            .foregroundStyle(.primary)
                                            .padding(.top, Spacing.small)
                                            .fixedSize(horizontal: false, vertical: true)
                                            .transition(.asymmetric(
                                                insertion: .opacity.combined(with: .move(edge: .top)),
                                                removal: .opacity.combined(with: .move(edge: .bottom))
                                            ))
                                    } else {
                                        Text(medicalCase.treatmentPlan)
                                            .font(.subheadline)
                                            .foregroundStyle(.secondary)
                                            .lineLimit(2)
                                            .padding(.top, Spacing.xs)
                                    }
                                }
                                .padding(Spacing.medium)
                                .background(Color.healthPrimary.opacity(0.05))
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.healthPrimary.opacity(0.1), lineWidth: 1)
                                )
                            }
                            
                            // Enhanced Notes Section
                            if !medicalCase.notes.isEmpty {
                                HStack(spacing: Spacing.small) {
                                    Circle()
                                        .fill(Color.healthSuccess.opacity(0.2))
                                        .frame(width: 32, height: 32)
                                        .overlay {
                                            Image(systemName: "note.text")
                                                .font(.caption.weight(.medium))
                                                .foregroundStyle(Color.healthSuccess)
                                        }
                                    
                                    VStack(alignment: .leading, spacing: Spacing.xs) {
                                        HStack {
                                            Text("Clinical Notes")
                                                .font(.subheadline.weight(.semibold))
                                                .foregroundStyle(.primary)
                                            
                                            Spacer()
                                            
                                            Text("\(medicalCase.notes.count) chars")
                                                .font(.caption2)
                                                .foregroundStyle(.tertiary)
                                        }
                                        
                                        Text(medicalCase.notes)
                                            .font(.subheadline)
                                            .foregroundStyle(.secondary)
                                            .lineLimit(3)
                                    }
                                }
                                .padding(Spacing.medium)
                                .background(Color.healthSuccess.opacity(0.05))
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.healthSuccess.opacity(0.1), lineWidth: 1)
                                )
                            }
                        }
                        
                        // Enhanced Footer with Last Updated
                        if medicalCase.updatedAt != medicalCase.createdAt {
                            Divider()
                            
                            HStack {
                                Image(systemName: "clock.arrow.circlepath")
                                    .font(.caption)
                                    .foregroundStyle(.tertiary)
                                
                                Text("Last updated \(medicalCase.updatedAt, style: .relative)")
                                    .font(.caption)
                                    .foregroundStyle(.tertiary)
                                
                                Spacer()
                            }
                        }
                    }
                }
                
                // Enhanced Content Sections with modern layouts
                VStack(spacing: Spacing.large) {
                    EnhancedDocumentsSection(medicalCase: medicalCase)
                    
                    EnhancedBloodReportsSection(medicalCase: medicalCase)
                    
                    // Show unparsed documents only if there are any
                    if !medicalCase.unparsedDocuments.isEmpty {
                        EnhancedUnparsedDocumentsSection(medicalCase: medicalCase)
                    }
                }
            }
            .padding(.vertical, Spacing.medium)
        }
        .background(Color(UIColor.systemGroupedBackground))
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Enhanced Document Sections

struct EnhancedDocumentsSection: View {
    let medicalCase: MedicalCase
    @State private var selectedPrescription: Prescription?
    @State private var editingPrescription: Prescription?
    @State private var showAddDocument = false
    @State private var showPrescriptionEditor = false
    @State private var isExpanded = true
    
    var body: some View {
        HealthCard {
            VStack(alignment: .leading, spacing: Spacing.medium) {
                // Enhanced Section Header
                Button(action: {
                    withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                        isExpanded.toggle()
                    }
                }) {
                    HStack(spacing: Spacing.small) {
                        // Icon with dynamic background
                        Circle()
                            .fill(Color.healthPrimary.opacity(0.15))
                            .frame(width: 44, height: 44)
                            .overlay {
                                Image(systemName: "doc.text.fill")
                                    .font(.title3.weight(.semibold))
                                    .foregroundStyle(Color.healthPrimary)
                            }
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Prescriptions")
                                .font(.headline.weight(.bold))
                                .foregroundStyle(.primary)
                            
                            Text("\(medicalCase.prescriptions.count) documents")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        
                        Spacer()
                        
                        // Add button
                        Button(action: { showAddDocument = true }) {
                            Image(systemName: "plus.circle.fill")
                                .font(.title2)
                                .foregroundStyle(Color.healthPrimary)
                        }
                        .scaleEffect(showAddDocument ? 0.9 : 1.0)
                        .animation(.easeInOut(duration: 0.1), value: showAddDocument)
                        
                        // Expand/collapse button
                        Image(systemName: isExpanded ? "chevron.up.circle" : "chevron.down.circle")
                            .font(.title3)
                            .foregroundStyle(.secondary)
                            .rotationEffect(.degrees(isExpanded ? 0 : 180))
                    }
                }
                .buttonStyle(PlainButtonStyle())
                
                if isExpanded {
                    if medicalCase.prescriptions.isEmpty {
                        // Empty state with modern design
                        VStack(spacing: Spacing.medium) {
                            Image(systemName: "doc.badge.plus")
                                .font(.system(size: 48))
                                .foregroundStyle(.quaternary)
                            
                            VStack(spacing: Spacing.xs) {
                                Text("No prescriptions yet")
                                    .font(.subheadline.weight(.medium))
                                    .foregroundStyle(.secondary)
                                
                                Text("Add prescription documents to track medications")
                                    .font(.caption)
                                    .foregroundStyle(.tertiary)
                                    .multilineTextAlignment(.center)
                            }
                            
                            Button("Add First Prescription") {
                                showAddDocument = true
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(Color.healthPrimary)
                        }
                        .padding(.vertical, Spacing.large)
                        .transition(.opacity.combined(with: .move(edge: .top)))
                    } else {
                        // Enhanced prescription list
                        LazyVStack(spacing: Spacing.small) {
                            ForEach(medicalCase.prescriptions) { prescription in
                                EnhancedPrescriptionListItem(prescription: prescription)
                                    .onTapGesture {
                                        selectedPrescription = prescription
                                    }
                                    .contextMenu {
                                        prescriptionContextMenu(for: prescription)
                                    }
                            }
                        }
                        .transition(.opacity.combined(with: .move(edge: .top)))
                    }
                }
            }
        }
        .navigationDestination(item: $selectedPrescription) { prescription in
            PrescriptionDetailView(prescription: prescription)
        }
        .sheet(isPresented: $showPrescriptionEditor) {
            if let prescription = editingPrescription {
                PrescriptionEditor(prescription: prescription, medicalCase: medicalCase)
                    .onDisappear {
                        editingPrescription = nil
                    }
            }
        }
        .prescriptionDocumentPicker(for: medicalCase, isPresented: $showAddDocument)
    }
    
    // MARK: - Context Menu
    
    @ViewBuilder
    private func prescriptionContextMenu(for prescription: Prescription) -> some View {
        Button {
            editingPrescription = prescription
            showPrescriptionEditor = true
        } label: {
            Label("Edit Prescription", systemImage: "pencil")
        }
        
        Button {
            selectedPrescription = prescription
        } label: {
            Label("View Details", systemImage: "eye")
        }
        
        Divider()
        
        Button {
            // Add sharing functionality if needed
            if let document = prescription.document {
                let activityController = UIActivityViewController(
                    activityItems: [document.fileURL],
                    applicationActivities: nil
                )
                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                   let rootViewController = windowScene.windows.first?.rootViewController {
                    rootViewController.present(activityController, animated: true)
                }
            }
        } label: {
            Label("Share Document", systemImage: "square.and.arrow.up")
        }
        .disabled(prescription.document == nil)
    }
}

struct EnhancedPrescriptionListItem: View {
    let prescription: Prescription
    @State private var isPressed = false
    
    var body: some View {
        HStack(spacing: Spacing.medium) {
            // Enhanced icon with background
            Circle()
                .fill(Color.blue.opacity(0.15))
                .frame(width: 40, height: 40)
                .overlay {
                    Image(systemName: "pills.fill")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(.blue)
                }
            
            // Content with enhanced typography
            VStack(alignment: .leading, spacing: Spacing.xs) {
                HStack {
                    Text(prescription.dateIssued, style: .date)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.primary)
                    
                    Spacer()
                    
                    if prescription.followUpDate != nil {
                        HStack(spacing: 2) {
                            Circle()
                                .fill(Color.green)
                                .frame(width: 4, height: 4)
                            
                            Text("Follow-up")
                                .font(.caption2.weight(.medium))
                                .foregroundStyle(.green)
                        }
                    }
                }
                
                if let doctorName = prescription.doctorName {
                    Text("Dr. \(doctorName)")
                        .font(.caption.weight(.medium))
                        .foregroundStyle(.secondary)
                }
                
                if let facilityName = prescription.facilityName {
                    Text(facilityName)
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                        .lineLimit(1)
                }
            }
            
            // Chevron indicator
            Image(systemName: "chevron.right")
                .font(.caption.weight(.medium))
                .foregroundStyle(.quaternary)
        }
        .padding(Spacing.small)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(UIColor.secondarySystemGroupedBackground))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.blue.opacity(0.1), lineWidth: 0.5)
                )
        )
        .scaleEffect(isPressed ? 0.98 : 1.0)
        .animation(.easeInOut(duration: 0.1), value: isPressed)
        
    }
}

struct EnhancedBloodReportsSection: View {
    let medicalCase: MedicalCase
    @State private var selectedBloodReport: BloodReport?
    @State private var showAddBloodReport = false
    @State private var isExpanded = true
    
    var body: some View {
        HealthCard {
            VStack(alignment: .leading, spacing: Spacing.medium) {
                // Enhanced Section Header
                Button(action: {
                    withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                        isExpanded.toggle()
                    }
                }) {
                    HStack(spacing: Spacing.small) {
                        Circle()
                            .fill(Color.red.opacity(0.15))
                            .frame(width: 44, height: 44)
                            .overlay {
                                Image(systemName: "testtube.2")
                                    .font(.title3.weight(.semibold))
                                    .foregroundStyle(.red)
                            }
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Blood Reports")
                                .font(.headline.weight(.bold))
                                .foregroundStyle(.primary)
                            
                            HStack {
                                Text("\(medicalCase.bloodReports.count) reports")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                                
                                let abnormalCount = medicalCase.bloodReports.flatMap(\.testResults).filter(\.isAbnormal).count
                                if abnormalCount > 0 {
                                    Text("•")
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                    
                                    Text("\(abnormalCount) abnormal")
                                        .font(.subheadline.weight(.medium))
                                        .foregroundStyle(.red)
                                }
                            }
                        }
                        
                        Spacer()
                        
                        Button(action: { showAddBloodReport = true }) {
                            Image(systemName: "plus.circle.fill")
                                .font(.title2)
                                .foregroundStyle(.red)
                        }
                        
                        Image(systemName: isExpanded ? "chevron.up.circle" : "chevron.down.circle")
                            .font(.title3)
                            .foregroundStyle(.secondary)
                            .rotationEffect(.degrees(isExpanded ? 0 : 180))
                    }
                }
                .buttonStyle(PlainButtonStyle())
                
                if isExpanded {
                    if medicalCase.bloodReports.isEmpty {
                        VStack(spacing: Spacing.medium) {
                            Image(systemName: "testtube.2")
                                .font(.system(size: 48))
                                .foregroundStyle(.quaternary)
                            
                            VStack(spacing: Spacing.xs) {
                                Text("No blood reports")
                                    .font(.subheadline.weight(.medium))
                                    .foregroundStyle(.secondary)
                                
                                Text("Add lab results to track health metrics")
                                    .font(.caption)
                                    .foregroundStyle(.tertiary)
                                    .multilineTextAlignment(.center)
                            }
                            
                            Button("Add First Report") {
                                showAddBloodReport = true
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(.red)
                        }
                        .padding(.vertical, Spacing.large)
                        .transition(.opacity.combined(with: .move(edge: .top)))
                    } else {
                        LazyVStack(spacing: Spacing.small) {
                            ForEach(medicalCase.bloodReports) { bloodReport in
                                EnhancedBloodReportListItem(bloodReport: bloodReport)
                                    .onTapGesture {
                                        selectedBloodReport = bloodReport
                                    }
                            }
                        }
                        .transition(.opacity.combined(with: .move(edge: .top)))
                    }
                }
            }
        }
        .navigationDestination(item: $selectedBloodReport) { bloodReport in
            BloodReportDetailView(bloodReport: bloodReport)
        }
        .bloodReportDocumentPicker(for: medicalCase, isPresented: $showAddBloodReport)
    }
}

struct EnhancedBloodReportListItem: View {
    let bloodReport: BloodReport
    @State private var isPressed = false
    
    var body: some View {
        HStack(spacing: Spacing.medium) {
            Circle()
                .fill(Color.red.opacity(0.15))
                .frame(width: 40, height: 40)
                .overlay {
                    Image(systemName: "drop.fill")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(.red)
                }
            
            VStack(alignment: .leading, spacing: Spacing.xs) {
                HStack {
                    Text(bloodReport.testName)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.primary)
                        .lineLimit(1)
                    
                    Spacer()
                    
                    let abnormalCount = bloodReport.testResults.filter(\.isAbnormal).count
                    if abnormalCount > 0 {
                        HStack(spacing: 2) {
                            Circle()
                                .fill(Color.red)
                                .frame(width: 4, height: 4)
                            
                            Text("\(abnormalCount) abnormal")
                                .font(.caption2.weight(.medium))
                                .foregroundStyle(.red)
                        }
                    }
                }
                
                HStack {
                    Text(bloodReport.resultDate, style: .date)
                        .font(.caption.weight(.medium))
                        .foregroundStyle(.secondary)
                    
                    if !bloodReport.labName.isEmpty {
                        Text("•")
                            .font(.caption)
                            .foregroundStyle(.tertiary)
                        
                        Text(bloodReport.labName)
                            .font(.caption)
                            .foregroundStyle(.tertiary)
                            .lineLimit(1)
                    }
                }
                
                if !bloodReport.testResults.isEmpty {
                    Text("\(bloodReport.testResults.count) test results")
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                }
            }
            
            Image(systemName: "chevron.right")
                .font(.caption.weight(.medium))
                .foregroundStyle(.quaternary)
        }
        .padding(Spacing.small)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(UIColor.secondarySystemGroupedBackground))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.red.opacity(0.1), lineWidth: 0.5)
                )
        )
        .scaleEffect(isPressed ? 0.98 : 1.0)
        .animation(.easeInOut(duration: 0.1), value: isPressed)
        
    }
}

struct EnhancedUnparsedDocumentsSection: View {
    let medicalCase: MedicalCase
    @State private var isRetrying = false
    @State private var isExpanded = true
    
    var body: some View {
        HealthCard {
            VStack(alignment: .leading, spacing: Spacing.medium) {
                Button(action: {
                    withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                        isExpanded.toggle()
                    }
                }) {
                    HStack(spacing: Spacing.small) {
                        Circle()
                            .fill(Color.orange.opacity(0.15))
                            .frame(width: 44, height: 44)
                            .overlay {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .font(.title3.weight(.semibold))
                                    .foregroundStyle(.orange)
                            }
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Failed Documents")
                                .font(.headline.weight(.bold))
                                .foregroundStyle(.primary)
                            
                            Text("\(medicalCase.unparsedDocuments.count) documents need attention")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        
                        Spacer()
                        
                        Image(systemName: isExpanded ? "chevron.up.circle" : "chevron.down.circle")
                            .font(.title3)
                            .foregroundStyle(.secondary)
                            .rotationEffect(.degrees(isExpanded ? 0 : 180))
                    }
                }
                .buttonStyle(PlainButtonStyle())
                
                if isExpanded {
                    LazyVStack(spacing: Spacing.small) {
                        ForEach(medicalCase.unparsedDocuments) { document in
                            EnhancedUnparsedDocumentListItem(
                                document: document,
                                isRetrying: isRetrying,
                                onRetry: { }
                            )
                        }
                    }
                    .transition(.opacity.combined(with: .move(edge: .top)))
                }
            }
        }
    }
}

struct EnhancedUnparsedDocumentListItem: View {
    let document: Document
    let isRetrying: Bool
    let onRetry: () -> Void
    @State private var isPressed = false
    
    var body: some View {
        HStack(spacing: Spacing.medium) {
            Circle()
                .fill(Color.orange.opacity(0.15))
                .frame(width: 40, height: 40)
                .overlay {
                    Image(systemName: "doc.badge.ellipsis")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(.orange)
                }
            
            VStack(alignment: .leading, spacing: Spacing.xs) {
                Text(document.fileName)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.primary)
                    .lineLimit(2)
                
                HStack {
                    Text(document.uploadDate, style: .date)
                        .font(.caption.weight(.medium))
                        .foregroundStyle(.secondary)
                    
                    Text("•")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                    
                    Text(ByteCountFormatter.string(fromByteCount: document.fileSize, countStyle: .file))
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }
            }
            
            Spacer()
            
            Button(action: onRetry) {
                HStack(spacing: 4) {
                    if isRetrying {
                        ProgressView()
                            .controlSize(.mini)
                    } else {
                        Image(systemName: "arrow.clockwise.circle.fill")
                            .font(.title3)
                    }
                }
                .foregroundStyle(.orange)
            }
            .disabled(isRetrying)
        }
        .padding(Spacing.small)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(UIColor.secondarySystemGroupedBackground))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.orange.opacity(0.1), lineWidth: 0.5)
                )
        )
        .scaleEffect(isPressed ? 0.98 : 1.0)
        .animation(.easeInOut(duration: 0.1), value: isPressed)
    }
}

#Preview(body: {
    MedicalCaseDetailView(
        medicalCase: MedicalCase.sampleCase
    )
})
