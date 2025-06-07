//
//  MedicalRecordRow.swift
//  Walnut
//
//  Created by Mayank Gandhi on 07/06/25.
//  Copyright © 2025 m. All rights reserved.
//

import SwiftUI

// MARK: - Medical Record Row
struct MedicalRecordRow: View {
    let record: MedicalRecord
    let onTap: () -> Void
    
    var recordIcon: String {
        switch record.recordType {
        case "visit_summary": return "stethoscope"
        case "prescription": return "pill"
        case "diagnosis": return "cross.case"
        case "procedure": return "scissors"
        case "immunization": return "syringe"
        case "lab_report": return "testtube.2"
        default: return "doc.text"
        }
    }
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                Image(systemName: recordIcon)
                    .foregroundColor(.healthBlue)
                    .font(.system(size: 16, weight: .medium))
                    .frame(width: 20)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(record.title)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.textPrimary)
                        .lineLimit(1)
                    
                    if let summary = record.summary {
                        Text(summary)
                            .font(.caption)
                            .foregroundColor(.textSecondary)
                            .lineLimit(2)
                    }
                    
                    Text(record.date, formatter: DateFormatter.mediumStyle)
                        .font(.caption)
                        .foregroundColor(.textTertiary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.textTertiary)
                    .font(.system(size: 12, weight: .medium))
            }
            .padding(.vertical, 8)
        }
        .buttonStyle(PlainButtonStyle())
    }
}
