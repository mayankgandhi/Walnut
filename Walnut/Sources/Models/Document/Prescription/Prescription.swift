//
//  Prescription.swift
//  Walnut
//
//  Created by Mayank Gandhi on 11/07/25.
//  Copyright © 2025 m. All rights reserved.
//

import SwiftData
import Foundation

@Model
class Prescription: Sendable {
    
    var id: UUID?
    
    // Metadata
    var dateIssued: Date?
    var doctorName: String?
    var facilityName: String?
    
    var followUpDate: Date?
    var followUpTests: [String]?
        
    var notes: String?
    
    var createdAt: Date?
    var updatedAt: Date?
    
    var medicalCase: MedicalCase?
    
    @Relationship(deleteRule: .cascade, inverse: \Document.prescription)
    var document: Document?
    
    @Relationship(deleteRule: .cascade, inverse: \Medication.prescription)
    var medications: [Medication]?
    
    init(
        id: UUID,
        followUpDate: Date? = nil,
        followUpTests: [String], dateIssued: Date,
        doctorName: String? = nil,
        facilityName: String? = nil,
        notes: String? = nil,
        document: Document?,
        medicalCase: MedicalCase,
        medications: [Medication],
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.followUpDate = followUpDate
        self.followUpTests = followUpTests
        self.dateIssued = dateIssued
        self.doctorName = doctorName
        self.facilityName = facilityName
        self.notes = notes
        self.document = document
        self.medicalCase = medicalCase
        self.medications = medications
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
    
    convenience init(
        parsedPrescription: ParsedPrescription,
        medicalCase: MedicalCase,
        fileURL: URL
    ) {
        // Calculate actual file size
        let fileSize = (try? FileManager.default.attributesOfItem(atPath: fileURL.path)[.size] as? Int64) ?? 0
        
        self.init(
            id: UUID(),
            followUpDate: parsedPrescription.followUpDate,
            followUpTests: parsedPrescription.followUpTests,
            dateIssued: parsedPrescription.dateIssued,
            doctorName: parsedPrescription.doctorName,
            facilityName: parsedPrescription.facilityName,
            notes: parsedPrescription.notes,
            document: Document(
                fileName: fileURL.lastPathComponent,
                fileURL: fileURL.lastPathComponent,
                documentType: .prescription,
                fileSize: fileSize
            ),
            medicalCase: medicalCase,
            medications: parsedPrescription.medications.map({ medication in
                Medication(
                    id: medication.id,
                    name: medication.name,
                    frequency: medication.frequency?.compactMap ({ dto in
                        dto.toEnum()
                    }),
                    duration: medication.duration.toEnum(),
                    dosage: medication.dosage,
                    instructions: medication.instructions,
                    patient: .samplePatient
                )
            })
        )
    }
    
}

// MARK: - Sample Data
extension Prescription {
    
    @MainActor
    static func samplePrescription(for medicalCase: MedicalCase) -> Prescription {
        let sampleFileURL = URL(
            fileURLWithPath: "/tmp/sample_prescription.pdf"
        ).absoluteString
        
        let sampleMedications = [
            Medication(
                id: UUID(),
                name: "Amoxicillin",
                frequency: [],
                duration: .days(7),
                dosage: "500mg",
                instructions: "Take with food to reduce stomach upset",
                patient: .samplePatient
            ),
            Medication(
                id: UUID(),
                name: "Ibuprofen",
                frequency: [],
                duration: .days(5),
                dosage: "400mg",
                instructions: "Take as needed for pain. Do not exceed 1200mg per day",
                patient: .samplePatient
            )
        ]
        
        let document = Document(
            fileName: "Dr_Smith_Prescription.pdf",
            fileURL: sampleFileURL,
            documentType: .prescription,
            fileSize: 156780 // ~153KB
        )
        
        return Prescription(
            id: UUID(),
            followUpDate: Date().addingTimeInterval(86400 * 14), // 2 weeks from now
            followUpTests: ["Blood pressure check", "Kidney function test"],
            dateIssued: Date().addingTimeInterval(-86400 * 2), // 2 days ago
            doctorName: "Dr. Sarah Smith",
            facilityName: "City Medical Center",
            notes: "Continue current medications. Return if symptoms persist or worsen.",
            document: document,
            medicalCase: medicalCase,
            medications: sampleMedications
        )
    }
    
    @MainActor
    static func sampleChronicPrescription(for medicalCase: MedicalCase) -> Prescription {
        let sampleFileURL = URL(fileURLWithPath: "/tmp/chronic_prescription.pdf")
        
        let chronicMedications = [
            Medication(
                id: UUID(),
                name: "Lisinopril",
                frequency: [],
                duration: .days(90),
                dosage: "10mg",
                instructions: "Take at the same time each day for blood pressure control",
                patient: .samplePatient
            ),
            Medication(
                id: UUID(),
                name: "Metformin",
                frequency: [],
                duration: .days(90),
                dosage: "500mg",
                instructions: "Take with meals to control blood sugar levels",
                patient: .samplePatient
            )
        ]
        
        let document = Document(
            fileName: "Dr_Johnson_Chronic_Care.pdf",
            fileURL: sampleFileURL.absoluteString,
            documentType: .prescription,
            fileSize: 198432 // ~194KB
        )
        
        return Prescription(
            id: UUID(),
            followUpDate: Date().addingTimeInterval(86400 * 90), // 3 months from now
            followUpTests: ["HbA1c", "Blood pressure monitoring", "Kidney function"],
            dateIssued: Date().addingTimeInterval(-86400 * 7), // 1 week ago
            doctorName: "Dr. Michael Johnson",
            facilityName: "Downtown Health Clinic",
            notes: "Chronic care management. Continue medications as prescribed. Monitor blood sugar daily.",
            document: document,
            medicalCase: medicalCase,
            medications: chronicMedications
        )
    }
    
}

