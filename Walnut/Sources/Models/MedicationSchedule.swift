//
//  MedicationSchedule.swift
//  Walnut
//
//  Created by Mayank Gandhi on 06/09/25.
//  Copyright © 2025 m. All rights reserved.
//

import Foundation
import SwiftUI
import AIKit

// MARK: - Medication Frequency System

enum MedicationFrequency: Codable, Hashable {
    
    // Time-based frequencies
    case daily(times: [DateComponents]) // e.g., daily at 8:00 AM and 6:00 PM
    case hourly(interval: Int, startTime: DateComponents? = nil) // e.g., every 4 hours
    case weekly(dayOfWeek: Weekday, time: DateComponents) // e.g., every Monday at 9 AM
    case biweekly(dayOfWeek: Weekday, time: DateComponents) // e.g., every other Monday at 9 AM
    case monthly(dayOfMonth: Int, time: DateComponents) // e.g., 1st of every month at 10 AM
    case mealBased(mealTime: MealTime, timing: MedicationTime?)
    
    var icon: String {
        switch self {
            case .daily:
                return "clock.fill"
            case .hourly:
                return "timer"
            case .weekly, .biweekly:
                return "calendar.badge.clock"
            case .monthly:
                return "calendar.circle.fill"
            case .mealBased(let mealTime, _):
                return mealTime.icon
        }
    }
    
    var displayText: String {
        switch self {
            case .daily(let times):
                if times.count == 1 {
                    let timeString = formatTime(times[0])
                    return "Daily at \(timeString)"
                } else {
                    let timeStrings = times.map { formatTime($0) }
                    return "Daily at \(timeStrings.joined(separator: ", "))"
                }
            case .hourly(let interval, let startTime):
                if let startTime = startTime {
                    let timeString = formatTime(startTime)
                    return "Every \(interval) hour\(interval == 1 ? "" : "s") starting at \(timeString)"
                } else {
                    return "Every \(interval) hour\(interval == 1 ? "" : "s")"
                }
            case .weekly(let dayOfWeek, let time):
                let timeString = formatTime(time)
                return "Every \(dayOfWeek.displayName) at \(timeString)"
            case .biweekly(let dayOfWeek, let time):
                let timeString = formatTime(time)
                return "Every other \(dayOfWeek.displayName) at \(timeString)"
            case .monthly(let dayOfMonth, let time):
                let timeString = formatTime(time)
                let dayString = formatDayOfMonth(dayOfMonth)
                return "Monthly on the \(dayString) at \(timeString)"
            case .mealBased(let mealTime, let timing):
                let mealName = mealTime.displayName
                if let timing = timing {
                    return "\(timing.displayName) \(mealName)"
                } else {
                    return "With \(mealName)"
                }
        }
    }
    
    var color: Color {
        switch self {
            case .daily:
                return .blue
            case .hourly:
                return .green
            case .weekly, .biweekly:
                return .orange
            case .monthly:
                return .purple
            case .mealBased(let mealTime, _):
                return mealTime.color
        }
    }
    
    // Helper methods for formatting
    private func formatTime(_ dateComponents: DateComponents) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        
        let calendar = Calendar.current
        let date = calendar.date(from: dateComponents) ?? Date()
        return formatter.string(from: date)
    }
    
    private func formatDayOfMonth(_ day: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .ordinal
        return formatter.string(from: NSNumber(value: day)) ?? "\(day)"
    }
    
    static var jsonSchema: AIKit.OpenAIJSONSchema {
        
        // Enhanced DateComponents schema with better validation and descriptions
        let dateComponentsSchema: [String: Any] = [
            "type": "object",
            "properties": [
                "hour": [
                    "type": "integer",
                    "minimum": 0,
                    "maximum": 23,
                    "description": "Hour of the day (0-23)"
                ],
                "minute": [
                    "type": "integer",
                    "minimum": 0,
                    "maximum": 59,
                    "description": "Minute of the hour (0-59)"
                ],
                "second": [
                    "type": "integer",
                    "minimum": 0,
                    "maximum": 59,
                    "description": "Second of the minute (0-59)"
                ]
            ],
            "additionalProperties": false,
            "description": "Time components for scheduling"
        ]
        
        // Weekday enum schema with proper mapping to Swift enum
        let weekdaySchema: [String: Any] = [
            "type": "string",
            "enum": ["sunday", "monday", "tuesday", "wednesday", "thursday", "friday", "saturday"],
            "description": "Day of the week"
        ]
        
        // MealTime enum schema
        let mealTimeSchema: [String: Any] = [
            "type": "string",
            "enum": ["breakfast", "lunch", "dinner", "bedtime"],
            "description": "Meal time for medication scheduling"
        ]
        
        // MedicationTime enum schema
        let medicationTimeSchema: [String: Any] = [
            "type": "string",
            "enum": ["before", "after"],
            "description": "Timing relative to meal (before or after)"
        ]
        
        // Enhanced daily case with better validation
        let dailyCase: [String: Any] = [
            "type": "object",
            "properties": [
                "type": [
                    "type": "string",
                    "const": "daily"
                ],
                "times": [
                    "type": "array",
                    "items": dateComponentsSchema,
                    "minItems": 1,
                    "maxItems": 24, // Reasonable limit for daily doses
                    "description": "Array of times during the day when medication should be taken"
                ]
            ],
            "required": ["type", "times"],
            "additionalProperties": false,
            "description": "Medication taken daily at specific times"
        ]
        
        // Enhanced hourly case with better validation
        let hourlyCase: [String: Any] = [
            "type": "object",
            "properties": [
                "type": [
                    "type": "string",
                    "const": "hourly"
                ],
                "interval": [
                    "type": "integer",
                    "minimum": 1,
                    "maximum": 24, // Maximum 24 hours between doses
                    "description": "Number of hours between doses"
                ],
                "startTime": [
                    "oneOf": [
                        dateComponentsSchema,
                        ["type": "null"]
                    ],
                    "description": "Optional start time for the first dose"
                ]
            ],
            "required": ["type", "interval"],
            "additionalProperties": false,
            "description": "Medication taken every N hours"
        ]
        
        // Enhanced weekly case
        let weeklyCase: [String: Any] = [
            "type": "object",
            "properties": [
                "type": [
                    "type": "string",
                    "const": "weekly"
                ],
                "dayOfWeek": weekdaySchema,
                "time": dateComponentsSchema
            ],
            "required": ["type", "dayOfWeek", "time"],
            "additionalProperties": false,
            "description": "Medication taken once per week on a specific day and time"
        ]
        
        // Enhanced biweekly case
        let biweeklyCase: [String: Any] = [
            "type": "object",
            "properties": [
                "type": [
                    "type": "string",
                    "const": "biweekly"
                ],
                "dayOfWeek": weekdaySchema,
                "time": dateComponentsSchema
            ],
            "required": ["type", "dayOfWeek", "time"],
            "additionalProperties": false,
            "description": "Medication taken every other week on a specific day and time"
        ]
        
        // Enhanced monthly case with better day validation
        let monthlyCase: [String: Any] = [
            "type": "object",
            "properties": [
                "type": [
                    "type": "string",
                    "const": "monthly"
                ],
                "dayOfMonth": [
                    "type": "integer",
                    "minimum": 1,
                    "maximum": 31,
                    "description": "Day of the month (1-31). For months with fewer days, will use the last day of that month"
                ],
                "time": dateComponentsSchema
            ],
            "required": ["type", "dayOfMonth", "time"],
            "additionalProperties": false,
            "description": "Medication taken once per month on a specific day and time"
        ]
        
        // Enhanced meal-based case with proper optional handling
        let mealBasedCase: [String: Any] = [
            "type": "object",
            "properties": [
                "type": [
                    "type": "string",
                    "const": "mealBased"
                ],
                "mealTime": mealTimeSchema,
                "timing": [
                    "oneOf": [
                        medicationTimeSchema,
                        ["type": "null"]
                    ],
                    "description": "Optional timing relative to the meal (before/after). If null, means 'with' the meal"
                ]
            ],
            "required": ["type", "mealTime"],
            "additionalProperties": false,
            "description": "Medication taken in relation to meals"
        ]
        
        // Main schema with comprehensive description
        let properties: [String: Any] = [
            "description": "Medication frequency schedule defining when and how often medication should be taken",
            "oneOf": [
                dailyCase,
                hourlyCase,
                weeklyCase,
                biweeklyCase,
                monthlyCase,
                mealBasedCase
            ]
        ]
        
        return AIKit.OpenAIJSONSchema(
            properties: properties,
            required: [],
            additionalProperties: false
        )
    }
    
}
