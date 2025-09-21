//
//  DemoModeActivationSheet.swift
//  Walnut
//
//  Created by Claude Code on 22/09/25.
//  Copyright © 2025 m. All rights reserved.
//

import SwiftUI
import SwiftData
import WalnutDesignSystem

public struct DemoModeActivationSheet: View {

    @Environment(\.dismiss) private var dismiss
    @State private var demoModelContainer: ModelContainer?
    @State private var isLoading = true

    public init() {}

    public var body: some View {
        NavigationStack {
            if let container = demoModelContainer {
                PatientTabView(patient: getDemoPatient(from: container))
                    .modelContainer(container)
                    .navigationTitle("Demo Mode")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarLeading) {
                            Button("Exit Demo") {
                                dismiss()
                            }
                        }
                    }
                    .overlay(alignment: .top) {
                        DemoModeBanner()
                    }
            } else if isLoading {
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
            } else {
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
        .task {
            setupDemoContainer()
        }
    }

    // MARK: - Demo Data Setup

    private func setupDemoContainer() {
        isLoading = true

        Task { @MainActor in
            do {
                // Create in-memory model container for demo
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

                // Populate with demo data
                await populateDemoData(in: container.mainContext)

                self.demoModelContainer = container
                self.isLoading = false
            } catch {
                print("❌ Failed to create demo container: \(error)")
                self.isLoading = false
            }
        }
    }

    private func populateDemoData(in context: ModelContext) async {
        // Create demo patient
        let demoPatient = Patient(
            id: UUID(),
            name: "Alex Demo Patient",
            dateOfBirth: Calendar.current.date(byAdding: .year, value: -35, to: Date()) ?? Date(),
            gender: "Other",
            bloodType: "O+",
            emergencyContactName: "Jamie Contact",
            emergencyContactPhone: "+1 (555) 123-4567",
            notes: "This is a demo patient with sample health data for showcasing the Walnut app features.",
            createdAt: Date(),
            updatedAt: Date(),
            medicalCases: []
        )

        context.insert(demoPatient)

        // Create demo medical cases
        let diabetesCase = MedicalCase(
            id: UUID(),
            title: "Type 2 Diabetes Management",
            notes: "Patient diagnosed with Type 2 diabetes in 2020. Currently managing with medication and lifestyle changes. Regular monitoring required.",
            type: .consultation,
            specialty: .endocrinologist,
            isActive: true,
            createdAt: Calendar.current.date(byAdding: .year, value: -3, to: Date()) ?? Date(),
            updatedAt: Date(),
            patient: demoPatient,
            prescriptions: []
        )

        let hypertensionCase = MedicalCase(
            id: UUID(),
            title: "Hypertension Monitoring",
            notes: "Mild hypertension detected during routine checkup. Monitoring blood pressure and implementing lifestyle modifications.",
            type: .consultation,
            specialty: .cardiologist,
            isActive: true,
            createdAt: Calendar.current.date(byAdding: .month, value: -8, to: Date()) ?? Date(),
            updatedAt: Date(),
            patient: demoPatient,
            prescriptions: []
        )

        let resolvedCase = MedicalCase(
            id: UUID(),
            title: "Seasonal Allergies",
            notes: "Seasonal allergies successfully managed with antihistamines. Symptoms have resolved.",
            type: .consultation,
            specialty: .generalPractitioner,
            isActive: false,
            createdAt: Calendar.current.date(byAdding: .year, value: -1, to: Date()) ?? Date(),
            updatedAt: Calendar.current.date(byAdding: .month, value: -2, to: Date()) ?? Date(),
            patient: demoPatient,
            prescriptions: []
        )

        context.insert(diabetesCase)
        context.insert(hypertensionCase)
        context.insert(resolvedCase)

        demoPatient.medicalCases = [diabetesCase, hypertensionCase, resolvedCase]

        // Create demo prescriptions and medications
        let metforminPrescription = Prescription(
            id: UUID(),
            followUpDate: nil,
            followUpTests: [],
            dateIssued: Calendar.current.date(byAdding: .day, value: -30, to: Date()) ?? Date(),
            doctorName: "Dr. Sarah Johnson",
            facilityName: "HealthCare Clinic",
            notes: "Demo prescription for Metformin",
            document: nil,
            medicalCase: diabetesCase,
            medications: [],
            createdAt: Date(),
            updatedAt: Date()
        )

        let metforminMedication = Medication(
            id: UUID(),
            name: "Metformin",
            frequency: [.daily(times: [
                DateComponents(hour: 8, minute: 0),
                DateComponents(hour: 20, minute: 0)
            ])],
            duration: nil,
            dosage: "500mg",
            instructions: "Take twice daily with meals",
            createdAt: Date(),
            updatedAt: Date(),
            patient: demoPatient,
            prescription: metforminPrescription
        )

        metforminPrescription.medications = [metforminMedication]
        context.insert(metforminPrescription)
        context.insert(metforminMedication)

        // Create demo biomarker reports
        let recentReport = BioMarkerReport(
            id: UUID(),
            testName: "Comprehensive Metabolic Panel",
            labName: "Central Medical Lab",
            category: "Blood Chemistry",
            resultDate: Calendar.current.date(byAdding: .day, value: -14, to: Date()) ?? Date(),
            notes: "Routine follow-up blood work for diabetes management",
            createdAt: Date(),
            updatedAt: Date(),
            medicalCase: nil,
            patient: demoPatient,
            document: nil,
            testResults: []
        )

        let glucoseResult = BioMarkerResult(
            id: UUID(),
            testName: "Glucose",
            value: "145.0",
            unit: "mg/dL",
            referenceRange: "70-100 mg/dL",
            isAbnormal: true,
            bloodReport: recentReport
        )

        recentReport.testResults = [glucoseResult]
        context.insert(recentReport)
        context.insert(glucoseResult)

        do {
            try context.save()
        } catch {
            print("❌ Failed to save demo data: \(error)")
        }
    }

    private func getDemoPatient(from container: ModelContainer) -> Patient {
        let context = container.mainContext
        let descriptor = FetchDescriptor<Patient>()

        do {
            let patients = try context.fetch(descriptor)
            return patients.first ?? Patient(
                id: UUID(),
                name: "Demo Patient",
                dateOfBirth: Date(),
                gender: "Other",
                bloodType: "O+",
                emergencyContactName: "Emergency Contact",
                emergencyContactPhone: "555-0123",
                notes: "Fallback demo patient",
                createdAt: Date(),
                updatedAt: Date(),
                medicalCases: []
            )
        } catch {
            print("❌ Failed to fetch demo patient: \(error)")
            return Patient(
                id: UUID(),
                name: "Demo Patient",
                dateOfBirth: Date(),
                gender: "Other",
                bloodType: "O+",
                emergencyContactName: "Emergency Contact",
                emergencyContactPhone: "555-0123",
                notes: "Fallback demo patient",
                createdAt: Date(),
                updatedAt: Date(),
                medicalCases: []
            )
        }
    }
}

#Preview {
    DemoModeActivationSheet()
}