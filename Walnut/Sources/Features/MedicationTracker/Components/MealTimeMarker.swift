//
//  MealTimeMarker.swift
//  Walnut
//
//  Created by Mayank Gandhi on 10/09/25.
//  Copyright © 2025 m. All rights reserved.
//

import SwiftUI
import WalnutDesignSystem

/// Meal time marker component for showing meal reference points
struct MealTimeMarker: View {
    let mealTime: MealTime
    let isUpcoming: Bool
    
    var body: some View {
        HStack(spacing: Spacing.small) {
            Image(systemName: mealTime.icon)
                .font(.caption)
                .foregroundStyle(mealTime.color)
                .frame(width: 20, height: 20)
                .background(mealTime.color.opacity(0.15))
                .clipShape(Circle())
            
            Text(mealTime.displayName)
                .font(.caption.weight(.medium))
                .foregroundStyle(isUpcoming ? mealTime.color : .secondary)
            
            if isUpcoming {
                Text("upcoming")
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(mealTime.color)
                    .clipShape(Capsule())
            }
            
            Spacer()
        }
        .padding(.horizontal, Spacing.medium)
        .padding(.vertical, Spacing.small)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
}

#Preview {
    MealTimeMarker(mealTime: .bedtime, isUpcoming: true)
    MealTimeMarker(mealTime: .bedtime, isUpcoming: false)
}
