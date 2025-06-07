//
//  DateOfBirthField.swift
//  Walnut
//
//  Created by Mayank Gandhi on 07/06/25.
//  Copyright © 2025 m. All rights reserved.
//

import SwiftUI

struct DateOfBirthField: View {
    let selectedDate: Date?
    let onTap: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Date of Birth")
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.textPrimary)
            
            Button(action: onTap) {
                HStack {
                    if let date = selectedDate {
                        Text(date, style: .date)
                            .foregroundColor(.textPrimary)
                    } else {
                        Text("Select date of birth")
                            .foregroundColor(.textSecondary)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "calendar")
                        .foregroundColor(.healthBlue)
                        .font(.system(size: 16, weight: .medium))
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(Color.walnutSecondaryBackground)
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.borderColor, lineWidth: 1)
                )
            }
        }
    }
}
