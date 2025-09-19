//
//  PatientTabView.swift
//  Walnut
//
//  Created by Mayank Gandhi on 11/08/25.
//  Copyright © 2025 m. All rights reserved.
//

import SwiftUI
import WalnutDesignSystem

struct PatientTabView: View {

    @Environment(\.modelContext) private var modelContext
    let patient: Patient
    @State private var uploadStateManager = DocumentUploadStateManager.shared
    @StateObject private var subscriptionService = SubscriptionService.shared

    init(patient: Patient) {
        self.patient = patient
    }

    var body: some View {
        TabView {
            
            Tab("Meds", systemImage: "pills.fill") {
                NavigationStack {
                    MedicationsView(patient: patient)
                }
            }
            
            Tab("Cases", systemImage: "folder.fill") {
                NavigationStack {
                    MedicalCasesView(
                        viewModel: MedicalCasesViewModel(
                            patient: patient,
                            modelContext: modelContext
                        )
                    )
                }
            }
            
            Tab("Trends", systemImage: "chart.line.uptrend.xyaxis") {
                NavigationStack {
                    if subscriptionService.isSubscribed {
                        BloodTestsView(
                            viewModel: BloodTestsViewModel(
                                patient: patient,
                                modelContext: modelContext
                            )
                        )
                    } else {
                        AppPaywallView()
                    }
                }
            }
            
            Tab("Account", systemImage: "person.2.badge.gearshape.fill") {
                NavigationStack {
                    PatientSettingsView(
                        patient: patient,
                        modelContext: modelContext
                    )
                    
                }
            }
            
        }
        .tabBarMinimizeBehavior(.onScrollDown)
        .onAppear {
            uploadStateManager.initializeProcessingService(modelContext: modelContext)
        }
        .tabViewBottomAccessory {
            // Always provide the accessory view, but conditionally show content
            if uploadStateManager.isUploading, let documentType = uploadStateManager.documentType {
                UploadViewBottomAccessory(
                    documentType: documentType,
                    state: uploadStateManager.uploadState,
                    progress: uploadStateManager.progress,
                    customStatusText: uploadStateManager.statusText
                )
            } else {
                // Provide an empty view with zero height when not uploading
                // This maintains view structure stability
                EmptyView()
                    .frame(height: 0)
                    .opacity(0)
            }
        }
    }
}

#Preview {
    NavigationStack {
        PatientTabView(patient: .samplePatient)
    }
}
