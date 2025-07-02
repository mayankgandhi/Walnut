//
//  MedicalCaseType.swift
//  Walnut-Playground
//
//  Created by Mayank Gandhi on 29/06/25.
//  Copyright © 2025 m. All rights reserved.
//


// MARK: - Enums for type safety
enum MedicalCaseType: String, CaseIterable {
    case immunisation = "immunisation"
    case healthCheckup = "health-checkup"
    case surgery = "surgery"
    case consultation = "consultation"
    case procedure = "procedure"
    
    var displayName: String {
        switch self {
        case .immunisation: return "Immunisation"
        case .healthCheckup: return "Health Check-up"
        case .surgery: return "Surgery"
        case .consultation: return "Consultation"
        case .procedure: return "Procedure"
        }
    }
}

enum MedicalSpecialty: String, CaseIterable {
    case generalPractitioner = "General Practitioner"
    case cardiologist = "Cardiologist"
    case endocrinologist = "Endocrinologist"
    case orthopedicSurgeon = "Orthopedic Surgeon"
    case psychiatrist = "Psychiatrist"
    case ophthalmologist = "Ophthalmologist"
    case oncologist = "Oncologist"
    case pediatrician = "Pediatrician"
    case dermatologist = "Dermatologist"
    case neurologist = "Neurologist"
    case gastroenterologist = "Gastroenterologist"
    case pulmonologist = "Pulmonologist"
    case urologist = "Urologist"
    case gynecologist = "Gynecologist"
    case rheumatologist = "Rheumatologist"
}
