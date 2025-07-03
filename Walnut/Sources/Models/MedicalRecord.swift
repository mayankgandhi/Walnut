//
//  MedicalRecord.swift
//  Walnut
//
//  Created by Mayank Gandhi on 03/07/25.
//  Copyright © 2025 m. All rights reserved.
//

import Foundation

struct MedicalRecord: Codable, Identifiable, Hashable {
    let id: UUID
    let createdAt: Date
    let dateRecorded: Date
    let notes: String
    let providerName: String
    let recordType: String
    let summary: String
    let title: String
    let updatedAt: Date
}
