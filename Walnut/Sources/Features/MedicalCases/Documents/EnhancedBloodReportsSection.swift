//
//  EnhancedBloodReportsSection.swift
//  Walnut
//
//  Created by Mayank Gandhi on 21/08/25.
//  Copyright © 2025 m. All rights reserved.
//

import WalnutDesignSystem
import SwiftUI

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
                    HStack(spacing: Spacing.medium) {
                        Circle()
                            .fill(Color.healthError.opacity(0.15))
                            .frame(width: 48, height: 48)
                            .overlay {
                                Image(systemName: "testtube.2")
                                    .font(.title3.weight(.semibold))
                                    .foregroundStyle(Color.healthError)
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
                                        .foregroundStyle(Color.healthError)
                                }
                            }
                        }
                        
                        Spacer()
                        
                        Button(action: { showAddBloodReport = true }) {
                            Image(systemName: "plus.circle.fill")
                                .font(.title2)
                                .foregroundStyle(Color.healthError)
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
                            .tint(Color.healthError)
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

