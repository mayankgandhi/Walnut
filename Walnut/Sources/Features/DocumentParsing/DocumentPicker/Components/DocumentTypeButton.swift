//
//  DocumentTypeButton.swift
//  Walnut
//
//  Created by Mayank Gandhi on 02/07/25.
//  Copyright © 2025 m. All rights reserved.
//

import SwiftUI
import WalnutDesignSystem

struct DocumentTypeButton: View {
    
    let type: DocumentType
    let isSelected: Bool
    
    var body: some View {
        HStack(spacing: Spacing.small) {
            // Icon with enhanced styling
            
            Image(type.iconImage)
                .resizable()
                .frame(width: 36, height: 36)
            
            VStack(alignment: .leading) {
                Text(type.displayName)
                    .font(.subheadline.weight(isSelected ? .semibold : .medium))
                    .foregroundStyle(textColor)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                
                Text(type.subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                    .minimumScaleFactor(0.8)
            }
        }
        .padding(Spacing.small)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(backgroundColor)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(borderColor, lineWidth: isSelected ? 2 : 1)
        )
        .scaleEffect(isSelected ? 1.05 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: isSelected)
        
    }
    
    // MARK: - Computed Properties
    
    private var backgroundColor: Color {
        if isSelected {
            return type.color.opacity(0.08)
        } else {
            return Color(UIColor.secondarySystemGroupedBackground)
        }
    }
    
    private var borderColor: Color {
        if isSelected {
            return type.color
        } else {
            return Color(UIColor.separator).opacity(0.5)
        }
    }
    
    private var textColor: Color {
        if isSelected {
            return type.color
        } else {
            return .primary
        }
    }
    
    private var iconColor: Color {
        if isSelected {
            return type.color
        } else {
            return .secondary
        }
    }
    
    private var iconBackgroundColor: Color {
        if isSelected {
            return type.color.opacity(0.15)
        } else {
            return Color(UIColor.tertiarySystemGroupedBackground)
        }
    }
}

#Preview("Waterfall Grid Layout") {
    // Waterfall grid layout using LazyVGrid
    LazyVGrid(
        columns: [
            GridItem(.flexible(minimum: 120), spacing: Spacing.small),
            GridItem(.flexible(minimum: 120), spacing: Spacing.small)
            
        ],
        alignment: .leading,
        spacing: Spacing.small
    ) {
        ForEach(DocumentType.allCases, id: \.self) { type in
            DocumentTypeButton(
                type: type,
                isSelected: false
            )
        }
    }
    .padding(Spacing.medium)
    
}
