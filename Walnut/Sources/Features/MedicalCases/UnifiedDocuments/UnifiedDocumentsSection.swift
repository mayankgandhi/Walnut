//
//  UnifiedDocumentsSection.swift
//  Walnut
//
//  Created by Mayank Gandhi on 22/08/25.
//  Copyright © 2025 m. All rights reserved.
//

import SwiftUI
import WalnutDesignSystem
import SwiftData

struct UnifiedDocumentsSection: View {
    
    @Environment(\.modelContext) var modelContext
    let medicalCase: MedicalCase
    
    @State private var viewModel = UnifiedDocumentsSectionViewModel()
    
    init(
        modelContext: ModelContext,
        medicalCase: MedicalCase,
        viewModel: UnifiedDocumentsSectionViewModel = UnifiedDocumentsSectionViewModel()
    ) {
        self.medicalCase = medicalCase

        self.viewModel = viewModel
    }
    
    var body: some View {
        VStack(
            alignment: .leading,
            spacing: Spacing.medium
        ) {
            
            HStack {
                HealthCardHeader.medicalDocuments(
                    count: viewModel.totalDocumentCount
                )
            
                AddDocumentsButton(modelContext: modelContext, medicalCase: medicalCase)
            }
            
            Group {
                if viewModel.isLoading {
                    loadingView
                        .transition(.opacity)
                } else if viewModel.isEmpty {
                    emptyStateView
                        .transition(.opacity.combined(with: .scale(scale: 0.95)))
                } else {
                    documentsListView
                        .transition(.opacity.combined(with: .move(edge: .top)))
                }
            }
            .animation(.easeInOut(duration: 0.3), value: viewModel.isLoading)
            .animation(.easeInOut(duration: 0.3), value: viewModel.isEmpty)
        }
        .navigationDestination(item: $viewModel.navigationState.selectedPrescription) { prescription in
            PrescriptionDetailView(prescription: prescription)
        }
        .navigationDestination(item: $viewModel.navigationState.selectedBloodReport) { bloodReport in
            BloodReportDetailView(bloodReport: bloodReport)
        }
        .navigationDestination(item: $viewModel.navigationState.selectedDocument) { document in
            DocumentViewer(document: document)
        }
        .task {
            viewModel.loadDocuments(from: medicalCase)
        }
        .refreshable {
            await viewModel.refresh(from: medicalCase)
        }
    }
    
    // MARK: - View Components
    
    private var loadingView: some View {
        VStack(spacing: Spacing.medium) {
            ProgressView()
                .scaleEffect(1.2)
            
            Text("Loading documents...")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, Spacing.xl)
    }
    
    private var emptyStateView: some View {
        VStack(alignment: .center, spacing: Spacing.large) {
            
            ContentUnavailableView {
                Label("No Documents", systemImage: "folder.fill")
               
            } description: {
                Text("Add medical documents to track prescriptions, lab results, and more")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(nil)
            }
        }
        .padding(.vertical, Spacing.xl)
    }
    
    private var documentsListView: some View {
        LazyVStack(alignment: .center, spacing: Spacing.small) {
            ForEach(viewModel.allDocuments, id: \.id) { item in
                DocumentRowView(item: item, viewModel: viewModel)
                    .transition(.asymmetric(
                        insertion: .move(edge: .top).combined(with: .opacity),
                        removal: .move(edge: .trailing).combined(with: .opacity)
                    ))
            }
        }
    }
    
}

#Preview("Unified Documents - With Documents") {
    let schema = Schema([
        Patient.self,
        MedicalCase.self,
        Prescription.self,
        BloodReport.self,
        BloodTestResult.self,
        Document.self,
        Medication.self
    ])
    let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: schema, configurations: [modelConfiguration])
    
    let patient = Patient.samplePatient
    let medicalCase = MedicalCase.sampleCase
    
    // Create sample prescription
    let prescription = Prescription(
        id: UUID(),
        followUpDate: Date().addingTimeInterval(86400 * 30),
        followUpTests: ["Blood work", "Follow-up consultation"],
        dateIssued: Date().addingTimeInterval(-86400 * 7),
        doctorName: "Dr. Sarah Johnson",
        facilityName: "City Medical Center",
        notes: "Continue current medication regimen",
        document: nil,
        medicalCase: medicalCase,
        medications: [
            Medication(
                id: UUID(),
                name: "Metformin",
                frequency: [MedicationSchedule(mealTime: .breakfast, timing: .after, dosage: "500mg")],
                numberOfDays: 30,
                dosage: "500mg",
                instructions: "Take with breakfast"
            )
        ]
    )
    
    // Create sample blood report
    let bloodReport = BloodReport(
        id: UUID(),
        testName: "Complete Blood Count",
        labName: "LabCorp",
        category: "Hematology",
        resultDate: Date().addingTimeInterval(-86400 * 3),
        notes: "All values within normal range",
        createdAt: Date().addingTimeInterval(-86400 * 3),
        updatedAt: Date().addingTimeInterval(-86400 * 3),
        medicalCase: medicalCase,
        testResults: [
            BloodTestResult(
                testName: "Hemoglobin",
                value: "14.2",
                unit: "g/dL",
                referenceRange: "12.0-15.5",
                isAbnormal: false
            )
        ]
    )
    
    // Create sample document
    let document = Document(
        id: UUID(),
        fileName: "Medical_Report_2024.pdf",
        fileURL:  "file://document.pdf",
        documentType: .unknown,
        fileSize: 100,
        createdAt: Date().addingTimeInterval(-86400 * 5),
        updatedAt: Date().addingTimeInterval(-86400 * 5),
    )
    
    medicalCase.prescriptions = [prescription]
    medicalCase.bloodReports = [bloodReport]
    medicalCase.otherDocuments = [document]
    
    container.mainContext.insert(patient)
    container.mainContext.insert(medicalCase)
    container.mainContext.insert(prescription)
    container.mainContext.insert(bloodReport)
    container.mainContext.insert(document)
    
    return NavigationStack {
        ScrollView {
            UnifiedDocumentsSection(
                modelContext: container.mainContext,
                medicalCase: medicalCase
            )
            .padding()
        }
    }
    .modelContainer(container)
}

#Preview("Unified Documents - Empty State") {
    let schema = Schema([
        Patient.self,
        MedicalCase.self,
        Prescription.self,
        BloodReport.self,
        Document.self
    ])
    let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: schema, configurations: [modelConfiguration])
    
    let patient = Patient.samplePatient
    let medicalCase = MedicalCase(
        id: UUID(),
        title: "Empty Case",
        notes: "No documents yet",
        type: .consultation,
        specialty: .generalPractitioner,
        isActive: true,
        createdAt: Date(),
        updatedAt: Date(),
        patient: patient,
        prescriptions: [],
        bloodReports: [],
        unparsedDocuments: []
    )
    
    container.mainContext.insert(patient)
    container.mainContext.insert(medicalCase)
    
    return NavigationStack {
        ScrollView {
            UnifiedDocumentsSection(
                modelContext: container.mainContext,
                medicalCase: medicalCase
            )
            .padding()
        }
    }
    .modelContainer(container)
}
