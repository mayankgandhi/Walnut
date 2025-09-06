//
//  MedicationDuration.swift
//  Walnut
//
//  Created by Mayank Gandhi on 06/09/25.
//  Copyright © 2025 m. All rights reserved.
//

import Foundation
import AIKit

// MARK: - Supporting Enums

enum MedicationDuration: Codable, Hashable, CustomStringConvertible {
    case days(Int)
    case weeks(Int)
    case months(Int)
    case ongoing // Long-term medication with no end date
    case asNeeded // As needed, no specific duration
    case untilFollowUp(Date) // Until next appointment
    
    var displayText: String {
        switch self {
            case .days(let days):
                return "\(days) day\(days == 1 ? "" : "s")"
            case .weeks(let weeks):
                return "\(weeks) week\(weeks == 1 ? "" : "s")"
            case .months(let months):
                return "\(months) month\(months == 1 ? "" : "s")"
            case .ongoing:
                return "Ongoing"
            case .asNeeded:
                return "As needed"
            case .untilFollowUp(let date):
                let formatter = DateFormatter()
                formatter.dateStyle = .medium
                return "Until \(formatter.string(from: date))"
        }
    }
    
    var description: String {
        return displayText
    }
    
    var totalDays: Int? {
        switch self {
            case .days(let days):
                return days
            case .weeks(let weeks):
                return weeks * 7
            case .months(let months):
                return months * 30 // Approximate
            default:
                return nil
        }
    }
    
    static var openaiJSONSchema: OpenAIJSONSchema {
        
        // Define each case of the MedicationDuration enum
        let daysCase: [String: Any] = [
            "type": "object",
            "properties": [
                "type": ["type": "string", "const": "days"],
                "value": ["type": "integer", "minimum": 1]
            ],
            "required": ["type", "value"],
            "additionalProperties": false
        ]
        
        let weeksCase: [String: Any] = [
            "type": "object",
            "properties": [
                "type": ["type": "string", "const": "weeks"],
                "value": ["type": "integer", "minimum": 1]
            ],
            "required": ["type", "value"],
            "additionalProperties": false
        ]
        
        let monthsCase: [String: Any] = [
            "type": "object",
            "properties": [
                "type": ["type": "string", "const": "months"],
                "value": ["type": "integer", "minimum": 1]
            ],
            "required": ["type", "value"],
            "additionalProperties": false
        ]
        
        let ongoingCase: [String: Any] = [
            "type": "object",
            "properties": [
                "type": ["type": "string", "const": "ongoing"]
            ],
            "required": ["type"],
            "additionalProperties": false
        ]
        
        let asNeededCase: [String: Any] = [
            "type": "object",
            "properties": [
                "type": ["type": "string", "const": "asNeeded"]
            ],
            "required": ["type"],
            "additionalProperties": false
        ]
        
        let untilFollowUpCase: [String: Any] = [
            "type": "object",
            "properties": [
                "type": ["type": "string", "const": "untilFollowUp"],
                "date": [
                    "type": "string",
                    "format": "date-time",
                    "description": "ISO 8601 date-time string"
                ]
            ],
            "required": ["type", "date"],
            "additionalProperties": false
        ]
        
        // Main schema using oneOf to represent the enum with associated values
        let properties: [String: Any] = [
            "oneOf": [
                daysCase,
                weeksCase,
                monthsCase,
                ongoingCase,
                asNeededCase,
                untilFollowUpCase
            ]
        ]
        
        return OpenAIJSONSchema(
            properties: properties,
            required: [],
            additionalProperties: false
        )
    }
    
}
