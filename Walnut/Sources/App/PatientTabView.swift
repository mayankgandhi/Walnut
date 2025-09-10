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
    
    var body: some View {
        TabView {
            
            Tab("Meds", systemImage: "pills.fill") {
                NavigationStack {
                    AllMedicationsView(patient: patient)
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
                    BloodTestsView(
                        viewModel: BloodTestsViewModel(
                            patient: patient,
                            modelContext: modelContext
                        )
                    )
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
        .conditionalModifier(when: uploadStateManager.isUploading, apply: {
            $0.tabViewBottomAccessory {
                if let documentType = uploadStateManager.documentType {
                    UploadViewBottomAccessory(
                        documentType: documentType,
                        state: uploadStateManager.uploadState,
                        progress: uploadStateManager.progress,
                        customStatusText: uploadStateManager.statusText
                    )
                }
            }
        })
    }
}

#Preview {
    NavigationStack {
        PatientTabView(patient: .samplePatient)
    }
}
