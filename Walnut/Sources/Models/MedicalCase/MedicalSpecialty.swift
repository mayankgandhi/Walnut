//
//  MedicalSpecialty.swift
//  Walnut-Playground
//
//  Created by Mayank Gandhi on 02/07/25.
//  Copyright © 2025 m. All rights reserved.
//

import Foundation
import SwiftUI
import WalnutDesignSystem


enum MedicalSpecialty: String, CaseIterable, Hashable, Codable, Sendable, ButtonPickable {

    
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
    case ent = "ENT"
    
    var description: String {
        rawValue
    }
    
    var icon: String {
        switch self {
        case .generalPractitioner:
            return "generalPractictioner"
        case .cardiologist:
            return "cardiologist"
        case .endocrinologist:
            return "endocrinologist"
        case .rheumatologist:
            return "rheumatologist"
        case .dermatologist:
            return "dermatologist"
        case .pediatrician:
            return "pediatrician"
        case .urologist:
            return "urologist"
        case .dentist:
            return "dentist"
        case .oncologist:
            return "oncologist"
        case .pulmonologist:
            return "pulmonologist"
        case .ophthalmologist:
            return "ophthalmologist"
        case .neurologist:
            return "neurologist"
        case .gynecologist:
            return "gynacology"
        case .orthopedicSurgeon:
            return "orthopaedic"
        case .gastroenterologist:
            return "gastroenterelogist"
        case .psychiatrist:
            return "psychology"
        case .ent:
            return "generalPractictioner"
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
        case .ent:
            return .black
        }
    }
}
