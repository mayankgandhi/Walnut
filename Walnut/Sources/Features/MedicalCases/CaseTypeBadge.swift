//
//  CaseTypeBadge.swift
//  Walnut-Playground
//
//  Created by Mayank Gandhi on 02/07/25.
//  Copyright © 2025 m. All rights reserved.
//

import SwiftUI
import WalnutDesignSystem

// Case Type Badge Component
struct CaseTypeBadge: View {
    let type: MedicalCaseType
    
    var body: some View {
        Text(type.displayName)
            .font(.caption.weight(.semibold))
            .padding(.horizontal, Spacing.medium)
            .padding(.vertical, Spacing.xs)
            .background(type.backgroundColor)
            .foregroundColor(type.foregroundColor)
            .clipShape(Capsule())
    }
    
   
}
