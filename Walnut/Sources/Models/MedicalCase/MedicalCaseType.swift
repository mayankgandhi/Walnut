//
//  MedicalCaseType.swift
//  Walnut-Playground
//
//  Created by Mayank Gandhi on 29/06/25.
//  Copyright © 2025 m. All rights reserved.
//

import SwiftUI

// MARK: - Enums for type safety
enum MedicalCaseType: String, CaseIterable, Codable, Hashable {
    
    case immunisation = "immunisation"
    case healthCheckup = "health-checkup"
    case surgery = "surgery"
    case consultation = "consultation"
    case procedure = "procedure"
    case followUp = "follow-up"
    case treatment = "treatment"
    
    var displayName: String {
        switch self {
        case .immunisation: return "Immunisation"
        case .healthCheckup: return "Health Check-up"
        case .surgery: return "Surgery"
        case .consultation: return "Consultation"
        case .procedure: return "Procedure"
        case .followUp: return "Follow Up"
        case .treatment: return "Treatment"
        }
    }
    
    var backgroundColor: Color {
        switch self {
        case .immunisation:
            return Color.blue.opacity(0.15)
        case .surgery:
            return Color.red.opacity(0.15)
        case .healthCheckup:
            return Color.green.opacity(0.15)
        case .followUp:
            return Color.orange.opacity(0.15)
        case .treatment:
            return Color.purple.opacity(0.15)
        default:
            return Color.gray.opacity(0.15)
        }
    }
    
    var foregroundColor: Color {
        switch self {
        case .immunisation:
            return .blue
        case .surgery:
            return .red
        case .healthCheckup:
            return .green
        case .followUp:
            return .orange
        case .treatment:
            return .purple
        default:
            return .gray
        }
    }
    
}


