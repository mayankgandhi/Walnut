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
    case unknown
   
    
    // MARK: - Computed Properties
    var displayName: String {
        switch self {
        case .prescription:
            return "Rx"
        case .labResult:
            return "Lab"
        case .unknown:
            return "Doc"
        }
    }
    
    var typeIcon: String {
        switch self {
        case .prescription:
            return "pills.fill"
        case .labResult:
            return "flask.fill"
        case .unknown:
            return "doc.fill"
        }
    }
    
    var backgroundColor: Color {
        switch self {
        case .prescription:
            return .blue
        case .labResult:
            return .red
        case .unknown:
            return .gray
        }
    }
    
    var color: Color {
        switch self {
        case .prescription:
            return .blue
        case .labResult:
            return .red
        case .unknown:
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
            self = .labResult
        default:
            return nil
        }
    }
}
