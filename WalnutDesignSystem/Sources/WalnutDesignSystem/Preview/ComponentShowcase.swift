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
               
                Section("Reference Design 2 - Nutrition & Progress") {
                    NavigationLink("Calorie & Nutrition Tracking") {
                        ScrollView {
                            VStack(spacing: Spacing.large) {
                                
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
                            .padding()
                        }
                        .navigationTitle("Nutrition")
                    }
                }
       
                
                Section("Menu & Navigation") {
                    NavigationLink("Menu Items") {
                        VStack(spacing: Spacing.small) {
                         
                            
                            DSCard(
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
                
               
//                Section("Design Tokens") {
//                    NavigationLink("Colors & Typography") {
//                        VStack(alignment: .leading, spacing: Spacing.large) {
//                            // Colors
//                            VStack(alignment: .leading, spacing: Spacing.medium) {
//                                Text("Healthcare Colors")
//                                    .font(.headline.weight(.semibold))
//                                
//                                HStack(spacing: Spacing.small) {
//                                    ColorSwatch("Primary", color: .healthPrimary)
//                                    ColorSwatch("Success", color: .healthSuccess)
//                                    ColorSwatch("Warning", color: .healthWarning)
//                                    ColorSwatch("Error", color: .healthError)
//                                }
//                            }
//                            
//                            // Typography
//                            VStack(alignment: .leading, spacing: Spacing.medium) {
//                                Text("Typography")
//                                    .font(.headline.weight(.semibold))
//                                
//                                VStack(alignment: .leading, spacing: Spacing.small) {
//                                    Text("Large Title")
//                                        .font(.largeTitle.weight(.bold))
//                                    Text("Title")
//                                        .font(.title.weight(.semibold))
//                                    Text("Headline")
//                                        .font(.headline.weight(.medium))
//                                    Text("Body Text")
//                                        .font(.body)
//                                    Text("Caption")
//                                        .font(.caption)
//                                        .foregroundStyle(.secondary)
//                                }
//                            }
//                            
//                            // Buttons
//                            VStack(alignment: .leading, spacing: Spacing.medium) {
//                                Text("Buttons")
//                                    .font(.headline.weight(.semibold))
//                                
//                                HStack(spacing: Spacing.medium) {
//                                    DSButton("Primary", style: .primary) {}
//                                    DSButton("Secondary", style: .secondary) {}
//                                    DSButton("Danger", style: .danger) {}
//                                }
//                            }
//                            
//                            Spacer()
//                        }
//                        .padding()
//                        .navigationTitle("Design Tokens")
//                    }
//                }
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
