//
//  FileIcon.swift
//  WalnutDesignSystem
//
//  Created by Mayank Gandhi on 21/08/25.
//  Copyright © 2025 m. All rights reserved.
//

import SwiftUI

public struct FileIcon: View {
    let documentType: DocumentType
    let fileName: String
    let previewText: String?
    let size: CGFloat
    
    public init(documentType: DocumentType, fileName: String, previewText: String? = nil, size: CGFloat = 80) {
        self.documentType = documentType
        self.fileName = fileName
        self.previewText = previewText
        self.size = size
    }
    
    public var body: some View {
        VStack(spacing: size * 0.12) {
            Image(systemName: documentType.typeIcon)
                .font(.system(size: size * 0.6, weight: .semibold))
                .foregroundStyle(
                    LinearGradient(
                        colors: [documentType.backgroundColor, documentType.backgroundColor.opacity(0.85)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            
            Text(documentType.displayName)
                .font(.system(size: size * 0.085, weight: .medium, design: .rounded))
                .foregroundColor(.primary)
                .opacity(0.75)
        }
        .frame(width: size, height: size * 1.25)
    }
    
}

// MARK: - DocumentType Extensions  
public enum DocumentType: String, CaseIterable, Codable {
    case prescription
    case labResult = "lab result"
    case unknown
    case invoice
    case discharge = "discharge summary"
    case imaging = "imaging report"
    
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
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        HStack(spacing: 15) {
            FileIcon(
                documentType: .prescription,
                fileName: "Prescription_Cardiology.pdf",
                previewText: "Take 1 tablet daily with food. Lisinopril 10mg for blood pressure management."
            )
            
            FileIcon(
                documentType: .labResult,
                fileName: "Blood_Test_Results.pdf",
                previewText: "Hemoglobin: 14.2 g/dL, White Blood Cells: 7,500, Platelets: 250,000"
            )
            
            FileIcon(
                documentType: .invoice,
                fileName: "Medical_Invoice.pdf",
                previewText: "Consultation Fee: $150, Lab Work: $75, Total Amount: $225"
            )
        }
        
        HStack(spacing: 15) {
            FileIcon(
                documentType: .discharge,
                fileName: "Discharge_Summary.pdf",
                previewText: "Patient discharged in stable condition. Follow-up in 2 weeks.",
                size: 70
            )
            
            FileIcon(
                documentType: .imaging,
                fileName: "Chest_X-Ray.jpg",
                previewText: "Normal chest X-ray. No acute findings. Heart size normal.",
                size: 70
            )
            
            FileIcon(
                documentType: .unknown,
                fileName: "Medical_Document.pdf",
                size: 70
            )
        }
    }
    .padding()
}
