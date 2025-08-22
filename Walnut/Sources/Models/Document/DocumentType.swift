//
//  DocumentType.swift
//  Walnut
//
//  Created by Mayank Gandhi on 08/07/25.
//  Copyright © 2025 m. All rights reserved.
//

import SwiftUI

// MARK: - DocumentType Extensions
public enum DocumentType: String, CaseIterable, Codable {
    
    case prescription
    case labResult = "lab result"
    case unknown
    case invoice
    case discharge = "discharge summary"
    case imaging = "imaging report"
    case consultation = "consultation notes"
    case vaccination = "vaccination record"
    case insurance = "insurance document"
    case referral = "referral letter"
    
    public var displayName: String {
        switch self {
        case .prescription:
            return "Rx"
        case .labResult:
            return "Lab"
        case .unknown:
            return "Doc"
        case .invoice:
            return "Bill"
        case .discharge:
            return "Disc"
        case .imaging:
            return "Img"
        case .consultation:
            return "Notes"
        case .vaccination:
            return "Vacc"
        case .insurance:
            return "Ins"
        case .referral:
            return "Ref"
        }
    }
    
    public var typeIcon: String {
        switch self {
        case .prescription:
            return "pills.fill"
        case .labResult:
            return "flask.fill"
        case .unknown:
            return "doc.fill"
        case .invoice:
            return "dollarsign.square.fill"
        case .discharge:
            return "doc.text.fill"
        case .imaging:
            return "xray"
        case .consultation:
            return "stethoscope"
        case .vaccination:
            return "syringe.fill"
        case .insurance:
            return "creditcard.fill"
        case .referral:
            return "person.2.fill"
        }
    }
    
    public var backgroundColor: Color {
        switch self {
        case .prescription:
            return .blue
        case .labResult:
            return .red
        case .unknown:
            return .gray
        case .invoice:
            return .green
        case .discharge:
            return .orange
        case .imaging:
            return .purple
        case .consultation:
            return .teal
        case .vaccination:
            return .mint
        case .insurance:
            return .indigo
        case .referral:
            return .cyan
        }
    }
    
    public var color: Color {
        switch self {
        case .prescription:
            return .blue
        case .labResult:
            return .red
        case .unknown:
            return .gray
        case .invoice:
            return .green
        case .discharge:
            return .orange
        case .imaging:
            return .purple
        case .consultation:
            return .teal
        case .vaccination:
            return .mint
        case .insurance:
            return .indigo
        case .referral:
            return .cyan
        }
    }
    
    public var accessibilityDescription: String {
        switch self {
        case .prescription:
            return "prescription document"
        case .labResult:
            return "lab result document"
        case .unknown:
            return "medical document"
        case .invoice:
            return "medical bill"
        case .discharge:
            return "discharge summary"
        case .imaging:
            return "imaging report"
        case .consultation:
            return "consultation notes"
        case .vaccination:
            return "vaccination record"
        case .insurance:
            return "insurance document"
        case .referral:
            return "referral letter"
        }
    }
    
    // MARK: - Initializers
    init?(from string: String) {
        let lowercased = string.lowercased()
        
        // Try direct raw value match first
        if let type = DocumentType(rawValue: lowercased) {
            self = type
            return
        }
        
        // Try alternative matches
        switch lowercased {
        case "lab result", "blood work", "lab", "laboratory", "test results", "blood test":
            self = .labResult
        case "prescription", "rx", "medication", "medicine", "drug", "pills":
            self = .prescription
        case "invoice", "bill", "billing", "payment", "receipt", "medical bill":
            self = .invoice
        case "discharge summary", "discharge", "summary", "hospital discharge":
            self = .discharge
        case "imaging report", "imaging", "x-ray", "xray", "mri", "ct scan", "ultrasound", "radiology":
            self = .imaging
        case "consultation notes", "consultation", "notes", "visit notes", "doctor notes", "clinical notes":
            self = .consultation
        case "vaccination record", "vaccination", "vaccine", "immunization", "shot record":
            self = .vaccination
        case "insurance document", "insurance", "insurance card", "coverage", "policy":
            self = .insurance
        case "referral letter", "referral", "specialist referral", "referral form":
            self = .referral
        case "document", "file", "medical document", "health document":
            self = .unknown
        default:
            return nil
        }
    }
}

