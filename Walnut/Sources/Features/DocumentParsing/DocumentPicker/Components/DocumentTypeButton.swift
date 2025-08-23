//
//  DocumentTypeButton.swift
//  Walnut-Playground
//
//  Created by Mayank Gandhi on 02/07/25.
//  Copyright © 2025 m. All rights reserved.
//

import SwiftUI

// Document Type Button
struct DocumentTypeButton: View {
    let type: DocumentType
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: type.typeIcon)
                Text(type.displayName)
            }
            .font(.subheadline)
            .fontWeight(isSelected ? .semibold : .medium)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(isSelected ? type.color : Color.gray.opacity(0.1))
            .foregroundColor(isSelected ? .white : .primary)
            .cornerRadius(12)
        }
    }
    
}
