//
//  MedicalSpecialty.swift
//  Walnut-Playground
//
//  Created by Mayank Gandhi on 02/07/25.
//  Copyright © 2025 m. All rights reserved.
//

import Foundation
import SwiftUI

enum MedicalSpecialty: String, CaseIterable, Hashable, Codable, Sendable {
    
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
    case dentist = "Dentist"
    
    var icon: String {
        switch self {
        case .generalPractitioner:
            return "generalPractitioner.png"
        case .cardiologist:
            return "cardiologist.png"
        case .endocrinologist:
            return "endocrinologist.png"
        case .rheumatologist:
            return "rheumatologist.png"
        case .dermatologist:
            return "dermatologist.png"
        case .pediatrician:
            return "pediatrician.png"
        case .urologist:
            return "urologist.png"
        case .dentist:
            return "dentist.png"
        case .oncologist:
            return "oncologist.png"
        case .pulmonologist:
            return "pulmonologist.png"
        case .ophthalmologist:
            return "ophthalmologist.png"
        case .neurologist:
            return "neurologist.png"
        case .gynecologist:
            return "gynecology.png"
        case .orthopedicSurgeon:
            return "orthopaedic.png"
        case .gastroenterologist:
            return "gastroenterelogist.png"
        case .psychiatrist:
            return "psychology.png"
        }
    }
    
    var color: Color {
        switch self {
        case .cardiologist:
            return .red
        case .endocrinologist:
            return .green
        case .neurologist:
            return .purple
        case .orthopedicSurgeon:
            return .orange
        case .pediatrician:
            return .pink
        case .psychiatrist:
            return .indigo
        case .ophthalmologist:
            return .cyan
        case .oncologist:
            return .gray
        case .dermatologist:
            return .yellow
        case .gastroenterologist:
            return .brown
        case .pulmonologist:
            return .mint
        case .urologist:
            return .teal
        case .gynecologist:
            return .secondary
        case .rheumatologist:
            return .accentColor
        case .dentist:
            return .white
        case .generalPractitioner:
            return .blue
        }
    }
}
