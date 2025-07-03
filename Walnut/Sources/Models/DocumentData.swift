//
//  DocumentData.swift
//  Walnut-Playground
//
//  Created by Mayank Gandhi on 02/07/25.
//  Copyright © 2025 m. All rights reserved.
//

import SwiftUI
import UniformTypeIdentifiers

struct DocumentData: Identifiable, Hashable {
    let id: UUID
    let fileName: String
    let fileURL: URL
    let documentType: DocumentType
    let documentDate: Date
    let uploadDate: Date
    let fileSize: Int64
    var extractionError: String?
    
    static let documents: [DocumentData] = [
        DocumentData(
            id: UUID(),
            fileName: "Blood_Test_Results_2024.pdf",
            fileURL: URL(string: "file://")!,
            documentType: .labResult,
            documentDate: Date().addingTimeInterval(-86400 * 7),
            uploadDate: Date().addingTimeInterval(-86400 * 2),
            fileSize: 245760
        ),
        DocumentData(
            id: UUID(),
            fileName: "Prescription_Cardiology.pdf",
            fileURL: URL(string: "file://")!,
            documentType: .prescription,
            documentDate: Date().addingTimeInterval(-86400 * 3),
            uploadDate: Date().addingTimeInterval(-86400 * 1),
            fileSize: 123456
        ),
        DocumentData(
            id: UUID(),
            fileName: "Chest_XRay_Report.jpg",
            fileURL: URL(string: "file://")!,
            documentType: .imaging,
            documentDate: Date().addingTimeInterval(-86400 * 14),
            uploadDate: Date().addingTimeInterval(-86400 * 10),
            fileSize: 2097152
        )
    ]
}

// MARK: - Document Type Enum
enum DocumentType: String, CaseIterable {
    case prescription
    case labResult = "lab result"
    case bloodWork = "blood work"
    case diagnosis
    case notes
    case imaging
    case xray = "x-ray"
    case scan
    case insurance
    case billing
    
    // MARK: - Computed Properties
    var displayName: String {
        switch self {
        case .prescription:
            return "Rx"
        case .labResult, .bloodWork:
            return "Lab"
        case .diagnosis:
            return "Dx"
        case .notes:
            return "Notes"
        case .imaging, .xray, .scan:
            return "IMG"
        case .insurance:
            return "INS"
        case .billing:
            return "Bill"
        }
    }
    
    var typeIcon: String {
        switch self {
        case .prescription:
            return "pills.fill"
        case .labResult, .bloodWork:
            return "flask.fill"
        case .diagnosis:
            return "stethoscope"
        case .notes:
            return "note.text"
        case .imaging, .xray, .scan:
            return "camera.fill"
        case .insurance:
            return "shield.fill"
        case .billing:
            return "dollarsign.circle.fill"
        }
    }
    
    var backgroundColor: Color {
        switch self {
        case .prescription:
            return .blue
        case .labResult, .bloodWork:
            return .red
        case .diagnosis:
            return .purple
        case .notes:
            return .orange
        case .imaging, .xray, .scan:
            return .green
        case .insurance:
            return .cyan
        case .billing:
            return .indigo
        }
    }
    
    var color: Color {
        switch self {
        case .prescription:
            return .blue
        case .labResult:
            return .red
        case .diagnosis:
            return .purple
        case .notes:
            return .orange
        case .imaging:
            return .green
        default:
            return .gray
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
        case "lab result", "blood work":
            self = lowercased == "lab result" ? .labResult : .bloodWork
        case "x-ray":
            self = .xray
        case "imaging", "scan":
            self = lowercased == "imaging" ? .imaging : .scan
        default:
            return nil
        }
    }
}
