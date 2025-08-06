//
//  ComponentShowcase.swift
//  WalnutDesignSystem
//
//  Created by Mayank Gandhi on 06/08/25.
//  Copyright © 2025 m. All rights reserved.
//

import SwiftUI

/// Complete showcase of all design system components matching reference designs
public struct ComponentShowcase: View {
    public init() {}
    
    public var body: some View {
        NavigationView {
            List {
                Section("Reference Design 1 - Medical Cards") {
                    NavigationLink("Heart Condition & Medical Charts") {
                        ScrollView {
                            VStack(spacing: Spacing.large) {
                                HeartConditionCard(
                                    bloodPressure: "170/80",
                                    heartRate: "72",
                                    chartData: [0.3, 0.8, 0.5, 0.9, 0.4, 0.7, 0.6, 0.8, 0.3]
                                )
                                
                                MedicalChartCard(
                                    patientName: "Adrian Williams",
                                    patientInfo: "Type 1 diabetes, 29 y/o",
                                    testType: "General Blood Test",
                                    value: "195.80",
                                    date: "21 Dec",
                                    chartData: [0.2, 0.7, 0.4, 0.8, 0.3, 0.9, 0.5, 0.6]
                                )
                                
                                InfoCard(
                                    title: "Do you know that doctors are available to you at all times?",
                                    subtitle: "Get consultation",
                                    buttonText: "Get started"
                                )
                            }
                            .padding()
                        }
                        .navigationTitle("Medical Cards")
                    }
                }
                
                Section("Reference Design 2 - Nutrition & Progress") {
                    NavigationLink("Calorie & Nutrition Tracking") {
                        ScrollView {
                            VStack(spacing: Spacing.large) {
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
                                
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: Spacing.medium) {
                                        FoodItemCard(
                                            name: "Taco",
                                            calories: "745",
                                            details: "Big nice meal",
                                            color: .cyan
                                        )
                                        
                                        FoodItemCard(
                                            name: "Donut",
                                            calories: "341",
                                            details: "Sweet treat",
                                            color: .pink
                                        )
                                        
                                        FoodItemCard(
                                            name: "Salad",
                                            calories: "125",
                                            details: "Healthy choice",
                                            color: .green
                                        )
                                    }
                                    .padding(.horizontal)
                                }
                            }
                            .padding()
                        }
                        .navigationTitle("Nutrition")
                    }
                }
                
//                Section("Reference Design 3 - Glucose & Success") {
//                    NavigationLink("Glucose Monitoring") {
//                        ScrollView {
//                            VStack(spacing: Spacing.large) {
//                                ProfileHeader(
//                                    name: "Jason Bean",
//                                    subtitle: "Type 1 diabetes, 29 y/o"
//                                )
//                                
//                                ScrollView(.horizontal, showsIndicators: false) {
//                                    HStack(spacing: Spacing.medium) {
//                                        GlucoseCard(
//                                            value: "3,2",
//                                            unit: "mmol/L",
//                                            status: "Hypos level",
//                                            timestamp: "5:05 pm",
//                                            lastScan: "4,1",
//                                            growth: "Negative"
//                                        )
//                                        
//                                        GlucoseCard(
//                                            value: "4,1",
//                                            unit: "mmol/L",
//                                            status: "Normal",
//                                            timestamp: "6:15 pm",
//                                            lastScan: "3,8",
//                                            growth: "Positive"
//                                        )
//                                    }
//                                    .padding(.horizontal)
//                                }
//                                
//                                VStack(alignment: .leading, spacing: Spacing.medium) {
//                                    Text("Nutrition Tracking")
//                                        .font(.headline.weight(.semibold))
//                                        .foregroundStyle(.primary)
//                                    
//                                    VStack(spacing: Spacing.small) {
//                                        NutritionListItem(
//                                            icon: "cup.and.saucer.fill",
//                                            title: "Juice candy",
//                                            subtitle: "Our natural juice",
//                                            value: "3",
//                                            unit: "GL",
//                                            iconColor: .red
//                                        )
//                                        
//                                        NutritionListItem(
//                                            icon: "snowflake",
//                                            title: "Ice cream",
//                                            subtitle: "50g / big or 6g carbs",
//                                            value: "4",
//                                            unit: "GL",
//                                            iconColor: .blue
//                                        )
//                                    }
//                                }
//                                
//                                VStack(alignment: .leading, spacing: Spacing.medium) {
//                                    Text("Monitoring")
//                                        .font(.headline.weight(.semibold))
//                                        .foregroundStyle(.primary)
//                                    
//                                    Text("All glucose measurements.")
//                                        .font(.caption)
//                                        .foregroundStyle(.secondary)
//                                    
//                                    Text("Negative growth")
//                                        .font(.caption.weight(.medium))
//                                        .foregroundStyle(.orange)
//                                    
//                                    LineChart(
//                                        data: [3, 8, 5, 12, 7, 15, 9, 11, 6, 13, 8],
//                                        color: .healthPrimary
//                                    )
//                                }
//                                .padding()
//                                .cardStyle()
//                            }
//                            .padding()
//                        }
//                        .navigationTitle("Glucose Monitoring")
//                    }
//                    
//                    NavigationLink("Success Notification") {
//                        VStack {
//                            Spacer()
//                            
//                            SuccessNotification(
//                                timestamp: "5:05 pm",
//                                value: "3,2",
//                                unit: "mmol/L",
//                                status: "Hypos level!"
//                            )
//                            
//                            Spacer()
//                        }
//                        .background(Color(.systemGroupedBackground))
//                        .navigationTitle("Success")
//                    }
//                }
                
                Section("Menu & Navigation") {
                    NavigationLink("Menu Items") {
                        VStack(spacing: Spacing.small) {
                            ProfileHeader(
                                name: "Jason Bean",
                                subtitle: "Type 1 diabetes"
                            )
                            .padding(.bottom)
                            
                            KnowledgeCard(
                                title: "Got a question?",
                                subtitle: "Read knowledge base"
                            )
                            
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
                        }
                        .padding()
                        .navigationTitle("Menu")
                    }
                }
                
               
                Section("Design Tokens") {
                    NavigationLink("Colors & Typography") {
                        VStack(alignment: .leading, spacing: Spacing.large) {
                            // Colors
                            VStack(alignment: .leading, spacing: Spacing.medium) {
                                Text("Healthcare Colors")
                                    .font(.headline.weight(.semibold))
                                
                                HStack(spacing: Spacing.small) {
                                    ColorSwatch("Primary", color: .healthPrimary)
                                    ColorSwatch("Success", color: .healthSuccess)
                                    ColorSwatch("Warning", color: .healthWarning)
                                    ColorSwatch("Error", color: .healthError)
                                }
                            }
                            
                            // Typography
                            VStack(alignment: .leading, spacing: Spacing.medium) {
                                Text("Typography")
                                    .font(.headline.weight(.semibold))
                                
                                VStack(alignment: .leading, spacing: Spacing.small) {
                                    Text("Large Title")
                                        .font(.largeTitle.weight(.bold))
                                    Text("Title")
                                        .font(.title.weight(.semibold))
                                    Text("Headline")
                                        .font(.headline.weight(.medium))
                                    Text("Body Text")
                                        .font(.body)
                                    Text("Caption")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                            
                            // Buttons
                            VStack(alignment: .leading, spacing: Spacing.medium) {
                                Text("Buttons")
                                    .font(.headline.weight(.semibold))
                                
//                                HStack(spacing: Spacing.medium) {
//                                    HealthButton("Primary", style: .primary) {}
//                                    HealthButton("Secondary", style: .secondary) {}
//                                    HealthButton("Danger", style: .danger) {}
//                                }
                            }
                            
                            Spacer()
                        }
                        .padding()
                        .navigationTitle("Design Tokens")
                    }
                }
            }
            .navigationTitle("WalnutDesignSystem")
        }
    }
}

/// Color swatch component for showing design tokens
struct ColorSwatch: View {
    private let title: String
    private let color: Color
    
    init(_ title: String, color: Color) {
        self.title = title
        self.color = color
    }
    
    var body: some View {
        VStack(spacing: Spacing.xs) {
            RoundedRectangle(cornerRadius: 8)
                .fill(color)
                .frame(width: 60, height: 40)
            
            Text(title)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
    }
}

#Preview {
    ComponentShowcase()
}
