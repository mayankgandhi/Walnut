//
//  iCloudError.swift
//  Walnut
//
//  Created by Mayank Gandhi on 08/06/25.
//  Copyright © 2025 m. All rights reserved.
//


import CloudKit
import Foundation

enum iCloudError: Error {
    case noAccount
    case restricted
    case temporarilyUnavailable
    case couldNotDetermine
    case unknown
}

enum iCloudService {
    static func checkAccountStatus() async throws {
        return try await withCheckedThrowingContinuation { continuation in
            CKContainer.default().accountStatus { status, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }

                switch status {
                case .available:
                    continuation.resume(returning: ())
                case .noAccount:
                    continuation.resume(throwing: iCloudError.noAccount)
                case .restricted:
                    continuation.resume(throwing: iCloudError.restricted)
                case .temporarilyUnavailable:
                    continuation.resume(throwing: iCloudError.temporarilyUnavailable)
                case .couldNotDetermine:
                    continuation.resume(throwing: iCloudError.couldNotDetermine)
                @unknown default:
                    continuation.resume(throwing: iCloudError.unknown)
                }
            }
        }
    }
}
