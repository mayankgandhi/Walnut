//
//  LabResult.swift
//  Walnut
//
//  Created by Mayank Gandhi on 03/07/25.
//  Copyright © 2025 m. All rights reserved.
//


import Foundation

struct LabResult: Codable, Identifiable, Hashable {
    let id: UUID
    let category: String
    let createdAt: Date
    let labName: String
    let resultDate: Date
    let status: String
    let testName: String
    let updatedAt: Date
    
    init(
        id: UUID = UUID(),
        category: String,
        createdAt: Date = Date(),
        labName: String,
        resultDate: Date,
        status: String,
        testName: String,
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.category = category
        self.createdAt = createdAt
        self.labName = labName
        self.resultDate = resultDate
        self.status = status
        self.testName = testName
        self.updatedAt = updatedAt
    }
}

// MARK: - Convenience Extensions
extension LabResult {
    enum Status: String, CaseIterable {
        case pending = "pending"
        case completed = "completed"
        case cancelled = "cancelled"
        case inProgress = "in_progress"
        
        var displayName: String {
            switch self {
            case .pending: return "Pending"
            case .completed: return "Completed"
            case .cancelled: return "Cancelled"
            case .inProgress: return "In Progress"
            }
        }
    }
    
    var statusEnum: Status? {
        Status(rawValue: status)
    }
    
    var isCompleted: Bool {
        statusEnum == .completed
    }
    
    var isPending: Bool {
        statusEnum == .pending
    }
}

// MARK: - Sample Data
extension LabResult {
    static let sampleData: [LabResult] = [
        LabResult(
            category: "Blood Work",
            labName: "LabCorp",
            resultDate: Date().addingTimeInterval(-86400 * 2), // 2 days ago
            status: "completed",
            testName: "Complete Blood Count"
        ),
        LabResult(
            category: "Imaging",
            labName: "Quest Diagnostics",
            resultDate: Date().addingTimeInterval(-86400 * 7), // 1 week ago
            status: "pending",
            testName: "Chest X-Ray"
        ),
        LabResult(
            category: "Chemistry",
            labName: "LabCorp",
            resultDate: Date().addingTimeInterval(-86400 * 14), // 2 weeks ago
            status: "completed",
            testName: "Lipid Panel"
        )
    ]
}