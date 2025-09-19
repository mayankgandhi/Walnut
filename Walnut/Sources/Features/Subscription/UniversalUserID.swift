//
//  UniversalUserID.swift
//  Walnut
//
//  Created by Mayank Gandhi on 19/09/25.
//  Copyright © 2025 m. All rights reserved.
//


import Foundation
import Security
import UIKit
import NotificationCenter

class UniversalUserID {
    private let keychainService = "m.walnut.userid"
    private let keychainAccount = "user-identifier"
    private let iCloudKey = "synced-user-id"
    private let store = NSUbiquitousKeyValueStore.default
    
    enum UserIDSource {
        case keychain
        case iCloud
        case vendorID
        case newGenerated
    }
    
    func getUserID() async -> (id: String, source: UserIDSource) {
        // 1. Always check keychain first (works for everyone)
        if let keychainID = getFromKeychain() {
            if iCloudAvailable() {
                syncToiCloudIfNeeded(keychainID)
            }
            return (keychainID, .keychain)
        }
        
        // 2. If iCloud is available, check there
        if iCloudAvailable(), let iCloudID = getFromiCloud() {
            saveToKeychain(iCloudID)
            return (iCloudID, .iCloud)
        }
        
        // 3. For non-iCloud users, try to use vendor ID as base
        if let vendorID = await UIDevice.current.identifierForVendor?.uuidString {
            // Create a consistent ID based on vendor ID
            let stableID = createStableID(from: vendorID)
            saveToKeychain(stableID)
            return (stableID, .vendorID)
        }
        
        // 4. Last resort: generate new ID
        let newID = UUID().uuidString
        saveToKeychain(newID)
        if iCloudAvailable() {
            saveToiCloud(newID)
        }
        return (newID, .newGenerated)
    }
    
    // MARK: - iCloud Availability Check
    private func iCloudAvailable() -> Bool {
        if let _ = FileManager.default.ubiquityIdentityToken {
            return true
        }
        return false
    }
    
    // MARK: - Stable ID Generation
    private func createStableID(from vendorID: String) -> String {
        // Create a more stable ID by hashing vendor ID with app identifier
        let appSalt = Bundle.main.bundleIdentifier ?? "health-app"
        let combined = "\(vendorID)-\(appSalt)"
        
        // Simple hash to create consistent but unique ID
        var hasher = Hasher()
        hasher.combine(combined)
        let hashValue = hasher.finalize()
        
        // Convert to UUID-like format for consistency
        return "stable-\(abs(hashValue))-\(vendorID.suffix(8))"
    }
    
    private func syncToiCloudIfNeeded(_ id: String) {
        guard iCloudAvailable() else { return }
        if getFromiCloud() != id {
            saveToiCloud(id)
        }
    }
    
    // MARK: - User Education
    func getiCloudStatus() -> (available: Bool, recommendation: String?) {
        let available = iCloudAvailable()
        let recommendation = available ? nil : 
            "Enable iCloud in Settings to sync your health data across devices"
        return (available, recommendation)
    }
    
    // MARK: - Storage Methods (same as before)
    private func saveToKeychain(_ value: String) {
        let data = value.data(using: .utf8)!
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: keychainService,
            kSecAttrAccount as String: keychainAccount,
            kSecValueData as String: data
        ]
        
        SecItemDelete(query as CFDictionary)
        SecItemAdd(query as CFDictionary, nil)
    }
    
    private func getFromKeychain() -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: keychainService,
            kSecAttrAccount as String: keychainAccount,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var result: AnyObject?
        guard SecItemCopyMatching(query as CFDictionary, &result) == errSecSuccess,
              let data = result as? Data,
              let string = String(data: data, encoding: .utf8) else {
            return nil
        }
        return string
    }
    
    private func saveToiCloud(_ value: String) {
        guard iCloudAvailable() else { return }
        store.set(value, forKey: iCloudKey)
        store.synchronize()
    }
    
    private func getFromiCloud() -> String? {
        guard iCloudAvailable() else { return nil }
        let value = store.string(forKey: iCloudKey)
        return value?.isEmpty == false ? value : nil
    }
    
    // MARK: - Sync Monitoring (only if iCloud available)
    func startMonitoringSync() {
        guard iCloudAvailable() else { return }
        
        NotificationCenter.default.addObserver(
            forName: NSUbiquitousKeyValueStore.didChangeExternallyNotification,
            object: store,
            queue: .main
        ) { [weak self] _ in
            self?.handleiCloudSync()
        }
    }
    
    private func handleiCloudSync() {
        guard iCloudAvailable(),
              let iCloudID = getFromiCloud(),
              let keychainID = getFromKeychain(),
              iCloudID != keychainID else { return }
        
        saveToKeychain(iCloudID)
        NotificationCenter.default.post(name: Notification.Name("userIdUpdated"), object: iCloudID)
    }
}


