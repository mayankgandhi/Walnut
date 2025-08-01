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
class Prescription {
    
    @Attribute(.unique)
    var id: UUID
    
    // Metadata
    var dateIssued: Date
    var doctorName: String?
    var facilityName: String?
    
    var followUpDate: Date?
    var followUpTests: [String]?
        
    var notes: String?
    
    var createdAt: Date
    var updatedAt: Date
    
    @Relationship(inverse: \MedicalCase.prescriptions)
    var medicalCase: MedicalCase
    
    @Relationship(deleteRule: .cascade)
    var document: Document?
    
    @Relationship(deleteRule: .cascade, inverse: \Medication.prescription)
    var medications: [Medication]
    
    init(
        id: UUID,
        followUpDate: Date? = nil,
        followUpTests: [String], dateIssued: Date,
        doctorName: String? = nil,
        facilityName: String? = nil,
        notes: String? = nil,
        document: Document,
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
        self.init(
            id: UUID(),
            followUpDate: parsedPrescription.followUpDate,
            followUpTests: parsedPrescription.followUpTests,
            dateIssued: parsedPrescription.dateIssued,
            doctorName: parsedPrescription.doctorName,
            facilityName: parsedPrescription.facilityName,
            notes: parsedPrescription.notes,
            document: Document(
                fileName: "\(parsedPrescription.doctorName)_\(medicalCase.title)_prescription",
                fileURL: fileURL,
                documentType: .prescription,
                fileSize: 12
            ),
            medicalCase: medicalCase,
            medications: parsedPrescription.medications.map({ medication in
                Medication(
                    id: medication.id,
                    name: medication.name,
                    frequency: medication.frequency,
                    numberOfDays: medication.numberOfDays
                )
            })
        )
    }
    
}

