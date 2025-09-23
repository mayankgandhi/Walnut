//
//  WelcomeScreen.swift
//  Walnut
//
//  Created by Claude on 11/09/25.
//  Copyright © 2025 m. All rights reserved.
//

import SwiftUI
import SwiftData
import WalnutDesignSystem

/// Welcome screen introducing the app's value proposition
struct WelcomeScreen: View {
    
    @Bindable var viewModel: OnboardingViewModel
    
    @State var showFeatures: Bool = false
    @State var showChildFeatures: Bool = false
    @State private var showDemoModeSheet = false
    @Namespace var animation
    
    var body: some View {
        
        VStack(alignment: .center, spacing: Spacing.medium) {
            
            Image("display-app-icon")
                .resizable()
                .scaledToFit()
                .frame(width: 96, height: 96)
                .onLongPressGesture(minimumDuration: 3.0) {
                    showDemoModeSheet = true
                    AnalyticsService.shared.track(.app(.featureUsed))
                }
            
            VStack(alignment: .center, spacing: Spacing.medium) {
                Text("HealthStack")
                    .font(.largeTitle.bold())
                    .foregroundStyle(.primary)
                
                Text("Your comprehensive health management companion")
                    .font(.title3)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)
            }
            
            if showFeatures {
                VStack(alignment: .center, spacing: Spacing.medium) {
                    featureItemView(icon: "ai-sparkle", title: "AI Powered", subtitle: "Automatically extract and organize your health data for easier access.")
                    featureItemView(icon: "graph", title: "Health Trends Tracker", subtitle: "Visualize your health journey with dynamic charts and trends. Stay informed, stay ahead.")
                    featureItemView(icon: "calendar", title: "Never Miss a Dose", subtitle: "Smart reminders for medications, appointments, and check-ups. Your health, always on track.")
                    featureItemView(icon: "journal", title: "Secure Health Vault", subtitle: "Store and organize all your health documents securely.")
                }
            } else {
                HStack(alignment: .center, spacing: Spacing.medium) {
                    Image("ai-sparkle")
                        .resizable()
                        .scaledToFit()
                        .matchedGeometryEffect(id: "ai-sparkle", in: animation)
                    Image("graph")
                        .resizable()
                        .scaledToFit()
                        .matchedGeometryEffect(id: "graph", in: animation)
                    Image("calendar")
                        .resizable()
                        .scaledToFit()
                        .matchedGeometryEffect(id: "calendar", in: animation)
                    
                    Image("journal")
                        .resizable()
                        .scaledToFit()
                        .matchedGeometryEffect(id: "journal", in: animation)
                }
            }
        }
        .padding(.horizontal, Spacing.medium)
        .task {
            try? await Task.sleep(nanoseconds: 500_000_000)
            withAnimation(.easeInOut(duration: 1.5)) {
                showFeatures = true
            }
        }
        .fullScreenCover(isPresented: $showDemoModeSheet) {
            DemoModeView()
        }
    }
    
    // MARK: - Demo Mode View
    
    // MARK: - Demo Environment
    
    @MainActor
    private class DemoEnvironment: ObservableObject {
        let container: ModelContainer
        let modelContext: ModelContext
        
        init(container: ModelContainer) {
            self.container = container
            self.modelContext = container.mainContext
        }
    }
    
    @MainActor
    private struct DemoModeView: View {
        @Environment(\.dismiss) private var dismiss
        @State private var demoModelContainer: ModelContainer?
        @State private var isLoading = true
        
        var body: some View {
            Group {
                if let container = demoModelContainer {
                    // Completely isolate the demo mode in its own environment
                    NavigationStack {
                        PatientTabView(patient: getDemoPatient(from: container))
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
                    .environmentObject(DemoEnvironment(container: container))
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
            // Create comprehensive demo patient
            let demoPatient = Patient(
                id: UUID(),
                name: "Alex Demo Patient",
                dateOfBirth: Calendar.current.date(byAdding: .year, value: -42, to: Date()) ?? Date(),
                gender: "Non-binary",
                bloodType: "O+",
                emergencyContactName: "Jamie Morgan (Partner)",
                emergencyContactPhone: "+1 (555) 123-4567",
                notes: "Comprehensive demo patient showcasing Walnut's full capabilities. Active lifestyle, works in tech. History of Type 2 diabetes, hypertension, and seasonal allergies. Regular exercise routine and careful dietary management.",
                createdAt: Calendar.current.date(byAdding: .year, value: -2, to: Date()) ?? Date(),
                updatedAt: Date(),
                medicalCases: []
            )
            
            context.insert(demoPatient)
            
            // Create multiple comprehensive medical cases
            let medicalCases = createDemoMedicalCases(for: demoPatient, in: context)
            demoPatient.medicalCases = medicalCases
            
            // Create comprehensive prescriptions and medications
            await createDemoMedications(for: demoPatient, cases: medicalCases, in: context)
            
            // Create comprehensive biomarker reports
            await createDemoBiomarkerReports(for: demoPatient, in: context)
            
            do {
                try context.save()
            } catch {
                print("❌ Failed to save demo data: \(error)")
            }
        }
        
        private func createDemoMedicalCases(for patient: Patient, in context: ModelContext) -> [MedicalCase] {
            var cases: [MedicalCase] = []
            
            // 1. Type 2 Diabetes Management (Active)
            let diabetesCase = MedicalCase(
                id: UUID(),
                title: "Type 2 Diabetes Management",
                notes: "Diagnosed January 2020 during routine screening. HbA1c was 8.2% at diagnosis. Currently well-controlled with metformin and lifestyle modifications. Patient shows excellent adherence to medication and dietary guidelines. Regular monitoring every 3 months. Last HbA1c: 6.8%. Target: <7.0%.",
                type: .consultation,
                specialty: .endocrinologist,
                isActive: true,
                createdAt: Calendar.current.date(byAdding: .year, value: -4, to: Date()) ?? Date(),
                updatedAt: Calendar.current.date(byAdding: .day, value: -14, to: Date()) ?? Date(),
                patient: patient,
                prescriptions: []
            )
            
            // 2. Hypertension Monitoring (Active)
            let hypertensionCase = MedicalCase(
                id: UUID(),
                title: "Essential Hypertension",
                notes: "Stage 1 hypertension discovered during annual physical exam. Average BP readings: 145/92 mmHg. Started on ACE inhibitor. Patient advised on DASH diet and regular exercise. Current BP well controlled: 128/82 mmHg. Continue current regimen.",
                type: .consultation,
                specialty: .cardiologist,
                isActive: true,
                createdAt: Calendar.current.date(byAdding: .month, value: -10, to: Date()) ?? Date(),
                updatedAt: Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date(),
                patient: patient,
                prescriptions: []
            )
            
            // 3. Annual Physical Exam (Active)
            let physicalCase = MedicalCase(
                id: UUID(),
                title: "Annual Physical Examination 2024",
                notes: "Comprehensive annual health assessment. Overall health status: Good. Weight stable, BMI 26.2. Blood pressure controlled. Diabetes management excellent. Recommended: Continue current medications, maintain exercise routine, annual eye exam, and podiatry follow-up.",
                type: .healthCheckup,
                specialty: .generalPractitioner,
                isActive: true,
                createdAt: Calendar.current.date(byAdding: .month, value: -2, to: Date()) ?? Date(),
                updatedAt: Calendar.current.date(byAdding: .month, value: -2, to: Date()) ?? Date(),
                patient: patient,
                prescriptions: []
            )
            
            // 4. Vitamin D Deficiency (Active)
            let vitaminDCase = MedicalCase(
                id: UUID(),
                title: "Vitamin D Deficiency",
                notes: "Routine screening revealed low vitamin D levels (18 ng/mL). Common in northern climates. Started on high-dose vitamin D3 supplementation. Recheck levels in 3 months. Patient reports improved energy levels since starting treatment.",
                type: .consultation,
                specialty: .generalPractitioner,
                isActive: true,
                createdAt: Calendar.current.date(byAdding: .month, value: -4, to: Date()) ?? Date(),
                updatedAt: Calendar.current.date(byAdding: .month, value: -1, to: Date()) ?? Date(),
                patient: patient,
                prescriptions: []
            )
            
            // 5. Seasonal Allergies (Resolved)
            let allergiesCase = MedicalCase(
                id: UUID(),
                title: "Seasonal Allergic Rhinitis",
                notes: "Spring pollen allergies affecting quality of life. Symptoms: sneezing, nasal congestion, watery eyes. Managed successfully with antihistamines and nasal corticosteroids during allergy season. Patient well-educated on environmental controls.",
                type: .consultation,
                specialty: .generalPractitioner,
                isActive: false,
                createdAt: Calendar.current.date(byAdding: .year, value: -1, to: Date()) ?? Date(),
                updatedAt: Calendar.current.date(byAdding: .month, value: -6, to: Date()) ?? Date(),
                patient: patient,
                prescriptions: []
            )
            
            // 6. Minor Injury - Ankle Sprain (Resolved)
            let injuryCase = MedicalCase(
                id: UUID(),
                title: "Left Ankle Sprain",
                notes: "Grade II lateral ankle sprain sustained during hiking. Initial treatment: RICE protocol, NSAIDs for pain. Physical therapy 6 weeks. Full recovery achieved. Patient cleared for all activities. Provided education on injury prevention.",
                type: .consultation,
                specialty: .orthopedicSurgeon,
                isActive: false,
                createdAt: Calendar.current.date(byAdding: .month, value: -8, to: Date()) ?? Date(),
                updatedAt: Calendar.current.date(byAdding: .month, value: -6, to: Date()) ?? Date(),
                patient: patient,
                prescriptions: []
            )
            
            // 7. COVID-19 Vaccination (Completed)
            let covidVaxCase = MedicalCase(
                id: UUID(),
                title: "COVID-19 Vaccination Series",
                notes: "Completed primary vaccination series and boosters as recommended. Last booster: Updated bivalent vaccine. No adverse reactions. Patient counseled on continued preventive measures and symptoms to monitor.",
                type: .immunisation,
                specialty: .generalPractitioner,
                isActive: false,
                createdAt: Calendar.current.date(byAdding: .month, value: -6, to: Date()) ?? Date(),
                updatedAt: Calendar.current.date(byAdding: .month, value: -6, to: Date()) ?? Date(),
                patient: patient,
                prescriptions: []
            )
            
            cases = [diabetesCase, hypertensionCase, physicalCase, vitaminDCase, allergiesCase, injuryCase, covidVaxCase]
            
            for medicalCase in cases {
                context.insert(medicalCase)
            }
            
            return cases
        }
        
        private func createDemoMedications(for patient: Patient, cases: [MedicalCase], in context: ModelContext) async {
            guard let diabetesCase = cases.first(where: { $0.title?.contains("Diabetes") == true }),
                  let hypertensionCase = cases.first(where: { $0.title?.contains("Hypertension") == true }),
                  let vitaminDCase = cases.first(where: { $0.title?.contains("Vitamin D") == true }),
                  let allergiesCase = cases.first(where: { $0.title?.contains("Allergies") == true }) else { return }
            
            // Diabetes Medications
            let metforminPrescription = createPrescription(
                medicationName: "Metformin ER",
                dosage: "500mg",
                instructions: "Take twice daily with meals to reduce GI upset",
                frequency: [.daily(times: [
                    DateComponents(hour: 8, minute: 0),
                    DateComponents(hour: 20, minute: 0)
                ])],
                doctorName: "Dr. Sarah Johnson, MD",
                facilityName: "Endocrine Associates",
                medicalCase: diabetesCase,
                daysAgo: 90,
                in: context
            )
            
            // Hypertension Medication
            let lisinoprilPrescription = createPrescription(
                medicationName: "Lisinopril",
                dosage: "10mg",
                instructions: "Take once daily in the morning, preferably at the same time",
                frequency: [.daily(times: [DateComponents(hour: 8, minute: 0)])],
                doctorName: "Dr. Michael Chen, MD",
                facilityName: "Cardiology Center",
                medicalCase: hypertensionCase,
                daysAgo: 120,
                in: context
            )
            
            // Vitamin D Supplement
            let vitaminDPrescription = createPrescription(
                medicationName: "Vitamin D3 (Cholecalciferol)",
                dosage: "4000 IU",
                instructions: "Take once daily with food for better absorption",
                frequency: [.daily(times: [DateComponents(hour: 9, minute: 0)])],
                doctorName: "Dr. Emily Rodriguez, MD",
                facilityName: "Primary Care Associates",
                medicalCase: vitaminDCase,
                daysAgo: 60,
                in: context
            )
            
            // Omega-3 Supplement (General health)
            let omega3Prescription = createPrescription(
                medicationName: "Omega-3 Fish Oil",
                dosage: "1000mg",
                instructions: "Take twice daily with meals",
                frequency: [.daily(times: [
                    DateComponents(hour: 8, minute: 0),
                    DateComponents(hour: 18, minute: 0)
                ])],
                doctorName: "Dr. Emily Rodriguez, MD",
                facilityName: "Primary Care Associates",
                medicalCase: diabetesCase,
                daysAgo: 45,
                in: context
            )
            
            // Allergy Medication (Seasonal - as needed)
            let allergyPrescription = createPrescription(
                medicationName: "Cetirizine (Zyrtec)",
                dosage: "10mg",
                instructions: "Take once daily during allergy season or as needed",
                frequency: [.daily(times: [DateComponents(hour: 8, minute: 0)])],
                doctorName: "Dr. Lisa Park, MD",
                facilityName: "Allergy & Asthma Clinic",
                medicalCase: allergiesCase,
                daysAgo: 180,
                in: context
            )
            
            // Multivitamin (Daily wellness)
            let multivitaminPrescription = createPrescription(
                medicationName: "Adult Multivitamin",
                dosage: "1 tablet",
                instructions: "Take once daily with breakfast",
                frequency: [.daily(times: [DateComponents(hour: 8, minute: 0)])],
                doctorName: "Dr. Emily Rodriguez, MD",
                facilityName: "Primary Care Associates",
                medicalCase: vitaminDCase,
                daysAgo: 30,
                in: context
            )
            
            // Update medical cases with prescriptions
            diabetesCase.prescriptions = [metforminPrescription, omega3Prescription]
            hypertensionCase.prescriptions = [lisinoprilPrescription]
            vitaminDCase.prescriptions = [vitaminDPrescription, multivitaminPrescription]
            allergiesCase.prescriptions = [allergyPrescription]
        }
        
        private func createPrescription(
            medicationName: String,
            dosage: String,
            instructions: String,
            frequency: [MedicationFrequency],
            doctorName: String,
            facilityName: String,
            medicalCase: MedicalCase,
            daysAgo: Int,
            in context: ModelContext
        ) -> Prescription {
            
            let prescription = Prescription(
                id: UUID(),
                followUpDate: Calendar.current.date(byAdding: .month, value: 3, to: Date()),
                followUpTests: [],
                dateIssued: Calendar.current.date(byAdding: .day, value: -daysAgo, to: Date()) ?? Date(),
                doctorName: doctorName,
                facilityName: facilityName,
                notes: "Demo prescription for \(medicationName). Patient counseled on proper usage and potential side effects.",
                document: nil,
                medicalCase: medicalCase,
                medications: [],
                createdAt: Calendar.current.date(byAdding: .day, value: -daysAgo, to: Date()) ?? Date(),
                updatedAt: Date()
            )
            
            let medication = Medication(
                id: UUID(),
                name: medicationName,
                frequency: frequency,
                duration: nil,
                dosage: dosage,
                instructions: instructions,
                createdAt: Calendar.current.date(byAdding: .day, value: -daysAgo, to: Date()) ?? Date(),
                updatedAt: Date(),
                patient: medicalCase.patient!,
                prescription: prescription
            )
            
            prescription.medications = [medication]
            
            context.insert(prescription)
            context.insert(medication)
            
            return prescription
        }
        
        private func createDemoBiomarkerReports(for patient: Patient, in context: ModelContext) async {
            // Recent Comprehensive Metabolic Panel
            let recentCMP = BioMarkerReport(
                id: UUID(),
                testName: "Comprehensive Metabolic Panel (CMP)",
                labName: "Quest Diagnostics",
                category: "Blood Chemistry",
                resultDate: Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date(),
                notes: "Routine follow-up labs for diabetes and hypertension management. Overall results show good disease control.",
                createdAt: Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date(),
                updatedAt: Date(),
                medicalCase: nil,
                patient: patient,
                document: nil,
                testResults: []
            )
            
            let cmpResults = [
                createBiomarkerResult("Glucose", "142", "mg/dL", "70-100", true, recentCMP, context),
                createBiomarkerResult("BUN", "18", "mg/dL", "7-20", false, recentCMP, context),
                createBiomarkerResult("Creatinine", "0.9", "mg/dL", "0.7-1.3", false, recentCMP, context),
                createBiomarkerResult("eGFR", ">60", "mL/min/1.73m²", ">60", false, recentCMP, context),
                createBiomarkerResult("Sodium", "140", "mEq/L", "136-145", false, recentCMP, context),
                createBiomarkerResult("Potassium", "4.2", "mEq/L", "3.5-5.1", false, recentCMP, context),
                createBiomarkerResult("Chloride", "102", "mEq/L", "98-107", false, recentCMP, context),
                createBiomarkerResult("CO2", "24", "mEq/L", "22-28", false, recentCMP, context)
            ]
            recentCMP.testResults = cmpResults
            
            // HbA1c Test
            let hba1cReport = BioMarkerReport(
                id: UUID(),
                testName: "Hemoglobin A1c",
                labName: "Quest Diagnostics",
                category: "Diabetes Monitoring",
                resultDate: Calendar.current.date(byAdding: .day, value: -14, to: Date()) ?? Date(),
                notes: "Excellent diabetes control. Continue current management plan.",
                createdAt: Calendar.current.date(byAdding: .day, value: -14, to: Date()) ?? Date(),
                updatedAt: Date(),
                medicalCase: nil,
                patient: patient,
                document: nil,
                testResults: []
            )
            
            let hba1cResult = createBiomarkerResult("Hemoglobin A1c", "6.8", "%", "<7.0", false, hba1cReport, context)
            hba1cReport.testResults = [hba1cResult]
            
            // Lipid Panel
            let lipidReport = BioMarkerReport(
                id: UUID(),
                testName: "Lipid Panel",
                labName: "LabCorp",
                category: "Cardiovascular Risk",
                resultDate: Calendar.current.date(byAdding: .month, value: -1, to: Date()) ?? Date(),
                notes: "Lipid levels within target ranges for diabetic patient. Continue statin therapy.",
                createdAt: Calendar.current.date(byAdding: .month, value: -1, to: Date()) ?? Date(),
                updatedAt: Date(),
                medicalCase: nil,
                patient: patient,
                document: nil,
                testResults: []
            )
            
            let lipidResults = [
                createBiomarkerResult("Total Cholesterol", "185", "mg/dL", "<200", false, lipidReport, context),
                createBiomarkerResult("LDL Cholesterol", "95", "mg/dL", "<100", false, lipidReport, context),
                createBiomarkerResult("HDL Cholesterol", "52", "mg/dL", ">40", false, lipidReport, context),
                createBiomarkerResult("Triglycerides", "128", "mg/dL", "<150", false, lipidReport, context)
            ]
            lipidReport.testResults = lipidResults
            
            // Vitamin D Test
            let vitaminDReport = BioMarkerReport(
                id: UUID(),
                testName: "25-Hydroxyvitamin D",
                labName: "Quest Diagnostics",
                category: "Nutritional Status",
                resultDate: Calendar.current.date(byAdding: .month, value: -2, to: Date()) ?? Date(),
                notes: "Significant improvement from baseline (18 ng/mL). Continue supplementation.",
                createdAt: Calendar.current.date(byAdding: .month, value: -2, to: Date()) ?? Date(),
                updatedAt: Date(),
                medicalCase: nil,
                patient: patient,
                document: nil,
                testResults: []
            )
            
            let vitaminDResult = createBiomarkerResult("25-Hydroxyvitamin D", "35", "ng/mL", "30-100", false, vitaminDReport, context)
            vitaminDReport.testResults = [vitaminDResult]
            
            // Complete Blood Count
            let cbcReport = BioMarkerReport(
                id: UUID(),
                testName: "Complete Blood Count (CBC)",
                labName: "LabCorp",
                category: "Hematology",
                resultDate: Calendar.current.date(byAdding: .month, value: -3, to: Date()) ?? Date(),
                notes: "All values within normal limits. No evidence of anemia or infection.",
                createdAt: Calendar.current.date(byAdding: .month, value: -3, to: Date()) ?? Date(),
                updatedAt: Date(),
                medicalCase: nil,
                patient: patient,
                document: nil,
                testResults: []
            )
            
            let cbcResults = [
                createBiomarkerResult("WBC", "6.8", "K/uL", "4.0-11.0", false, cbcReport, context),
                createBiomarkerResult("RBC", "4.5", "M/uL", "4.5-5.9", false, cbcReport, context),
                createBiomarkerResult("Hemoglobin", "14.2", "g/dL", "14.0-18.0", false, cbcReport, context),
                createBiomarkerResult("Hematocrit", "42.1", "%", "42.0-52.0", false, cbcReport, context),
                createBiomarkerResult("Platelets", "285", "K/uL", "150-450", false, cbcReport, context)
            ]
            cbcReport.testResults = cbcResults
            
            // Historical HbA1c for trends
            let historicalHba1c = BioMarkerReport(
                id: UUID(),
                testName: "Hemoglobin A1c",
                labName: "Quest Diagnostics",
                category: "Diabetes Monitoring",
                resultDate: Calendar.current.date(byAdding: .month, value: -6, to: Date()) ?? Date(),
                notes: "Improved from previous value. Medication and lifestyle changes effective.",
                createdAt: Calendar.current.date(byAdding: .month, value: -6, to: Date()) ?? Date(),
                updatedAt: Calendar.current.date(byAdding: .month, value: -6, to: Date()) ?? Date(),
                medicalCase: nil,
                patient: patient,
                document: nil,
                testResults: []
            )
            
            let historicalHba1cResult = createBiomarkerResult("Hemoglobin A1c", "7.4", "%", "<7.0", true, historicalHba1c, context)
            historicalHba1c.testResults = [historicalHba1cResult]
            
            let reports = [recentCMP, hba1cReport, lipidReport, vitaminDReport, cbcReport, historicalHba1c]
            for report in reports {
                context.insert(report)
            }
        }
        
        private func createBiomarkerResult(
            _ testName: String,
            _ value: String,
            _ unit: String,
            _ referenceRange: String,
            _ isAbnormal: Bool,
            _ report: BioMarkerReport,
            _ context: ModelContext
        ) -> BioMarkerResult {
            let result = BioMarkerResult(
                id: UUID(),
                testName: testName,
                value: value,
                unit: unit,
                referenceRange: referenceRange,
                isAbnormal: isAbnormal,
                bloodReport: report
            )
            
            context.insert(result)
            return result
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
    
    func featureItemView(
        icon: String,
        title: String,
        subtitle: String
    ) -> some View {
        Group {
            if showChildFeatures {
                HStack(alignment: .center, spacing: Spacing.medium) {
                    Image(icon)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 64, height: 64)
                        .matchedGeometryEffect(id: icon, in: animation)
                    
                    VStack(alignment: .leading, spacing: Spacing.xs) {
                        Text(title)
                            .font(.headline.bold())
                            .foregroundStyle(.primary)
                        
                        Text(subtitle)
                            .font(.caption.weight(.light))
                            .foregroundStyle(.primary)
                    }
                    
                }
                .padding(Spacing.small)
                .frame(maxWidth: .infinity, alignment: .leading)
                .subtleCardStyle()
            } else {
                Image(icon)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 64, height: 64)
                    .matchedGeometryEffect(id: icon, in: animation)
                    .padding(.horizontal, Spacing.medium)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .task {
            try? await Task.sleep(nanoseconds: 2_000_000_000)
            withAnimation(.easeInOut(duration: 0.5)) {
                showChildFeatures = true
            }
        }
    }
}



// MARK: - Preview
#Preview {
    NavigationStack {
        WelcomeScreen(viewModel: OnboardingViewModel())
    }
}
