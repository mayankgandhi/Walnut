//
//  DemoModeView.swift
//  Walnut
//
//  Created by Mayank Gandhi on 23/09/25.
//  Copyright © 2025 m. All rights reserved.
//


import SwiftUI
import SwiftData
import WalnutDesignSystem

@MainActor
struct DemoModeView: View {

    @Environment(\.dismiss) private var dismiss
    @State private var demoModelContainer: ModelContainer?
    @State private var isLoading = true
    
    private let demoModeManager = DemoModeManager.shared
    
    var body: some View {
        Group {
            if !isLoading,
               let container = demoModelContainer {
                // Fetch the demo patient from the container
                if let demoPatient = fetchDemoPatient(from: container) {
                // Completely isolate the demo mode in its own environment
                NavigationStack {
                    PatientTabView(patient: demoPatient)
                        .navigationTitle("Demo Mode")
                        .navigationBarTitleDisplayMode(.inline)
                        .toolbar {
                            ToolbarItem(placement: .navigationBarLeading) {
                                Button("Exit Demo") {
                                    dismiss()
                                }
                            }
                        }
                }
                .modelContainer(container)
                .environment(\.modelContext, container.mainContext)
                } else {
                    // Demo patient not found
                    NavigationStack {
                        VStack(spacing: Spacing.medium) {
                            Image(systemName: "exclamationmark.triangle")
                                .font(.title)
                                .foregroundStyle(.orange)

                            Text("Demo patient not found")
                                .font(.headline)

                            Button("Retry") {
                                setupDemoContainer()
                            }
                            .buttonStyle(.borderedProminent)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .navigationTitle("Demo Mode")
                        .navigationBarTitleDisplayMode(.inline)
                        .toolbar {
                            ToolbarItem(placement: .navigationBarLeading) {
                                Button("Cancel") {
                                    dismiss()
                                }
                            }
                        }
                    }
                }
            } else if isLoading {
                NavigationStack {
                    VStack(spacing: Spacing.medium) {
                        ProgressView()
                            .scaleEffect(1.2)
                        
                        Text("Loading demo data...")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .navigationTitle("Demo Mode")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarLeading) {
                            Button("Cancel") {
                                dismiss()
                            }
                        }
                    }
                }
            } else {
                NavigationStack {
                    VStack(spacing: Spacing.medium) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.title)
                            .foregroundStyle(.orange)
                        
                        Text("Failed to load demo data")
                            .font(.headline)
                        
                        Button("Retry") {
                            setupDemoContainer()
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .navigationTitle("Demo Mode")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarLeading) {
                            Button("Cancel") {
                                dismiss()
                            }
                        }
                    }
                }
            }
        }
        .task {
            setupDemoContainer()
        }
    }
    
    private func setupDemoContainer() {
        isLoading = true
        
        Task { @MainActor in
            do {
                let schema = Schema([
                    Patient.self,
                    MedicalCase.self,
                    Prescription.self,
                    Medication.self,
                    BioMarkerReport.self,
                    BioMarkerResult.self,
                    Document.self
                ])
                
                let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
                let container = try ModelContainer(for: schema, configurations: [configuration])
                
                // Temporarily enable demo mode to populate data
                let originalDemoState = demoModeManager.isDemoModeEnabled
                if !originalDemoState {
                    demoModeManager.isDemoModeEnabled = true
                }

                // Use DemoModeManager to populate demo data
                demoModeManager.populateDemoData(in: container.mainContext)

                // Restore original demo mode state if it was changed
                if !originalDemoState {
                    demoModeManager.isDemoModeEnabled = false
                }
                
                self.demoModelContainer = container
                self.isLoading = false
            } catch {
                print("❌ Failed to create demo container: \(error)")
                self.isLoading = false
            }
        }
    }

    private func fetchDemoPatient(from container: ModelContainer) -> Patient? {
        do {
            let descriptor = FetchDescriptor<Patient>()
            let patients = try container.mainContext.fetch(descriptor)

            // Look for demo patient
            return patients.first { patient in
                (patient.name == "Alex Demo Patient") ||
                (patient.notes?.contains("demo-patient-walnut-app") == true)
            }
        } catch {
            print("❌ Failed to fetch demo patient: \(error)")
            return nil
        }
    }
}

#Preview {
    DemoModeView()
}
