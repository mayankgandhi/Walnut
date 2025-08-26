//
//  PatientSettingsView.swift
//  Walnut
//
//  Created by Mayank Gandhi on 11/08/25.
//  Copyright © 2025 m. All rights reserved.
//

import SwiftUI
import SwiftData
import WalnutDesignSystem

struct PatientSettingsView: View {
    let patient: Patient
    @State private var showEditPatient = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: Spacing.large) {
                
                VStack(alignment: .leading, spacing: Spacing.medium) {
                    Text("Settings")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    VStack(spacing: Spacing.xs) {
                        MenuListItem(
                            icon: "pencil.circle.fill",
                            title: "Edit Profile",
                            subtitle: "Update patient information",
                            iconColor: .healthPrimary
                        ) {
                            showEditPatient = true
                        }
                        
                        MenuListItem(
                            icon: "bell.fill",
                            title: "Notifications",
                            subtitle: "Manage alerts and reminders",
                            iconColor: .orange
                        ) {
                            // TODO: Navigate to notifications settings
                        }
                        
                        MenuListItem(
                            icon: "doc.fill",
                            title: "Export Data",
                            subtitle: "Export medical records",
                            iconColor: .blue
                        ) {
                            // TODO: Export functionality
                        }
                        
                        MenuListItem(
                            icon: "shield.fill",
                            title: "Privacy & Security",
                            subtitle: "Data protection settings",
                            iconColor: .green
                        ) {
                            // TODO: Privacy settings
                        }
                    }
                }
                
                // App Settings Section
                VStack(alignment: .leading, spacing: Spacing.medium) {
                    Text("App Settings")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    VStack(spacing: Spacing.xs) {
                        MenuListItem(
                            icon: "paintbrush.fill",
                            title: "Appearance",
                            subtitle: "Theme and display options",
                            iconColor: .purple
                        ) {
                            // TODO: Appearance settings
                        }
                        
                        AboutMenuListItem()
                        
                        MenuListItem(
                            icon: "questionmark.circle.fill",
                            title: "Help & Support",
                            subtitle: "Get help and contact support",
                            iconColor: .healthPrimary
                        ) {
                            // TODO: Help screen
                        }
                    }
                }
                
                Spacer(minLength: Spacing.xl)
            }
            .padding(.horizontal, Spacing.medium)
            .padding(.top, Spacing.medium)
        }
        .sheet(isPresented: $showEditPatient) {
            PatientEditor(patient: patient)
        }
        .navigationTitle("Settings")
    }
}


#Preview {
    NavigationStack {
        PatientSettingsView(patient: .samplePatient)
            .navigationTitle("Settings")
    }
    .modelContainer(for: Patient.self, inMemory: true)
}
