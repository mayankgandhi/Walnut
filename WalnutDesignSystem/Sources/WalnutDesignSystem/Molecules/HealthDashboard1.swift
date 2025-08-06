//
//  HealthDashboard.swift
//  WalnutDesignSystem
//
//  Created by Mayank Gandhi on 06/08/25.
//  Copyright © 2025 m. All rights reserved.
//

import SwiftUI

/// Complete health dashboard showcasing all design system components
public struct HealthDashboard: View {
    public init() {}
    
    public var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(spacing: Spacing.medium) {
                    // Profile header
                    ProfileHeader(
                        name: "Jason Bean",
                        subtitle: "Type 1 diabetes"
                    )
                    .padding(.horizontal)
                    
                    // Glucose monitoring section
                    VStack(alignment: .leading, spacing: Spacing.small) {
                        Text("Today's Readings")
                            .font(.headline.weight(.semibold))
                            .foregroundStyle(.primary)
                            .padding(.horizontal)
                        
                       
                    }
                    
                    // Heart condition card
                    HeartConditionCard(
                        bloodPressure: "170/80",
                        heartRate: "72",
                        chartData: [0.3, 0.8, 0.5, 0.9, 0.4, 0.7, 0.6, 0.8, 0.3]
                    )
                    .padding(.horizontal)
                    
                    // Nutrition tracking
                    VStack(alignment: .leading, spacing: Spacing.small) {
                        Text("Nutrition")
                            .font(.headline.weight(.semibold))
                            .foregroundStyle(.primary)
                            .padding(.horizontal)
                        
                        HStack(spacing: Spacing.medium) {
                            ProgressCard(
                                title: "Calories",
                                progress: 0.91,
                                currentValue: "1950",
                                maxValue: "2140",
                                unit: "kcal",
                                date: "10 December",
                                color: .cyan
                            )
                            
                            NutritionCard(
                                title: "Breakfast",
                                calories: "62.0",
                                protein: "78.5",
                                fats: "Today's 1278",
                                carbs: "23.0",
                                rdc: "14%"
                            )
                        }
                        .padding(.horizontal)
                    }
                    
                    // Food items
                    VStack(alignment: .leading, spacing: Spacing.small) {
                        HStack {
                            Text("Today's Meals")
                                .font(.headline.weight(.semibold))
                                .foregroundStyle(.primary)
                            
                            Spacer()
                            
                            Button("View All") {}
                                .font(.subheadline)
                                .foregroundStyle(Color.healthPrimary)
                        }
                        .padding(.horizontal)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: Spacing.medium) {
                                DSItemCard(
                                    name: "Taco",
                                    calories: "745",
                                    details: "Big nice meal",
                                    color: .cyan
                                )
                                
                                DSItemCard(
                                    name: "Donut",
                                    calories: "341",
                                    details: "Sweet treat",
                                    color: .pink
                                )
                                
                                DSItemCard(
                                    name: "Salad",
                                    calories: "125",
                                    details: "Healthy choice",
                                    color: .green
                                )
                            }
                            .padding(.horizontal)
                        }
                    }
                    
                    // Quick info card
                    InfoCard(
                        title: "Do you know that doctors are available to you at all times?",
                        subtitle: "Get consultation",
                        buttonText: "Get started"
                    )
                    .padding(.horizontal)
                    
                    // Menu items
                    VStack(spacing: Spacing.small) {
                        MenuListItem(
                            icon: "book.fill",
                            title: "Diary",
                            iconColor: .healthPrimary
                        )
                        
                        MenuListItem(
                            icon: "leaf.fill",
                            title: "Nutrition",
                            iconColor: .green
                        )
                        
                        MenuListItem(
                            icon: "chart.line.uptrend.xyaxis",
                            title: "Monitoring",
                            iconColor: .blue
                        )
                        
                        MenuListItem(
                            icon: "questionmark.circle.fill",
                            title: "Knowledge base",
                            iconColor: .healthPrimary
                        )
                        
                        MenuListItem(
                            icon: "bell.fill",
                            title: "Alarms",
                            iconColor: .orange
                        )
                        
                        MenuListItem(
                            icon: "gearshape.fill",
                            title: "Settings",
                            iconColor: .gray
                        )
                        
                        MenuListItem(
                            icon: "rectangle.portrait.and.arrow.right",
                            title: "Log out",
                            iconColor: .red,
                            hasChevron: false
                        )
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
            .navigationBarHidden(true)
        }
    }
}

/// Medical dashboard preview
public struct MedicalDashboardPreview: View {
    public init() {}
    
    public var body: some View {
        VStack(spacing: Spacing.large) {
            // Success notification example
            SuccessNotification(
                timestamp: "5:05 pm",
                value: "3,2",
                unit: "mmol/L",
                status: "Hypos level!"
            )
            
            Spacer()
            
            // Chart example
            VStack(alignment: .leading, spacing: Spacing.medium) {
                Text("Monitoring")
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(.primary)
                
                Text("All glucose measurements.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                LineChart(
                    data: [3, 8, 5, 12, 7, 15, 9, 11, 6, 13, 8],
                    color: .healthPrimary
                )
                
                Text("Negative growth")
                    .font(.caption.weight(.medium))
                    .foregroundStyle(.orange)
            }
            .padding()
            .cardStyle()
        }
        .padding()
    }
}
