//
//  TimelineEventProviders.swift
//  Walnut
//
//  Created by Mayank Gandhi on 22/08/25.
//  Copyright © 2025 m. All rights reserved.
//

import SwiftUI
import WalnutDesignSystem

// MARK: - Patient Timeline Event Provider

struct PatientTimelineEventProvider: TimelineEventProvider {
    let patient: Patient
    
    func generateTimelineEvents() -> [TimelineEvent] {
        var events: [TimelineEvent] = []
        
        // Patient creation event
        events.append(TimelineEvent(
            icon: "person.badge.plus.fill",
            color: .healthPrimary,
            title: "Patient Registered",
            subtitle: "Added to medical system",
            date: patient.createdAt
        ))
        
        // Medical cases events
        let caseEvents = patient.medicalCases
            .sorted(by: { $0.createdAt < $1.createdAt })
            .map { medicalCase in
                TimelineEvent(
                    icon: "folder.badge.plus.fill",
                    color: medicalCase.specialty.color,
                    title: "New Medical Case",
                    subtitle: "\(medicalCase.specialty.rawValue) - \(medicalCase.title)",
                    date: medicalCase.createdAt
                )
            }
        events.append(contentsOf: caseEvents)
        
        return events
    }
}

// MARK: - Document Timeline Event Provider

struct DocumentTimelineEventProvider: TimelineEventProvider {
    let documents: [Document]
    
    func generateTimelineEvents() -> [TimelineEvent] {
        return documents
            .sorted(by: { $0.createdAt < $1.createdAt })
            .map { document in
                TimelineEvent(
                    icon: documentIcon(for: document.documentType),
                    color: documentColor(for: document.documentType),
                    title: "Document Added",
                    subtitle: "\(document.documentType.rawValue) - \(document.fileName)",
                    date: document.createdAt
                )
            }
    }
    
    private func documentIcon(for type: DocumentType) -> String {
        type.typeIcon
    }
    
    private func documentColor(for type: DocumentType) -> Color {
        type.color
    }
}

// MARK: - Prescription Timeline Event Provider

struct PrescriptionTimelineEventProvider: TimelineEventProvider {
    let prescriptions: [Prescription]
    
    func generateTimelineEvents() -> [TimelineEvent] {
        return prescriptions
            .sorted(by: { $0.dateIssued < $1.dateIssued })
            .map { prescription in
                let medicationCount = prescription.medications.count
                let subtitle = medicationCount == 1 ? 
                    "1 medication prescribed" : 
                    "\(medicationCount) medications prescribed"
                
                return TimelineEvent(
                    icon: "pills.fill",
                    color: .blue,
                    title: "Prescription Issued",
                    subtitle: prescription.doctorName.map { "\($0) - \(subtitle)" } ?? subtitle,
                    date: prescription.dateIssued
                )
            }
    }
}
