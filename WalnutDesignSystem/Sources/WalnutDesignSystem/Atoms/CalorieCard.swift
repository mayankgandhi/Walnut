//
//  CalorieCard.swift
//  WalnutDesignSystem
//
//  Created by Mayank Gandhi on 06/08/25.
//  Copyright © 2025 m. All rights reserved.
//

import SwiftUI

/// Progress card with circular progress ring (matching the calorie design)
public struct ProgressCard: View {
    private let title: String
    private let progress: Double
    private let currentValue: String
    private let maxValue: String
    private let unit: String
    private let date: String
    private let color: Color
    
    public init(
        title: String,
        progress: Double,
        currentValue: String,
        maxValue: String,
        unit: String,
        date: String,
        color: Color = .healthPrimary
    ) {
        self.title = title
        self.progress = progress
        self.currentValue = currentValue
        self.maxValue = maxValue
        self.unit = unit
        self.date = date
        self.color = color
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: Spacing.medium) {
            // Header
            HStack {
                HStack(spacing: Spacing.xs) {
                    Image(systemName: "chart.pie.fill")
                        .font(.caption)
                        .foregroundStyle(color)
                    
                    Text(title)
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(.primary)
                }
                
                Spacer()
                
                Image(systemName: "star.fill")
                    .font(.caption)
                    .foregroundStyle(.yellow)
            }
            
            // Progress ring and percentage
            HStack {
                ZStack {
                    Circle()
                        .stroke(color.opacity(0.2), lineWidth: 12)
                    
                    Circle()
                        .trim(from: 0, to: progress)
                        .stroke(color, style: StrokeStyle(lineWidth: 12, lineCap: .round))
                        .rotationEffect(.degrees(-90))
                        .animation(.easeOut(duration: 1), value: progress)
                    
                    VStack(spacing: 2) {
                        Text(currentValue)
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundStyle(.primary)
                        
                        Text(unit)
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
                .frame(width: 120, height: 120)
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: Spacing.small) {
                    Text("\(Int(progress * 100))%")
                        .font(.system(size: 48, weight: .bold, design: .rounded))
                        .foregroundStyle(.primary)
                    
                    Text(date)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(Spacing.medium)
        .background(color.opacity(0.1), in: RoundedRectangle(cornerRadius: 16))
    }
}

/// Nutrition breakdown card (matching the breakfast design)
public struct NutritionCard: View {
    private let title: String
    private let calories: String
    private let protein: String
    private let fats: String
    private let carbs: String
    private let rdc: String
    private let color: Color
    
    public init(
        title: String,
        calories: String,
        protein: String,
        fats: String,
        carbs: String,
        rdc: String,
        color: Color = .healthSuccess
    ) {
        self.title = title
        self.calories = calories
        self.protein = protein
        self.fats = fats
        self.carbs = carbs
        self.rdc = rdc
        self.color = color
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: Spacing.medium) {
            // Header
            HStack {
                HStack(spacing: Spacing.xs) {
                    Image(systemName: "leaf.fill")
                        .font(.caption)
                        .foregroundStyle(color)
                    
                    Text(title)
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(.primary)
                }
                
                Spacer()
                
                Button(action: {}) {
                    Image(systemName: "plus")
                        .font(.caption.weight(.medium))
                        .foregroundStyle(.white)
                        .frame(width: 20, height: 20)
                        .background(color, in: Circle())
                }
            }
            
            // Calorie count
            Text(calories)
                .font(.title.weight(.bold))
                .foregroundStyle(.primary)
            
            // Nutrition breakdown
            HStack {
                VStack(alignment: .leading, spacing: Spacing.xs) {
                    Text("Proteins")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                    Text(protein)
                        .font(.body.weight(.semibold))
                        .foregroundStyle(.primary)
                }
                
                Spacer()
                
                VStack(alignment: .center, spacing: Spacing.xs) {
                    Text("Fats")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                    Text(fats)
                        .font(.body.weight(.semibold))
                        .foregroundStyle(.primary)
                }
                
                Spacer()
                
                VStack(alignment: .center, spacing: Spacing.xs) {
                    Text("Carbs")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                    Text(carbs)
                        .font(.body.weight(.semibold))
                        .foregroundStyle(.primary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: Spacing.xs) {
                    Text("RDC")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                    Text(rdc)
                        .font(.body.weight(.semibold))
                        .foregroundStyle(.primary)
                }
            }
            
            // Today dropdown
            HStack {
                Text("Today")
                    .font(.caption.weight(.medium))
                    .foregroundStyle(.secondary)
                
                Image(systemName: "chevron.down")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                
                Spacer()
                
                Button(action: {}) {
                    Image(systemName: "pencil")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(Spacing.medium)
        .background(color.opacity(0.1), in: RoundedRectangle(cornerRadius: 16))
    }
}

