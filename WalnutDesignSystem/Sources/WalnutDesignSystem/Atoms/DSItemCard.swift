//
//  DSItemCard.swift
//  WalnutDesignSystem
//
//  Created by Mayank Gandhi on 06/08/25.
//  Copyright © 2025 m. All rights reserved.
//

import SwiftUI

/// Food item card (like Taco, Donut)
public struct DSItemCard: View {
    private let icon: String?
    private let name: String
    private let calories: String
    private let details: String
    private let color: Color
    
    public init(icon: String? = nil,
                name: String, calories: String, details: String, color: Color = .cyan) {
        self.icon = icon
        self.name = name
        self.calories = calories
        self.details = details
        self.color = color
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: Spacing.small) {
            
            HStack {
                Text(name)
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(.primary)
                
                Spacer()
                
                Image(systemName: icon ?? "cross.fill")
                    .foregroundColor(icon != nil ? color : .green)
            }
            
            Text(calories)
                .font(.title2.weight(.bold))
                .foregroundStyle(.primary)
            
            Text("Calories")
                .font(.caption)
                .foregroundStyle(.secondary)
            
            Text(details)
                .font(.caption.weight(.medium))
                .foregroundStyle(.primary)
        }
        .padding(Spacing.medium)
        .background(color.opacity(0.15), in: RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    DSItemCard(
        icon: "carrot",
        name: "Burger",
        calories: "200",
        details: "Deliciosos",
        color: .glucose
    )
    
    DSItemCard(
        name: "Burger",
        calories: "200",
        details: "Deliciosos",
        color: .glucose
    )
}
