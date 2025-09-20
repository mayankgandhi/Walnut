//
//  DocumentType.swift
//  Walnut
//
//  Created by Mayank Gandhi on 08/07/25.
//  Copyright © 2025 m. All rights reserved.
//

import SwiftUI

// MARK: - DocumentType Extensions
@frozen public enum DocumentType: String, CaseIterable, Codable, Identifiable {
    
    case prescription
    case biomarkerReport = "lab result"
    case unknown
    case invoice
    case imaging = "imaging report"
    case vaccination = "vaccination record"
    case insurance = "insurance document"
    
    public var displayName: String {
        switch self {
        case .prescription:
            return "Rx"
        case .biomarkerReport:
            return "Lab"
        case .unknown:
            return "Doc"
        case .invoice:
            return "Bill"
        case .imaging:
            return "Imaging"
        case .vaccination:
            return "Vaccination"
        case .insurance:
            return "Insurance"
        }
    }
    
    public var iconImage: String {
        switch self {
        case .prescription:
            "prescription"
        case .biomarkerReport:
            "labresult"
        case .unknown:
            "document"
        case .invoice:
            "invoice"
        case .imaging:
            "imaging"
        case .vaccination:
            "vaccine"
        case .insurance:
            "insurance"
        }
    }
    
    public var typeIcon: String {
        switch self {
        case .prescription:
            return "pills.fill"
        case .biomarkerReport:
            return "flask.fill"
        case .unknown:
            return "doc.fill"
        case .invoice:
            return "dollarsign.square.fill"
        case .imaging:
            return "xray"
        case .vaccination:
            return "syringe.fill"
        case .insurance:
            return "creditcard.fill"
        }
    }
    
    public var backgroundColor: Color {
        switch self {
        case .prescription:
            return .blue
        case .biomarkerReport:
            return .red
        case .unknown:
            return .gray
        case .invoice:
            return .green
        case .imaging:
            return .purple
        case .vaccination:
            return .mint
        case .insurance:
            return .indigo
        }
    }
    
    public var color: Color {
        switch self {
        case .prescription:
            return .blue
        case .biomarkerReport:
            return .red
        case .unknown:
            return .gray
        case .invoice:
            return .green
        case .imaging:
            return .purple
        case .vaccination:
            return .mint
        case .insurance:
            return .indigo
        }
    }
    
    public var subtitle: String {
        switch self {
        case .prescription:
            return "Medications & dosages, Doctor visit notes"
        case .biomarkerReport:
            return "Blood tests & analysis"
        case .unknown:
            return "General documents"
        case .invoice:
            return "Bills & payments"
        case .imaging:
            return "X-rays, MRI, CT scans"
        case .vaccination:
            return "Immunization records"
        case .insurance:
            return "Coverage & policies"
        }
    }
    
    public var accessibilityDescription: String {
        switch self {
        case .prescription:
            return "prescription document"
        case .biomarkerReport:
            return "lab result document"
        case .unknown:
            return "medical document"
        case .invoice:
            return "medical bill"
        case .imaging:
            return "imaging report"
        case .vaccination:
            return "vaccination record"
        case .insurance:
            return "insurance document"
        }
    }
    
    public var id: String {
        self.rawValue
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
            self = .biomarkerReport
        case "prescription", "rx", "medication", "medicine", "drug", "pills", "discharge summary", "discharge", "summary", "hospital discharge",
            "consultation notes", "consultation", "notes", "visit notes", "doctor notes", "clinical notes":
            self = .prescription
        case "invoice", "bill", "billing", "payment", "receipt", "medical bill":
            self = .invoice
        case "imaging report", "imaging", "x-ray", "xray", "mri", "ct scan", "ultrasound", "radiology":
            self = .imaging
        case "vaccination record", "vaccination", "vaccine", "immunization", "shot record":
            self = .vaccination
        case "insurance document", "insurance", "insurance card", "coverage", "policy":
            self = .insurance
        case "referral letter", "referral", "specialist referral", "referral form":
            self = .unknown
        default:
            return nil
        }
    }
}

