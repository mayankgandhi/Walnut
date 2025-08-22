//
//  EnhancedBloodReportListItem.swift
//  Walnut
//
//  Created by Mayank Gandhi on 21/08/25.
//  Copyright © 2025 m. All rights reserved.
//

import SwiftUI
import WalnutDesignSystem

struct EnhancedBloodReportListItem: View {
    let bloodReport: BloodReport
    @State private var isPressed = false
    
    var body: some View {
        HStack(spacing: Spacing.medium) {
            Circle()
                .fill(Color.healthError.opacity(0.15))
                .frame(width: 44, height: 44)
                .overlay {
                    Image(systemName: "drop.fill")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundStyle(Color.healthError)
                }
            
            VStack(alignment: .leading, spacing: Spacing.xs) {
                HStack {
                    Text(bloodReport.testName)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.primary)
                        .lineLimit(1)
                    
                    Spacer()
                    
                    let abnormalCount = bloodReport.testResults.filter(\.isAbnormal).count
                    if abnormalCount > 0 {
                        HStack(spacing: 2) {
                            Circle()
                                .fill(Color.healthError)
                                .frame(width: 4, height: 4)
                            
                            Text("\(abnormalCount) abnormal")
                                .font(.caption2.weight(.medium))
                                .foregroundStyle(Color.healthError)
                        }
                    }
                }
                
                HStack {
                    Text(bloodReport.resultDate, style: .date)
                        .font(.caption.weight(.medium))
                        .foregroundStyle(.secondary)
                    
                    if !bloodReport.labName.isEmpty {
                        Text("•")
                            .font(.caption)
                            .foregroundStyle(.tertiary)
                        
                        Text(bloodReport.labName)
                            .font(.caption)
                            .foregroundStyle(.tertiary)
                            .lineLimit(1)
                    }
                }
                
                if !bloodReport.testResults.isEmpty {
                    Text("\(bloodReport.testResults.count) test results")
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                }
            }
            
            Image(systemName: "chevron.right")
                .font(.caption.weight(.medium))
                .foregroundStyle(.quaternary)
        }
        .padding(Spacing.medium)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(UIColor.secondarySystemGroupedBackground))
                .stroke(Color.healthError.opacity(0.2), lineWidth: 0.5)
                .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
        )
        .scaleEffect(isPressed ? 0.98 : 1.0)
        .animation(.easeInOut(duration: 0.1), value: isPressed)
        
    }
}
