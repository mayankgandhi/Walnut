//
//  DocumentItem.swift
//  Walnut
//
//  Created by Mayank Gandhi on 26/08/25.
//  Copyright © 2025 m. All rights reserved.
//

import Foundation

// MARK: - Supporting Types

enum DocumentItem {
    
    case prescription(Prescription)
    case bloodReport(BloodReport)
    case document(Document)
    case unparsedDocument(Document)
    
    var id: String {
        switch self {
        case .prescription(let prescription):
            return "prescription-\(prescription.id)"
        case .bloodReport(let bloodReport):
            return "bloodReport-\(bloodReport.id)"
        case .document(let document):
            return "document-\(document.id)"
        case .unparsedDocument(let document):
            return "unparsedDocument-\(document.id)"
        }
    }
    
    var sortDate: Date? {
        switch self {
        case .prescription(let prescription):
            return prescription.dateIssued
        case .bloodReport(let bloodReport):
            return bloodReport.resultDate
        case .unparsedDocument(let document):
            return document.uploadDate
        case .document(let document):
            return document.uploadDate
        }
    }
}

