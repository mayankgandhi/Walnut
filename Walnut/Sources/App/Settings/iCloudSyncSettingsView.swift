//
//  iCloudSyncSettingsView.swift
//  Walnut
//
//  Created by Mayank Gandhi on 01/09/25.
//  Copyright © 2025 m. All rights reserved.
//

import SwiftUI
import WalnutDesignSystem
import CloudKit

struct iCloudSyncSettingsView: View {
    @State private var syncService = iCloudSyncService()
    @Environment(\.dismiss) private var dismiss
    @State private var showStatusView = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Spacing.large) {
                    // Header
                    headerSection
                    
                    // iCloud Account Status
                    accountStatusSection
                    
                    // Sync Toggle
                    if syncService.canSync {
                        syncToggleSection
                    }
                    
                    // Sync Status (if enabled)
                    if syncService.isEnabled {
                        syncStatusSection
                    }
                    
                    // Information Section
                    informationSection
                    
                    Spacer()
                }
                .padding(.horizontal, Spacing.medium)
                .padding(.top, Spacing.medium)
            }
            .navigationTitle("iCloud Sync")
            .navigationBarTitleDisplayMode(.large)
            .navigationBarBackButtonHidden(false)
            .sheet(isPresented: $showStatusView) {
                iCloudSyncStatusView()
            }
        }
    }
    
    // MARK: - View Components
    
    private var headerSection: some View {
        VStack(spacing: Spacing.medium) {
            Image(systemName: "icloud")
                .font(.system(size: 64, weight: .light))
                .foregroundStyle(.blue)
            
            VStack(spacing: Spacing.xs) {
                Text("Keep Your Data in Sync")
                    .font(.title2.weight(.semibold))
                    .foregroundStyle(.primary)
                
                Text("Sync your medical records across all your devices")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(.vertical, Spacing.large)
    }
    
    private var accountStatusSection: some View {
        HealthCard {
            VStack(spacing: Spacing.medium) {
                HStack {
                    Text("iCloud Account")
                        .font(.headline.weight(.semibold))
                        .foregroundStyle(.primary)
                    
                    Spacer()
                    
                    if syncService.isAccountAvailable {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(Color.healthSuccess)
                    } else {
                        Image(systemName: "exclamationmark.circle.fill")
                            .foregroundStyle(Color.healthError)
                    }
                }
                
                HStack {
                    Text(syncService.accountStatusText)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    
                    Spacer()
                }
            }
        }
    }
    
    private var syncToggleSection: some View {
        HealthCard {
            VStack(spacing: Spacing.medium) {
                HStack {
                    VStack(alignment: .leading, spacing: Spacing.xs) {
                        Text("Enable iCloud Sync")
                            .font(.headline.weight(.semibold))
                            .foregroundStyle(.primary)
                        
                        Text("Sync your medical data across all devices")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    
                    Spacer()
                    
                    Toggle("", isOn: Binding(
                        get: { syncService.isEnabled },
                        set: { isEnabled in
                            if isEnabled {
                                syncService.enableiCloudSync()
                            } else {
                                syncService.disableiCloudSync()
                            }
                        }
                    ))
                    .toggleStyle(SwitchToggleStyle(tint: .healthPrimary))
                }
            }
        }
    }
    
    private var syncStatusSection: some View {
        VStack(spacing: Spacing.medium) {
            HStack {
                Text("Sync Status")
                    .font(.headline)
                    .foregroundStyle(.secondary)
                
                Spacer()
                
                Button("View Details") {
                    showStatusView = true
                }
                .font(.subheadline)
                .foregroundStyle(Color.healthPrimary)
            }
            
            HealthCard {
                VStack(spacing: Spacing.medium) {
                    // Quick Status
                    HStack(spacing: Spacing.medium) {
                        Circle()
                            .fill(syncService.syncStatusColor)
                            .frame(width: 12, height: 12)
                        
                        VStack(alignment: .leading, spacing: Spacing.xs) {
                            Text(syncService.syncStatus.displayText)
                                .font(.subheadline.weight(.medium))
                                .foregroundStyle(.primary)
                            
                            if syncService.lastSyncDate != nil {
                                Text(syncService.lastSyncText)
                                    .font(.caption)
                                    .foregroundStyle(.tertiary)
                            }
                        }
                        
                        Spacer()
                        
                        if syncService.isSyncing {
                            ProgressView()
                                .scaleEffect(0.8)
                        }
                    }
                    
                    // Sync Progress (if syncing)
                    if syncService.isSyncing {
                        VStack(spacing: Spacing.xs) {
                            ProgressView(value: syncService.syncProgress)
                                .progressViewStyle(LinearProgressViewStyle(tint: .healthPrimary))
                            
                            HStack {
                                Text("Syncing... \(Int(syncService.syncProgress * 100))%")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                
                                Spacer()
                            }
                        }
                    }
                    
                    // Sync Actions
                    if !syncService.isSyncing && syncService.canSync {
                        HStack {
                            Spacer()
                            
                            Button("Sync Now") {
                                syncService.syncNow()
                            }
                            .buttonStyle(.bordered)
                            .controlSize(.small)
                        }
                    }
                }
            }
        }
    }
    
    private var informationSection: some View {
        VStack(alignment: .leading, spacing: Spacing.medium) {
            Text("About iCloud Sync")
                .font(.headline)
                .foregroundStyle(.secondary)
            
            VStack(alignment: .leading, spacing: Spacing.small) {
                informationItem(
                    icon: "shield.fill",
                    title: "Secure & Private",
                    description: "Your data is encrypted and only accessible by you"
                )
                
                informationItem(
                    icon: "arrow.2.squarepath",
                    title: "Automatic Sync",
                    description: "Changes sync automatically across all your devices"
                )
                
                informationItem(
                    icon: "icloud.and.arrow.down",
                    title: "Offline Access",
                    description: "Your data is available even when you're offline"
                )
                
                informationItem(
                    icon: "externaldrive.badge.icloud",
                    title: "No Extra Storage",
                    description: "Uses your existing iCloud storage quota"
                )
            }
            
            if !syncService.isAccountAvailable {
                VStack(alignment: .leading, spacing: Spacing.small) {
                    Text("To enable iCloud sync:")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(.primary)
                    
                    VStack(alignment: .leading, spacing: Spacing.xs) {
                        Text("1. Open Settings app")
                        Text("2. Sign in to iCloud")
                        Text("3. Enable iCloud for Walnut")
                        Text("4. Return to this screen")
                    }
                    .font(.caption)
                    .foregroundStyle(.secondary)
                }
                .padding(Spacing.medium)
                .background(Color.blue.opacity(0.1))
                .cornerRadius(12)
            }
        }
    }
    
    @ViewBuilder
    private func informationItem(icon: String, title: String, description: String) -> some View {
        HStack(spacing: Spacing.medium) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(Color.healthPrimary)
                .frame(width: 24, height: 24)
            
            VStack(alignment: .leading, spacing: Spacing.xs) {
                Text(title)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.primary)
                
                Text(description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
        }
    }
}

#Preview {
    NavigationStack {
        iCloudSyncSettingsView()
    }
}
