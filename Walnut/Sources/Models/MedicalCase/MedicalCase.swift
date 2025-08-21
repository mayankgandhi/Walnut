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
    
    @Attribute(.unique)
    var id: UUID
    
    var title: String
    var notes: String
    var treatmentPlan: String
    var type: MedicalCaseType // immunisation, health-checkup, surgery, follow-up, treatment, diagnosis
    var specialty: MedicalSpecialty // Cardiologist, Endocrinologist, etc.
    var isActive: Bool
    
    var createdAt: Date
    var updatedAt: Date
  
    var patient: Patient
    
    @Relationship(deleteRule: .cascade)
    var prescriptions: [Prescription] = []
    
    @Relationship(deleteRule: .cascade)
    var bloodReports: [BloodReport] = []
    
    @Relationship(deleteRule: .cascade)
    var unparsedDocuments: [Document] = []
    
    init(id: UUID,
         title: String,
         notes: String,
         treatmentPlan: String,
         type: MedicalCaseType,
         specialty: MedicalSpecialty,
         isActive: Bool,
         createdAt: Date,
         updatedAt: Date,
         patient: Patient,
         prescriptions: [Prescription] = [],
         bloodReports: [BloodReport] = [],
         unparsedDocuments: [Document] = []) {
        self.id = id
        self.title = title
        self.notes = notes
        self.treatmentPlan = treatmentPlan
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
    
}

// MARK: - Extension for easy access
extension MedicalCase {
    
    @MainActor
    static var sampleCase =  MedicalCase(
        id: UUID(),
        title: "Hypertension Management",
        notes: "Patient presents with elevated blood pressure readings over the past 3 months. Family history of cardiovascular disease. Currently experiencing mild headaches and occasional dizziness. Diagnosed with Stage 1 hypertension. Started on ACE inhibitor therapy with good response. Regular follow-ups show gradual improvement.",
        treatmentPlan: "1. Start ACE inhibitor (Lisinopril 10mg daily)\n2. Dietary modifications - reduce sodium intake\n3. Regular exercise 30min/day\n4. Weight management\n5. Follow-up in 4 weeks",
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
            medicalCase.patient.id == patientID
        }
    }
}


