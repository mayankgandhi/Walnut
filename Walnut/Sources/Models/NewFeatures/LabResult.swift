//
//  LabReport.swift
//  Walnut
//
//  Created by Mayank Gandhi on 03/07/25.
//  Copyright © 2025 m. All rights reserved.
//

import Foundation

struct LabReport: Codable, Identifiable, Hashable {
    
    let id: UUID
    
    let category: String
    let labName: String
    let resultDate: Date
    let status: String
    let testName: String
    
    let createdAt: Date
    let updatedAt: Date
    
    init(
        id: UUID = UUID(),
        category: String,
        labName: String,
        resultDate: Date,
        status: String,
        testName: String,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.category = category
        self.labName = labName
        self.resultDate = resultDate
        self.status = status
        self.testName = testName
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

// MARK: - Convenience Extensions
extension LabReport {
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
extension LabReport {
    static let sampleData: [LabReport] = [
        LabReport(
            category: "Blood Work",
            labName: "LabCorp",
            resultDate: Date().addingTimeInterval(-86400 * 2), // 2 days ago
            status: "completed",
            testName: "Complete Blood Count"
        ),
        LabReport(
            category: "Imaging",
            labName: "Quest Diagnostics",
            resultDate: Date().addingTimeInterval(-86400 * 7), // 1 week ago
            status: "pending",
            testName: "Chest X-Ray"
        ),
        LabReport(
            category: "Chemistry",
            labName: "LabCorp",
            resultDate: Date().addingTimeInterval(-86400 * 14), // 2 weeks ago
            status: "completed",
            testName: "Lipid Panel"
        )
    ]
}
