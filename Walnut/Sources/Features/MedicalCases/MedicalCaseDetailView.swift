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
            VStack(spacing: Spacing.xl) {
                // Enhanced Hero Header with dynamic visuals
                HealthCard(padding: Spacing.xl) {
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
                            .padding(Spacing.medium)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color(UIColor.secondarySystemGroupedBackground))
                                    .stroke(Color(UIColor.separator).opacity(0.3), lineWidth: 0.5)
                            )
                            
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
                            .padding(Spacing.medium)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color(UIColor.secondarySystemGroupedBackground))
                                    .stroke(Color(UIColor.separator).opacity(0.3), lineWidth: 0.5)
                            )
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
                    EnhancedPrescriptionSection(medicalCase: medicalCase)
                    
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

#Preview(body: {
    MedicalCaseDetailView(
        medicalCase: MedicalCase.sampleCase
    )
})
