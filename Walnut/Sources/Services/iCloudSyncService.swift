//
//  iCloudSyncService.swift
//  Walnut
//
//  Created by Mayank Gandhi on 01/09/25.
//  Copyright © 2025 m. All rights reserved.
//

import Foundation
import CloudKit
import SwiftUI
import Observation

@Observable
class iCloudSyncService {
    
    // MARK: - Published Properties
    var iCloudAccountStatus: CKAccountStatus = .couldNotDetermine
    var iCloudStorageStatus: StorageStatus = .checking
    var syncStatus: SyncStatus = .notSynced
    var lastSyncDate: Date?
    var isEnabled: Bool = false
    var syncProgress: Double = 0.0
    var isSyncing: Bool = false
    var errorMessage: String?
    
    // MARK: - Private Properties
    private let container = CKContainer(identifier: "iCloud.m.walnut")
    private let database: CKDatabase
    private var syncTimer: Timer?
    
    // MARK: - Supporting Types
    
    enum StorageStatus {
        case checking
        case available
        case unavailable
        case quotaExceeded
        
        var displayText: String {
            switch self {
            case .checking: return "Checking storage..."
            case .available: return "Storage available"
            case .unavailable: return "Storage unavailable"
            case .quotaExceeded: return "Storage quota exceeded"
            }
        }
    }
    
    enum SyncStatus {
        case notSynced
        case synced
        case syncing
        case error(String)
        
        var displayText: String {
            switch self {
            case .notSynced: return "Not synced"
            case .synced: return "All items synced to iCloud"
            case .syncing: return "Syncing..."
            case .error(let message): return "Sync error: \(message)"
            }
        }
        
        var isSuccess: Bool {
            if case .synced = self { return true }
            return false
        }
        
        var isError: Bool {
            if case .error = self { return true }
            return false
        }
    }
    
    // MARK: - Initializer
    
    init() {
        self.database = container.privateCloudDatabase
        checkiCloudStatus()
        setupSyncTimer()
    }
    
    // MARK: - Public Methods
    
    func enableiCloudSync() {
        isEnabled = true
        UserDefaults.standard.set(true, forKey: "iCloudSyncEnabled")
        Task {
            await performInitialSync()
        }
    }
    
    func disableiCloudSync() {
        isEnabled = false
        UserDefaults.standard.set(false, forKey: "iCloudSyncEnabled")
        syncStatus = .notSynced
        lastSyncDate = nil
    }
    
    func syncNow() {
        guard isEnabled && !isSyncing else { return }
        Task {
            await performSync()
        }
    }
    
    // MARK: - Private Methods
    
    private func checkiCloudStatus() {
        isEnabled = UserDefaults.standard.bool(forKey: "iCloudSyncEnabled")
        
        container.accountStatus { [weak self] status, error in
            DispatchQueue.main.async {
                self?.iCloudAccountStatus = status
                if status == .available {
                    self?.checkStorageQuota()
                } else {
                    self?.iCloudStorageStatus = .unavailable
                }
            }
        }
    }
    
    private func checkStorageQuota() {
        // Simulate storage check - in real implementation, you'd check actual usage
        Task {
            try? await Task.sleep(for: .seconds(1))
            await MainActor.run {
                self.iCloudStorageStatus = .available
            }
        }
    }
    
    private func setupSyncTimer() {
        // Check sync status every 30 seconds if enabled
        syncTimer = Timer.scheduledTimer(withTimeInterval: 30.0, repeats: true) { [weak self] _ in
            guard let self = self, self.isEnabled && !self.isSyncing else { return }
            Task {
                await self.checkSyncStatus()
            }
        }
    }
    
    @MainActor
    private func performInitialSync() async {
        guard iCloudAccountStatus == .available else { return }
        
        isSyncing = true
        syncStatus = .syncing
        syncProgress = 0.0
        errorMessage = nil
        
        do {
            // Simulate sync process
            for progress in stride(from: 0.0, through: 1.0, by: 0.1) {
                syncProgress = progress
                try await Task.sleep(for: .milliseconds(300))
            }
            
            // TODO: Implement actual CloudKit sync logic here
            // This would involve:
            // 1. Fetch local data changes
            // 2. Push changes to CloudKit
            // 3. Pull remote changes from CloudKit
            // 4. Resolve conflicts
            // 5. Update local database
            
            syncStatus = .synced
            lastSyncDate = Date()
            syncProgress = 1.0
            
        } catch {
            syncStatus = .error(error.localizedDescription)
            errorMessage = error.localizedDescription
        }
        
        isSyncing = false
    }
    
    @MainActor
    private func performSync() async {
        await performInitialSync()
    }
    
    private func checkSyncStatus() async {
        // In real implementation, this would check if local data is in sync with CloudKit
        // For now, we'll simulate it
        if isEnabled && syncStatus.isSuccess {
            // Randomly simulate sync issues for demo
            if Int.random(in: 1...10) == 1 {
                await MainActor.run {
                    syncStatus = .error("Network unavailable")
                }
            }
        }
    }
    
    deinit {
        syncTimer?.invalidate()
    }
}

// MARK: - Computed Properties

extension iCloudSyncService {
    
    var accountStatusText: String {
        switch iCloudAccountStatus {
        case .available:
            return "Logged in to iCloud account"
        case .noAccount:
            return "No iCloud account"
        case .restricted:
            return "iCloud account restricted"
        case .couldNotDetermine:
            return "Checking iCloud account..."
        case .temporarilyUnavailable:
            return "iCloud temporarily unavailable"
        @unknown default:
            return "Unknown iCloud status"
        }
    }
    
    var isAccountAvailable: Bool {
        iCloudAccountStatus == .available
    }
    
    var canSync: Bool {
        isAccountAvailable && iCloudStorageStatus == .available
    }
    
    var syncStatusColor: Color {
        switch syncStatus {
        case .synced:
            return .healthSuccess
        case .syncing:
            return .healthPrimary
        case .notSynced:
            return .secondary
        case .error:
            return .healthError
        }
    }
    
    var lastSyncText: String {
        guard let lastSyncDate = lastSyncDate else {
            return "Never synced"
        }
        
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return "Last synced \(formatter.localizedString(for: lastSyncDate, relativeTo: Date()))"
    }
}