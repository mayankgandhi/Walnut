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
                   
                    
                    // Glucose monitoring section
                    VStack(alignment: .leading, spacing: Spacing.small) {
                        Text("Today's Readings")
                            .font(.headline.weight(.semibold))
                            .foregroundStyle(.primary)
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

#Preview {
    HealthDashboard()
}
