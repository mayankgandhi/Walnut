//
//  CaseTypeBadge.swift
//  Walnut-Playground
//
//  Created by Mayank Gandhi on 02/07/25.
//  Copyright © 2025 m. All rights reserved.
//

import SwiftUI

// Case Type Badge Component
struct CaseTypeBadge: View {
    let type: MedicalCaseType
    
    var body: some View {
        Text(type.displayName)
            .font(.caption)
            .fontWeight(.semibold)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(type.backgroundColor)
            .foregroundColor(type.foregroundColor)
            .cornerRadius(12)
    }
    
   
}
