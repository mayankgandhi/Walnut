//
//  MedicalSpecialty.swift
//  Walnut-Playground
//
//  Created by Mayank Gandhi on 02/07/25.
//  Copyright © 2025 m. All rights reserved.
//

import Foundation
import SwiftUI

enum MedicalSpecialty: String, CaseIterable, Hashable, Codable {
    
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
        case .cardiologist:
            return "heart.fill"
        case .endocrinologist:
            return "leaf.fill"
        case .neurologist:
            return "brain"
        case .orthopedicSurgeon:
            return "figure.walk"
        case .pediatrician:
            return "figure.2.and.child.holdinghands"
        case .psychiatrist:
            return "brain.head.profile"
        case .ophthalmologist:
            return "eye.fill"
        case .oncologist:
            return "cross.case.fill"
        case .dermatologist:
            return "hand.raised.fill"
        case .gastroenterologist:
            return "stomach"
        case .pulmonologist:
            return "lungs.fill"
        case .urologist:
            return "drop.fill"
        case .gynecologist:
            return "figure.dress.line.vertical.figure"
        case .rheumatologist:
            return "figure.flexibility"
        case .dentist:
            return "mouth.fill"
        case .generalPractitioner:
            return "stethoscope"
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
