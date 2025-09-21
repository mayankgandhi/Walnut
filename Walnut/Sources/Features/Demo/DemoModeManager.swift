//
//  DemoModeManager.swift
//  Walnut
//
//  Created by Claude Code on 21/09/25.
//  Copyright © 2025 m. All rights reserved.
//

import Foundation
import SwiftData
import SwiftUI
import Observation

@Observable
public class DemoModeManager {

    public static let shared = DemoModeManager()

    private let userDefaults = UserDefaults.standard
    private let demoModeKey = "DemoModeEnabled"

    // MARK: - Properties

    public var isDemoModeEnabled: Bool {
        get {
            userDefaults.bool(forKey: demoModeKey)
        }
        set {
            userDefaults.set(newValue, forKey: demoModeKey)
            if newValue {
                enableDemoMode()
            } else {
                disableDemoMode()
            }
        }
    }

    public var showDemoModeSheet: Bool = false

    var demoPatient: Patient?

    // Demo patient identifier
    private let demoPatientName = "Alex Demo Patient"
    private let demoPatientIdentifier = "demo-patient-walnut-app"

    // MARK: - Initialization

    private init() {
        // Check if demo mode is enabled on startup
        if isDemoModeEnabled {
            setupDemoData()
        }
    }

    // MARK: - Demo Mode Control

    func enableDemoMode() {
        setupDemoData()
        NotificationCenter.default.post(name: .demoModeEnabled, object: nil)
    }

    func disableDemoMode() {
        clearDemoData()
        NotificationCenter.default.post(name: .demoModeDisabled, object: nil)
    }

    func toggleDemoMode() {
        isDemoModeEnabled.toggle()
    }

    func presentDemoModeSheet() {
        showDemoModeSheet = true
    }

    func dismissDemoModeSheet() {
        showDemoModeSheet = false
    }

    // MARK: - Demo Data Management

    private func setupDemoData() {
        // Demo data will be populated when model context is available
    }

    public func populateDemoData(in modelContext: ModelContext) {
        guard isDemoModeEnabled else { return }

        // Check if demo data already exists
        let descriptor = FetchDescriptor<Patient>()

        do {
            let existingPatients = try modelContext.fetch(descriptor)

            // Look for existing demo patient
            let existingDemoPatient = existingPatients.first { patient in
                (patient.name == demoPatientName) ||
                (patient.notes?.contains(demoPatientIdentifier) == true)
            }

            if let existingDemo = existingDemoPatient {
                // Demo data already exists, just update our reference
                self.demoPatient = existingDemo
                return
            }

            // Create demo patient and related data
            createDemoPatient(in: modelContext)
            createDemoMedicalCases(in: modelContext)
            createDemoPrescriptions(in: modelContext)
            createDemoBiomarkerReports(in: modelContext)

            // Save changes
            try modelContext.save()

        } catch {
            print("❌ Failed to populate demo data: \(error)")
        }
    }

    private func clearDemoData() {
        // Reset demo patient reference
        demoPatient = nil
    }

    public func clearDemoDataIfNeeded(in modelContext: ModelContext) {
        // Find and delete demo patients and all their related data
        let descriptor = FetchDescriptor<Patient>()

        do {
            let allPatients = try modelContext.fetch(descriptor)
            let demoPatients = allPatients.filter { patient in
                // Identify demo patients by name or notes containing the identifier
                (patient.name == demoPatientName) ||
                (patient.notes?.contains(demoPatientIdentifier) == true)
            }

            for demoPatient in demoPatients {
                // SwiftData will automatically handle cascade deletion for relationships
                // This will delete all associated medical cases, prescriptions, medications,
                // biomarker reports, etc. due to the @Relationship(deleteRule: .cascade) setup
                modelContext.delete(demoPatient)
            }

            // Save the changes
            try modelContext.save()

            // Clear our local reference
            self.demoPatient = nil

        } catch {
            print("❌ Failed to clear demo data: \(error)")
        }
    }

    // MARK: - Demo Patient Creation

    private func createDemoPatient(in modelContext: ModelContext) {
        let demoPatient = Patient(
            id: UUID(),
            name: demoPatientName,
            dateOfBirth: Calendar.current.date(byAdding: .year, value: -35, to: Date()) ?? Date(),
            gender: "Other",
            bloodType: "O+",
            emergencyContactName: "Jamie Contact",
            emergencyContactPhone: "+1 (555) 123-4567",
            notes: "\(demoPatientIdentifier) - This is a demo patient with sample health data for showcasing the Walnut app features.",
            createdAt: Date(),
            updatedAt: Date(),
            medicalCases: []
        )

        self.demoPatient = demoPatient
        modelContext.insert(demoPatient)
    }

    // MARK: - Demo Medical Cases

    private func createDemoMedicalCases(in modelContext: ModelContext) {
        guard let patient = demoPatient else { return }

        // Diabetes case
        let diabetesCase = MedicalCase(
            id: UUID(),
            title: "Type 2 Diabetes Management",
            notes: "Patient diagnosed with Type 2 diabetes in 2020. Currently managing with medication and lifestyle changes. Regular monitoring required.",
            type: .consultation,
            specialty: .endocrinologist,
            isActive: true,
            createdAt: Calendar.current.date(byAdding: .year, value: -3, to: Date()) ?? Date(),
            updatedAt: Date(),
            patient: patient,
            prescriptions: []
        )

        // Hypertension case
        let hypertensionCase = MedicalCase(
            id: UUID(),
            title: "Hypertension Monitoring",
            notes: "Mild hypertension detected during routine checkup. Monitoring blood pressure and implementing lifestyle modifications.",
            type: .consultation,
            specialty: .cardiologist,
            isActive: true,
            createdAt: Calendar.current.date(byAdding: .month, value: -8, to: Date()) ?? Date(),
            updatedAt: Date(),
            patient: patient,
            prescriptions: []
        )

        // Resolved case
        let resolvedCase = MedicalCase(
            id: UUID(),
            title: "Seasonal Allergies",
            notes: "Seasonal allergies successfully managed with antihistamines. Symptoms have resolved.",
            type: .consultation,
            specialty: .generalPractitioner,
            isActive: false,
            createdAt: Calendar.current.date(byAdding: .year, value: -1, to: Date()) ?? Date(),
            updatedAt: Calendar.current.date(byAdding: .month, value: -2, to: Date()) ?? Date(),
            patient: patient,
            prescriptions: []
        )

        patient.medicalCases = [diabetesCase, hypertensionCase, resolvedCase]

        modelContext.insert(diabetesCase)
        modelContext.insert(hypertensionCase)
        modelContext.insert(resolvedCase)
    }

    // MARK: - Demo Prescriptions

    private func createDemoPrescriptions(in modelContext: ModelContext) {
        guard let patient = demoPatient,
              let diabetesCase = patient.medicalCases?.first(where: { $0.title?.contains("Diabetes") == true }),
              let hypertensionCase = patient.medicalCases?.first(where: { $0.title?.contains("Hypertension") == true }) else { return }

        // Diabetes medications
        let metforminPrescription = createDemoPrescription(
            medicationName: "Metformin",
            dosage: "500mg",
            instructions: "Take twice daily with meals",
            frequency: [.daily(times: [
                DateComponents(hour: 8, minute: 0),
                DateComponents(hour: 20, minute: 0)
            ])],
            medicalCase: diabetesCase,
            in: modelContext
        )

        // Hypertension medication
        let lisinoprilPrescription = createDemoPrescription(
            medicationName: "Lisinopril",
            dosage: "10mg",
            instructions: "Take once daily in the morning",
            frequency: [.daily(times: [DateComponents(hour: 8, minute: 0)])],
            medicalCase: hypertensionCase,
            in: modelContext
        )

        // Vitamin supplement
        let vitaminPrescription = createDemoPrescription(
            medicationName: "Vitamin D3",
            dosage: "2000 IU",
            instructions: "Take once daily with food",
            frequency: [.daily(times: [DateComponents(hour: 9, minute: 0)])],
            medicalCase: diabetesCase,
            in: modelContext
        )

        diabetesCase.prescriptions = [metforminPrescription, vitaminPrescription]
        hypertensionCase.prescriptions = [lisinoprilPrescription]
    }

    private func createDemoPrescription(
        medicationName: String,
        dosage: String,
        instructions: String,
        frequency: [MedicationFrequency],
        medicalCase: MedicalCase,
        in modelContext: ModelContext
    ) -> Prescription {

        let prescription = Prescription(
            id: UUID(),
            followUpDate: nil,
            followUpTests: [],
            dateIssued: Calendar.current.date(byAdding: .day, value: -30, to: Date()) ?? Date(),
            doctorName: "Dr. Sarah Johnson",
            facilityName: "HealthCare Clinic",
            notes: "Demo prescription for \(medicationName)",
            document: nil,
            medicalCase: medicalCase,
            medications: [],
            createdAt: Date(),
            updatedAt: Date()
        )

        let medication = Medication(
            id: UUID(),
            name: medicationName,
            frequency: frequency,
            duration: nil,
            dosage: dosage,
            instructions: instructions,
            createdAt: Date(),
            updatedAt: Date(),
            patient: medicalCase.patient!,
            prescription: prescription
        )

        prescription.medications = [medication]

        modelContext.insert(prescription)
        modelContext.insert(medication)

        return prescription
    }

    // MARK: - Demo Biomarker Reports

    private func createDemoBiomarkerReports(in modelContext: ModelContext) {
        guard let patient = demoPatient else { return }

        // Recent blood work
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
            patient: patient,
            document: nil,
            testResults: []
        )

        // Create biomarker results
        let glucoseResult = createBiomarkerResult(
            testName: "Glucose",
            value: "145.0",
            unit: "mg/dL",
            referenceRange: "70-100 mg/dL",
            isAbnormal: true,
            report: recentReport,
            in: modelContext
        )

        let hba1cResult = createBiomarkerResult(
            testName: "Hemoglobin A1c",
            value: "7.2",
            unit: "%",
            referenceRange: "<7.0%",
            isAbnormal: true,
            report: recentReport,
            in: modelContext
        )

        let cholesterolResult = createBiomarkerResult(
            testName: "Total Cholesterol",
            value: "185.0",
            unit: "mg/dL",
            referenceRange: "<200 mg/dL",
            isAbnormal: false,
            report: recentReport,
            in: modelContext
        )

        recentReport.testResults = [glucoseResult, hba1cResult, cholesterolResult]

        // Older report for trend data
        let olderReport = BioMarkerReport(
            id: UUID(),
            testName: "Quarterly Diabetes Panel",
            labName: "Central Medical Lab",
            category: "Blood Chemistry",
            resultDate: Calendar.current.date(byAdding: .month, value: -3, to: Date()) ?? Date(),
            notes: "Quarterly diabetes monitoring",
            createdAt: Calendar.current.date(byAdding: .month, value: -3, to: Date()) ?? Date(),
            updatedAt: Calendar.current.date(byAdding: .month, value: -3, to: Date()) ?? Date(),
            medicalCase: nil,
            patient: patient,
            document: nil,
            testResults: []
        )

        let oldGlucoseResult = createBiomarkerResult(
            testName: "Glucose",
            value: "160.0",
            unit: "mg/dL",
            referenceRange: "70-100 mg/dL",
            isAbnormal: true,
            report: olderReport,
            in: modelContext
        )

        let oldHba1cResult = createBiomarkerResult(
            testName: "Hemoglobin A1c",
            value: "7.8",
            unit: "%",
            referenceRange: "<7.0%",
            isAbnormal: true,
            report: olderReport,
            in: modelContext
        )

        olderReport.testResults = [oldGlucoseResult, oldHba1cResult]

        modelContext.insert(recentReport)
        modelContext.insert(olderReport)
    }

    private func createBiomarkerResult(
        testName: String,
        value: String,
        unit: String,
        referenceRange: String,
        isAbnormal: Bool,
        report: BioMarkerReport,
        in modelContext: ModelContext
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

        modelContext.insert(result)
        return result
    }

    // MARK: - Demo Data Status

    public func demoDataExists(in modelContext: ModelContext) -> Bool {
        let descriptor = FetchDescriptor<Patient>()

        do {
            let allPatients = try modelContext.fetch(descriptor)
            return allPatients.contains { patient in
                (patient.name == demoPatientName) ||
                (patient.notes?.contains(demoPatientIdentifier) == true)
            }
        } catch {
            print("❌ Failed to check demo data existence: \(error)")
            return false
        }
    }

    public func getDemoPatientCount(in modelContext: ModelContext) -> Int {
        let descriptor = FetchDescriptor<Patient>()

        do {
            let allPatients = try modelContext.fetch(descriptor)
            return allPatients.filter { patient in
                (patient.name == demoPatientName) ||
                (patient.notes?.contains(demoPatientIdentifier) == true)
            }.count
        } catch {
            print("❌ Failed to get demo patient count: \(error)")
            return 0
        }
    }

    // MARK: - Force Clear Methods

    /// Force clear all demo data regardless of demo mode status
    /// Useful for cleanup or troubleshooting
    public func forceClearAllDemoData(in modelContext: ModelContext) {
        let descriptor = FetchDescriptor<Patient>()

        do {
            let allPatients = try modelContext.fetch(descriptor)
            let demoPatients = allPatients.filter { patient in
                (patient.name == demoPatientName) ||
                (patient.notes?.contains(demoPatientIdentifier) == true)
            }

            for demoPatient in demoPatients {
                modelContext.delete(demoPatient)
            }

            try modelContext.save()
            self.demoPatient = nil

        } catch {
            print("❌ Failed to force clear demo data: \(error)")
        }
    }
}

// MARK: - Notifications

public extension Notification.Name {
    static let demoModeEnabled = Notification.Name("demoModeEnabled")
    static let demoModeDisabled = Notification.Name("demoModeDisabled")
}
