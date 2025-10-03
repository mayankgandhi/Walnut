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
    
    enum UserIDSource {
        case keychain
        case vendorID
        case newGenerated
    }
    
    func getUserID() async -> (id: String, source: UserIDSource) {
        // 1. Always check keychain first (works for everyone)
        if let keychainID = getFromKeychain() {
            return (keychainID, .keychain)
        }
        
        // 2. try to use vendor ID as base
        if let vendorID = await UIDevice.current.identifierForVendor?.uuidString {
            // Create a consistent ID based on vendor ID
            let stableID = createStableID(from: vendorID)
            saveToKeychain(stableID)
            return (stableID, .vendorID)
        }
        
        // 3. Last resort: generate new ID
        let newID = UUID().uuidString
        saveToKeychain(newID)
        return (newID, .newGenerated)
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
    
}


