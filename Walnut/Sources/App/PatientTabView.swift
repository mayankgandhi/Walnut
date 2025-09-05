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
                    MedicationsTrackerView(patient: patient)
                }
            }
            
            Tab("Cases", systemImage: "document.on.document") {
                NavigationStack {
                    MedicalCasesView(
                        viewModel: MedicalCasesViewModel(
                            patient: patient,
                            modelContext: modelContext
                        )
                    )
                }
            }
            
            Tab("Blood Tests", systemImage: "testtube.2") {
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
                    PatientSettingsView(patient: patient)
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
