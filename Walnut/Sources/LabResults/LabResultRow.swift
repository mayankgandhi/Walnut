//
//  LabResultRow.swift
//  Walnut
//
//  Created by Mayank Gandhi on 07/06/25.
//  Copyright © 2025 m. All rights reserved.
//

import SwiftUI

// MARK: - Lab Result Row
struct LabResultRow: View {
    let result: LabResult
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(result.testName ?? "Test")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.textPrimary)
                    if let resultDate = result.resultDate {
                        Text(resultDate, formatter: DateFormatter.mediumStyle)
                            .font(.caption)
                            .foregroundColor(.textSecondary)
                    }
                    
                }
                
                Spacer()
                
                if let status = result.status {
                    StatusBadge(status: status)
                }
            }
            .padding(.vertical, 8)
        }
        .buttonStyle(PlainButtonStyle())
    }
}
