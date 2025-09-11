//
//  MedicalCaseDummyData.swift
//  Walnut-Playground
//
//  Created by Mayank Gandhi on 29/06/25.
//  Copyright © 2025 m. All rights reserved.
//

import Foundation
import SwiftData

@Model
class MedicalCase: Identifiable, Sendable {
    
    var id: UUID?
    
    var title: String?
    var notes: String?
    var type: MedicalCaseType? // immunisation, health-checkup, surgery, follow-up, treatment, diagnosis
    var specialty: MedicalSpecialty? // Cardiologist, Endocrinologist, etc.
    var isActive: Bool?
    
    var createdAt: Date?
    var updatedAt: Date?
  
    var patient: Patient?
    
    @Relationship(deleteRule: .cascade, inverse: \Prescription.medicalCase)
    var prescriptions: [Prescription]? = []
    
    @Relationship(deleteRule: .cascade, inverse: \BloodReport.medicalCase)
    var bloodReports: [BloodReport]? = []
    
    @Relationship(deleteRule: .cascade, inverse: \Document.medicalCase)
    var unparsedDocuments: [Document]? = []
    
    @Relationship(deleteRule: .cascade, inverse: \Document.medicalCase)
    var otherDocuments: [Document]? = []
    
    init(id: UUID,
         title: String,
         notes: String,
         type: MedicalCaseType,
         specialty: MedicalSpecialty,
         isActive: Bool,
         createdAt: Date,
         updatedAt: Date,
         patient: Patient? = nil,
         prescriptions: [Prescription] = [],
         bloodReports: [BloodReport] = [],
         unparsedDocuments: [Document] = []) {
        self.id = id
        self.title = title
        self.notes = notes
        self.type = type
        self.specialty = specialty
        self.isActive = isActive
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.patient = patient
        self.prescriptions = prescriptions
        self.bloodReports = bloodReports
        self.unparsedDocuments = unparsedDocuments
    }
    
    init(
        chronicCondition: ChronicCondition,
        patient: Patient
    ) {
        self.id = UUID()
        self.title = chronicCondition.rawValue
        self.notes = nil
        self.type = .consultation
        self.specialty = chronicCondition.specialty
        self.isActive = true
        self.createdAt = Date()
        self.updatedAt = Date()
        self.patient = patient
        self.prescriptions = []
        self.bloodReports = []
        self.unparsedDocuments = []
    }
    
}

// MARK: - Extension for easy access
extension MedicalCase {
    
    @MainActor
    static var sampleCase =  MedicalCase(
        id: UUID(),
        title: "Hypertension",
        notes: "Patient presents with elevated blood pressure readings over the past 3 months. Family history of cardiovascular disease. Currently experiencing mild headaches and occasional dizziness. Diagnosed with Stage 1 hypertension. Started on ACE inhibitor therapy with good response. Regular follow-ups show gradual improvement.",
        type: .healthCheckup,
        specialty: .cardiologist,
        isActive: true,
        createdAt: Date().addingTimeInterval(-2_592_000), // 30 days ago
        updatedAt: Date().addingTimeInterval(-86_400), // 1 day ago
        patient: .samplePatient,
        prescriptions: []
    )
    
    static func predicate(
        patientID: UUID,
    ) -> Predicate<MedicalCase> {
        return #Predicate<MedicalCase> { medicalCase in
            medicalCase.patient?.id == patientID
        }
    }
}


