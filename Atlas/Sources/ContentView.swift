//
//  ContentView.swift
//  Atlas
//
//  Created by Mayank Gandhi on 08/08/25.
//  Copyright © 2025 m. All rights reserved.
//

import SwiftUI
import WalnutDesignSystem

struct ContentView: View {
    
    @State private var fullName = ""
    @State private var selectedBloodType: String? = nil
    @State private var selectedDate: Date? = nil
    @State private var notificationsEnabled = true
    
    private let bloodTypes = ["A+", "A-", "B+", "B-", "O+", "O-", "AB+", "AB-"]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: Spacing.large) {
                    // Header with ProfileHeader component
                
                    
                    // Input Fields Demo Section
                    VStack(alignment: .leading, spacing: Spacing.small) {
                        Text("Patient Information")
                            .font(.system(.title2, design: .rounded, weight: .bold))
                            .padding(.horizontal, Spacing.medium)
                        
                        VStack(spacing: Spacing.medium) {
                            TextFieldItem(
                                icon: "person.fill",
                                title: "Full Name",
                                text: $fullName,
                                placeholder: "Enter your full name",
                                helperText: "This will be displayed on your profile",
                                isRequired: true
                            )
                            
                            MenuPickerItem(
                                icon: "drop.fill",
                                title: "Blood Type",
                                selectedOption: $selectedBloodType,
                                options: bloodTypes,
                                placeholder: "Select blood type",
                                helperText: "Required for emergency situations",
                                iconColor: .red,
                                isRequired: true
                            )
                            
                            DatePickerItem(
                                icon: "calendar",
                                title: "Date of Birth",
                                selectedDate: $selectedDate,
                                helperText: "Used for age calculations",
                                iconColor: .blue,
                                isRequired: true
                            )
                            
                            ToggleItem(
                                icon: "bell.fill",
                                title: "Medication Reminders",
                                subtitle: "Get notified when it's time to take medication",
                                isOn: $notificationsEnabled,
                                helperText: "Push notifications will be sent to your device",
                                iconColor: .orange
                            )
                        }
                        .padding(.horizontal, Spacing.medium)
                    }
                    
                    // Menu List Items Demo Section
                    VStack(alignment: .leading, spacing: Spacing.small) {
                        Text("Quick Actions")
                            .font(.system(.title2, design: .rounded, weight: .bold))
                            .padding(.horizontal, Spacing.medium)
                        
                        VStack(spacing: Spacing.xs) {
                            MenuListItem(
                                icon: "heart.text.square",
                                title: "Biomarkers",
                                subtitle: "Lab results and health metrics",
                                iconColor: .healthPrimary,
                                badge: 2
                            )
                            
                            MenuListItem(
                                icon: "pills.fill",
                                title: "Medications",
                                subtitle: "Prescription management",
                                iconColor: .medication,
                                badge: 1
                            )
                            
                            MenuListItem(
                                icon: "chart.line.uptrend.xyaxis",
                                title: "Health Trends",
                                subtitle: "View analytics and patterns",
                                iconColor: .blue
                            )
                            
                            MenuListItem(
                                icon: "gearshape.fill",
                                title: "Settings",
                                subtitle: "App preferences and account",
                                iconColor: .gray
                            )
                        }
                        .padding(.horizontal, Spacing.medium)
                    }
                    
                    Spacer(minLength: 50)
                }
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Atlas")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

#Preview {
    ContentView()
}
