//
//  ValidationTest.swift
//  WalnutDesignSystem
//
//  Created by Mayank Gandhi on 06/08/25.
//  Copyright © 2025 m. All rights reserved.
//

import SwiftUI

/// Validation test to ensure all components compile and work together
struct ValidationTest: View {
    var body: some View {
        ScrollView {
            VStack(spacing: Spacing.medium) {
                // Test all atomic components
                DSButton("Test Button", style: .primary) {}
                
                PatientAvatar(initials: "JD", size: Size.avatarMedium)
                
                StatusIndicator(status: .good)
               
                ProgressCard(
                    title: "Test Progress",
                    progress: 0.75,
                    currentValue: "75",
                    maxValue: "100",
                    unit: "%",
                    date: "Today",
                    color: .healthPrimary
                )
                
                NutritionCard(
                    title: "Test Nutrition",
                    calories: "500",
                    protein: "20g",
                    fats: "15g",
                    carbs: "30g",
                    rdc: "25%"
                )
                
                DSItemCard(
                    name: "Test Food",
                    calories: "250",
                    details: "Test details",
                    color: .cyan
                )
                
                MenuListItem(
                    icon: "heart.fill",
                    title: "Test Menu Item",
                    iconColor: .healthPrimary
                )
                
                ProfileHeader(
                    name: "Test User",
                    subtitle: "Test subtitle"
                )
                
                HeartConditionCard(
                    bloodPressure: "120/80",
                    heartRate: "70",
                    chartData: [0.5, 0.7, 0.6, 0.8, 0.4]
                )
                
                SuccessNotification(
                    timestamp: "Now",
                    value: "5.0",
                    unit: "mmol/L",
                    status: "Perfect!"
                )
                
                LineChart(
                    data: [1, 3, 2, 5, 4, 6, 3],
                    color: .healthPrimary
                )
                
                // Test molecules
                HealthDashboard()
                    .frame(height: 400)
                
                // Test colors
                HStack {
                    Rectangle().fill(Color.healthPrimary).frame(width: 50, height: 50)
                    Rectangle().fill(Color.healthSuccess).frame(width: 50, height: 50)
                    Rectangle().fill(Color.healthWarning).frame(width: 50, height: 50)
                    Rectangle().fill(Color.healthError).frame(width: 50, height: 50)
                }
            }
            .padding()
        }
    }
}

#Preview {
    ValidationTest()
}
