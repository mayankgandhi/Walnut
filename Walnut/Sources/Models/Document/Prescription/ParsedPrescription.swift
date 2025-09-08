//
//  ParsedPrescription.swift
//  Walnut
//
//  Created by Mayank Gandhi on 11/07/25.
//  Copyright © 2025 m. All rights reserved.
//

import Foundation
import AIKit

struct ParsedPrescription: ParseableModel {
    
    struct Medication: Codable {
        var id: UUID
        var name: String
        var frequency: [MedicationFrequencyData]?
        var duration: MedicationDurationData
        var dosage: String?
        var instructions: String?
    }
    
    // Metadata
    var dateIssued: Date
    var doctorName: String?
    var facilityName: String?
    
    var followUpDate: Date?
    var followUpTests: [String]
    
    var notes: String?
    
    var medications: [Medication]
    
    static var parseDefinition: String {
    """
    Important Notes
    - All dates MUST be in ISO8601 format (e.g., "2025-01-15T00:00:00Z")
    - Times use 24-hour format in DateComponents (hour: 0-23)
    - Multiple frequencies can be specified for complex dosing schedules
    - When timing is ambiguous, use reasonable defaults (e.g., 8 AM for morning, 8 PM for evening)
    - UUID should be generated automatically for each medication
    """
    }
    
    static var jsonSchema: OpenAIJSONSchema {
        OpenAIJSONSchema(
            properties: [
                "dateIssued": [
                    "type": "string",
                    "format": "date-time",
                    "description": "Date when the prescription was issued (ISO8601 format)"
                ],
                "medications": [
                    "type": "array",
                    "items": [
                        "type": "object",
                        "properties": [
                            "id": [
                                "type": "string",
                                "format": "uuid",
                                "description": "Unique identifier for the medication"
                            ],
                            "name": [
                                "type": "string",
                                "description": "Name of the medication"
                            ],
                            "dosage": [
                                "anyOf": [
                                    ["type": "string"],
                                    ["type": "null"]
                                ],
                                "description": "Overall dosage information (e.g., '500mg', '2 tablets')"
                            ],
                            "instructions": [
                                "anyOf": [
                                    ["type": "string"],
                                    ["type": "null"]
                                ],
                                "description": "Special instructions for the medication"
                            ],
                            "duration": [
                                "type": "object",
                                "required": ["type"],
                                "oneOf": [
                                    [
                                        "properties": [
                                            "type": [
                                                "type": "string",
                                                "enum": ["days", "weeks", "months"]
                                            ],
                                            "value": [
                                                "type": "integer",
                                                "description": "Numeric value for duration"
                                            ]
                                        ],
                                        "required": ["type", "value"],
                                        "additionalProperties": false
                                    ],
                                    [
                                        "properties": [
                                            "type": [
                                                "type": "string",
                                                "const": "untilFollowUp"
                                            ],
                                            "date": [
                                                "type": "string",
                                                "format": "date-time",
                                                "description": "Follow-up date in ISO 8601 format"
                                            ]
                                        ],
                                        "required": ["type", "date"],
                                        "additionalProperties": false
                                    ],
                                    [
                                        "properties": [
                                            "type": [
                                                "type": "string",
                                                "enum": ["ongoing", "asNeeded"]
                                            ]
                                        ],
                                        "required": ["type"],
                                        "additionalProperties": false
                                    ]
                                ]
                            ],
                            "frequency": [
                                "type": "array",
                                "items": [
                                    "type": "object",
                                    "required": ["type"],
                                    "oneOf": [
                                        [
                                            "properties": [
                                                "type": [
                                                    "type": "string",
                                                    "const": "daily"
                                                ],
                                                "times": [
                                                    "type": "array",
                                                    "description": "Array of specific times for daily medication",
                                                    "items": [
                                                        "type": "object",
                                                        "required": ["hour", "minute"],
                                                        "additionalProperties": false,
                                                        "properties": [
                                                            "hour": [
                                                                "type": "integer",
                                                                "description": "Hour component (0-23)"
                                                            ],
                                                            "minute": [
                                                                "type": "integer",
                                                                "description": "Minute component (0-59)"
                                                            ],
                                                            "second": [
                                                                "type": "integer",
                                                                "description": "Second component (0-59)"
                                                            ]
                                                        ]
                                                    ]
                                                ]
                                            ],
                                            "required": ["type", "times"],
                                            "additionalProperties": false
                                        ],
                                        [
                                            "properties": [
                                                "type": [
                                                    "type": "string",
                                                    "const": "hourly"
                                                ],
                                                "interval": [
                                                    "type": "integer",
                                                    "description": "Hour interval for medication"
                                                ],
                                                "startTime": [
                                                    "type": "object",
                                                    "required": ["hour", "minute"],
                                                    "additionalProperties": false,
                                                    "description": "Starting time for hourly intervals",
                                                    "properties": [
                                                        "hour": [
                                                            "type": "integer",
                                                            "description": "Starting hour component (0-23)"
                                                        ],
                                                        "minute": [
                                                            "type": "integer",
                                                            "description": "Starting minute component (0-59)"
                                                        ],
                                                        "second": [
                                                            "type": "integer",
                                                            "description": "Starting second component (0-59)"
                                                        ]
                                                    ]
                                                ]
                                            ],
                                            "required": ["type", "interval"],
                                            "additionalProperties": false
                                        ],
                                        [
                                            "properties": [
                                                "type": [
                                                    "type": "string",
                                                    "enum": ["weekly", "biweekly"]
                                                ],
                                                "dayOfWeek": [
                                                    "type": "string",
                                                    "enum": ["monday", "tuesday", "wednesday", "thursday", "friday", "saturday", "sunday"],
                                                    "description": "Day of the week"
                                                ],
                                                "time": [
                                                    "type": "object",
                                                    "required": ["hour", "minute"],
                                                    "additionalProperties": false,
                                                    "description": "Specific time of day",
                                                    "properties": [
                                                        "hour": [
                                                            "type": "integer",
                                                            "description": "Hour component (0-23)"
                                                        ],
                                                        "minute": [
                                                            "type": "integer",
                                                            "description": "Minute component (0-59)"
                                                        ],
                                                        "second": [
                                                            "type": "integer",
                                                            "description": "Second component (0-59)"
                                                        ]
                                                    ]
                                                ]
                                            ],
                                            "required": ["type", "dayOfWeek", "time"],
                                            "additionalProperties": false
                                        ],
                                        [
                                            "properties": [
                                                "type": [
                                                    "type": "string",
                                                    "const": "monthly"
                                                ],
                                                "dayOfMonth": [
                                                    "type": "integer",
                                                    "description": "Day of the month (1-31)"
                                                ],
                                                "time": [
                                                    "type": "object",
                                                    "required": ["hour", "minute"],
                                                    "additionalProperties": false,
                                                    "description": "Specific time of day",
                                                    "properties": [
                                                        "hour": [
                                                            "type": "integer",
                                                            "description": "Hour component (0-23)"
                                                        ],
                                                        "minute": [
                                                            "type": "integer",
                                                            "description": "Minute component (0-59)"
                                                        ],
                                                        "second": [
                                                            "type": "integer",
                                                            "description": "Second component (0-59)"
                                                        ]
                                                    ]
                                                ]
                                            ],
                                            "required": ["type", "dayOfMonth", "time"],
                                            "additionalProperties": false
                                        ],
                                        [
                                            "properties": [
                                                "type": [
                                                    "type": "string",
                                                    "const": "mealBased"
                                                ],
                                                "mealTime": [
                                                    "type": "string",
                                                    "enum": ["breakfast", "lunch", "dinner", "bedtime"],
                                                    "description": "Meal reference point"
                                                ],
                                                "medicationTime": [
                                                    "type": "string",
                                                    "enum": ["before", "after"],
                                                    "description": "Timing relative to meal"
                                                ]
                                            ],
                                            "required": ["type", "mealTime"],
                                            "additionalProperties": false
                                        ]
                                    ]
                                ],
                                "description": "Medcation Frequency: Daily/Weekly/BiWeekly/Monthly can be at specific time, or Meal Based or other frequencies"
                            ]
                        ],
                        "required": ["id", "name", "duration"],
                        "additionalProperties": false
                    ]
                ],
                "doctorName": [
                    "anyOf": [
                        ["type": "string"],
                        ["type": "null"]
                    ],
                    "description": "Name of the prescribing doctor"
                ],
                "facilityName": [
                    "anyOf": [
                        ["type": "string"],
                        ["type": "null"]
                    ],
                    "description": "Name of the medical facility"
                ],
                "notes": [
                    "anyOf": [
                        ["type": "string"],
                        ["type": "null"]
                    ],
                    "description": "Additional notes or instructions"
                ],
                "followUpDate": [
                    "anyOf": [
                        [
                            "type": "string",
                            "format": "date-time"
                        ],
                        ["type": "null"]
                    ],
                    "description": "Date for follow-up appointment (ISO8601 format)"
                ],
                "followUpTests": [
                    "type": "array",
                    "items": [
                        "type": "string"
                    ],
                    "description": "List of follow-up tests recommended"
                ]
            ],
            required: ["dateIssued", "medications"],
            additionalProperties: false
        )
    }
    
    static var tool: AIKit.ClaudeTool {
        AIKit.ClaudeTool(
            name: "parse_prescription",
            description: "Parse a prescription document and extract structured medication data",
            inputSchema: ClaudeInputSchema(
                type: "object",
                properties: jsonSchema.properties,
                required: jsonSchema.required
            )
        )
    }
    
    static var toolChoice: AIKit.ToolChoice {
        AIKit.ToolChoice(
            type: "tool",
            name: "parse_prescription"
        )
    }
    
    
    
}
