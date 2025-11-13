//
//  PatientTabView.swift
//  Walnut
//
//  Created by Mayank Gandhi on 11/08/25.
//  Copyright © 2025 m. All rights reserved.
//

import SwiftUI
import WalnutDesignSystem
import Gate

struct PatientTabView: View {
    
    @Environment(\.modelContext) private var modelContext
    let patient: Patient
    @State private var uploadStateManager = DocumentUploadStateManager.shared
    @StateObject private var subscriptionService = SubscriptionService.shared
    @State private var showDocumentReview = false
    
    init(patient: Patient) {
        self.patient = patient
    }
    
    var body: some View {
        TabView {
            
            Tab("Meds", systemImage: "pills.fill") {
                NavigationStack {
                    MedicationsView(
                        patient: patient,
                        modelContext: modelContext
                    )
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
                    BioMarkersView(
                        viewModel: BioMarkersViewModel(
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
     
        .tabViewBottomAccessory {
            // Always provide the accessory view, but conditionally show content
            if uploadStateManager.isUploading, let documentType = uploadStateManager.documentType {
                UploadViewBottomAccessory(
                    documentType: documentType,
                    state: uploadStateManager.uploadState,
                    progress: uploadStateManager.progress,
                    customStatusText: uploadStateManager.statusText,
                    onTapReview: {
                        showDocumentReview = true
                    }
                )
            } else {
                EmptyView()
                    .frame(height: 0)
                    .opacity(0)
            }
        }
        .sheet(isPresented: $showDocumentReview) {
            if let createdDocument = uploadStateManager.createdDocument {
                documentReviewView(for: createdDocument)
            }
        }
    }
    
    @ViewBuilder
    private func documentReviewView(for createdDocument: CreatedDocument) -> some View {
        switch createdDocument {
            case .prescription(let prescription):
                if let medicalCase = prescription.medicalCase {
                    PrescriptionEditor(
                        patient: patient,
                        prescription: prescription,
                        medicalCase: medicalCase
                    )
                } else {
                    Text("Error: Prescription missing medical case")
                        .foregroundColor(.red)
                }
            case .bioMarkerReport(let bioMarkerReport):
                if let medicalCase = bioMarkerReport.medicalCase {
                    BioMarkerReportEditor(
                        bloodReport: bioMarkerReport,
                        medicalCase: medicalCase
                    )
                } else {
                    BioMarkerReportEditor(
                        bloodReport: bioMarkerReport,
                        patient: patient
                    )
                }
        }
    }
}

#Preview {
    NavigationStack {
        PatientTabView(patient: .samplePatient)
    }
}
