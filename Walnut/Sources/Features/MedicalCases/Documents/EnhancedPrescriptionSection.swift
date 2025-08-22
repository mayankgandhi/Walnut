//
//  EnhancedPrescriptionSection.swift
//  Walnut
//
//  Created by Mayank Gandhi on 21/08/25.
//  Copyright © 2025 m. All rights reserved.
//

import WalnutDesignSystem
import SwiftUI

struct EnhancedPrescriptionSection: View {
    
    let medicalCase: MedicalCase
    @State private var selectedPrescription: Prescription?
    @State private var editingPrescription: Prescription?
    @State private var showAddDocument = false
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
                    HStack(spacing: Spacing.medium) {
                        // Icon with dynamic background
                        Circle()
                            .fill(Color.healthPrimary.opacity(0.15))
                            .frame(width: 48, height: 48)
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
        .sheet(item: $editingPrescription) { prescription in
            PrescriptionEditor(prescription: prescription, medicalCase: medicalCase)
        }
        .prescriptionDocumentPicker(for: medicalCase, isPresented: $showAddDocument)
    }
    
    // MARK: - Context Menu
    
    @ViewBuilder
    private func prescriptionContextMenu(for prescription: Prescription) -> some View {
        Button {
            editingPrescription = prescription
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
