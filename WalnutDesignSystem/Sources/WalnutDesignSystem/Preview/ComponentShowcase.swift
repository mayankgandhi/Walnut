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
       
                
//                Section("Icons & File System") {
//                    NavigationLink("Folder Icons") {
//                        ScrollView {
//                            VStack(spacing: Spacing.large) {
//                                Text("Medical Case Folders")
//                                    .font(.title2)
//                                    .fontWeight(.bold)
//                                    .frame(maxWidth: .infinity, alignment: .leading)
//                                
//                                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: Spacing.medium), count: 3), spacing: Spacing.medium) {
//                                    FolderIcon(caseType: .consultation, documentCount: 3)
//                                    FolderIcon(caseType: .surgery, documentCount: 7)
//                                    FolderIcon(caseType: .healthCheckup, documentCount: 0)
//                                    FolderIcon(caseType: .immunisation, documentCount: 1)
//                                    FolderIcon(caseType: .followUp, documentCount: 12)
//                                    FolderIcon(caseType: .treatment, documentCount: 5)
//                                }
//                                
//                                Text("Document Files")
//                                    .font(.title2)
//                                    .fontWeight(.bold)
//                                    .frame(maxWidth: .infinity, alignment: .leading)
//                                    .padding(.top)
//                                
//                                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: Spacing.medium), count: 3), spacing: Spacing.medium) {
//                                    FileIcon(
//                                        documentType: .prescription,
//                                        fileName: "Prescription.pdf",
//                                        previewText: "Take 1 tablet daily with food. Lisinopril 10mg for blood pressure management.",
//                                        size: 70
//                                    )
//                                    
//                                    FileIcon(
//                                        documentType: .labResult,
//                                        fileName: "Blood_Test.pdf",
//                                        previewText: "Hemoglobin: 14.2 g/dL, White Blood Cells: 7,500, Platelets: 250,000",
//                                        size: 70
//                                    )
//                                    
//                                    FileIcon(
//                                        documentType: .invoice,
//                                        fileName: "Invoice.pdf",
//                                        previewText: "Consultation Fee: $150, Lab Work: $75, Total Amount: $225",
//                                        size: 70
//                                    )
//                                    
//                                    FileIcon(
//                                        documentType: .discharge,
//                                        fileName: "Discharge.pdf",
//                                        previewText: "Patient discharged in stable condition. Follow-up in 2 weeks.",
//                                        size: 70
//                                    )
//                                    
//                                    FileIcon(
//                                        documentType: .imaging,
//                                        fileName: "X-Ray.jpg",
//                                        previewText: "Normal chest X-ray. No acute findings. Heart size normal.",
//                                        size: 70
//                                    )
//                                    
//                                    FileIcon(
//                                        documentType: .unknown,
//                                        fileName: "Document.pdf",
//                                        size: 70
//                                    )
//                                }
//                            }
//                            .padding()
//                        }
//                        .navigationTitle("Icons")
//                    }
//                }
                
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
