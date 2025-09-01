//
//  iCloudSyncStatusView.swift
//  Walnut
//
//  Created by Mayank Gandhi on 01/09/25.
//  Copyright © 2025 m. All rights reserved.
//

import SwiftUI
import WalnutDesignSystem
import CloudKit

struct iCloudSyncStatusView: View {
    @State private var syncService = iCloudSyncService()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Spacing.large) {
                    // Header
                    VStack(spacing: Spacing.medium) {
                        Image(systemName: "icloud")
                            .font(.system(size: 48, weight: .light))
                            .foregroundStyle(Color.healthPrimary)
                        
                        Text("Sync Status")
                            .font(.largeTitle.weight(.bold))
                            .foregroundStyle(.primary)
                    }
                    .padding(.top, Spacing.large)
                    
                    // Status Items
                    VStack(spacing: Spacing.small) {
                        syncStatusItem(
                            title: "Account",
                            subtitle: syncService.accountStatusText,
                            isSuccess: syncService.isAccountAvailable
                        )
                        
                        syncStatusItem(
                            title: "iCloud Storage",
                            subtitle: syncService.iCloudStorageStatus.displayText,
                            isSuccess: syncService.iCloudStorageStatus == .available
                        )
                        
                        syncStatusItem(
                            title: "Items in iCloud",
                            subtitle: syncService.syncStatus.displayText,
                            isSuccess: syncService.syncStatus.isSuccess
                        )
                        
                        syncStatusItem(
                            title: "Items on Device",
                            subtitle: "All items on this device are synced to iCloud",
                            isSuccess: syncService.syncStatus.isSuccess
                        )
                    }
                    
                    // Sync Controls
                    if syncService.isEnabled {
                        syncControlsSection
                    }
                    
                    // Help Text
                    helpTextSection
                    
                    Spacer()
                }
                .padding(.horizontal, Spacing.medium)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        dismiss()
                    }
                }
                
                if syncService.canSync {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Sync Now") {
                            syncService.syncNow()
                        }
                        .disabled(syncService.isSyncing)
                    }
                }
            }
        }
    }
    
    // MARK: - View Components
    
    @ViewBuilder
    private func syncStatusItem(title: String, subtitle: String, isSuccess: Bool) -> some View {
        HStack(spacing: Spacing.medium) {
            // Status Indicator
            ZStack {
                Circle()
                    .fill(isSuccess ? Color.healthSuccess : Color.secondary)
                    .frame(width: 32, height: 32)
                
                Image(systemName: isSuccess ? "checkmark" : "exclamationmark")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.white)
            }
            
            // Content
            VStack(alignment: .leading, spacing: Spacing.xs) {
                Text(title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.primary)
                
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.leading)
            }
            
            Spacer()
        }
        .padding(.vertical, Spacing.small)
    }
    
    private var syncControlsSection: some View {
        VStack(spacing: Spacing.medium) {
            if syncService.isSyncing {
                VStack(spacing: Spacing.small) {
                    ProgressView(value: syncService.syncProgress)
                        .progressViewStyle(LinearProgressViewStyle(tint: .healthPrimary))
                        .scaleEffect(1.2)
                    
                    Text("Syncing... \(Int(syncService.syncProgress * 100))%")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal, Spacing.medium)
            }
            
            if let errorMessage = syncService.errorMessage {
                HStack {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundStyle(Color.healthError)
                    
                    Text(errorMessage)
                        .font(.caption)
                        .foregroundStyle(Color.healthError)
                    
                    Spacer()
                }
                .padding(Spacing.small)
                .background(Color.healthError.opacity(0.1))
                .cornerRadius(8)
            }
            
            HStack {
                Text(syncService.lastSyncText)
                    .font(.caption)
                    .foregroundStyle(.tertiary)
                
                Spacer()
            }
        }
    }
    
    private var helpTextSection: some View {
        VStack(alignment: .leading, spacing: Spacing.small) {
            Text("These fields help to give you an indication of Walnut's sync status.")
                .font(.caption)
                .foregroundStyle(.tertiary)
                .multilineTextAlignment(.leading)
            
            if !syncService.isAccountAvailable {
                VStack(alignment: .leading, spacing: Spacing.xs) {
                    Text("To enable iCloud sync:")
                        .font(.caption.weight(.medium))
                        .foregroundStyle(.secondary)
                    
                    Text("• Sign in to iCloud in Settings app")
                    Text("• Enable iCloud for Walnut")
                    Text("• Restart the app if needed")
                }
                .font(.caption)
                .foregroundStyle(.tertiary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, Spacing.large)
    }
}

#Preview {
    iCloudSyncStatusView()
}
