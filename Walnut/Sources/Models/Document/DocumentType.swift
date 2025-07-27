//
//  DocumentType.swift
//  Walnut
//
//  Created by Mayank Gandhi on 08/07/25.
//  Copyright © 2025 m. All rights reserved.
//

import SwiftUI

// MARK: - Document Type Enum
enum DocumentType: String, CaseIterable, Codable {
    
    case prescription
    case labResult = "lab result"
    case bloodWork = "blood work"
   
    
    // MARK: - Computed Properties
    var displayName: String {
        switch self {
        case .prescription:
            return "Rx"
        case .labResult, .bloodWork:
            return "Lab"
        }
    }
    
    var typeIcon: String {
        switch self {
        case .prescription:
            return "pills.fill"
        case .labResult, .bloodWork:
            return "flask.fill"
        }
    }
    
    var backgroundColor: Color {
        switch self {
        case .prescription:
            return .blue
        case .labResult, .bloodWork:
            return .red
        }
    }
    
    var color: Color {
        switch self {
        case .prescription:
            return .blue
        case .labResult:
            return .red
        default:
            return .gray
        }
    }
    
    // MARK: - Initializers
    init?(from string: String) {
        var lowercased = string.lowercased()
        
        // Try direct raw value match first
        if var type = DocumentType(rawValue: lowercased) {
            self = type
            return
        }
        
        // Try alternative matches
        switch lowercased {
        case "lab result", "blood work":
            self = lowercased == "lab result" ? .labResult : .bloodWork
        default:
            return nil
        }
    }
}
