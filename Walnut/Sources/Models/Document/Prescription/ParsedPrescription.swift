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
        var frequency: [MedicationFrequencyData]
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
            "doctorName": [
                "type": ["string", "null"],
                "description": "Name of the prescribing doctor"
            ],
            "facilityName": [
                "type": ["string", "null"],
                "description": "Name of the medical facility"
            ],
            "followUpDate": [
                "type": ["string", "null"],
                "format": "date-time",
                "description": "Date for follow-up appointment (ISO8601 format)"
            ],
            "followUpTests": [
                "type": "array",
                "items": ["type": "string"],
                "description": "List of follow-up tests recommended"
            ],
            "notes": [
                "type": ["string", "null"],
                "description": "Additional notes or instructions"
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
                        "frequency": [
                            "type": "array",
                            "items": [
                                "type": "object",
                                "oneOf": MedicationFrequency.jsonSchema.properties["oneOf"] ?? []
                            ],
                            "description": "Array of frequency specifications for the medication"
                        ],
                        "duration": [
                            "type": "object",
                            "description": "Duration of the medication treatment",
                            "oneOf": MedicationDuration.openaiJSONSchema.properties["oneOf"] ?? []
                        ],
                        "dosage": [
                            "type": ["string", "null"],
                            "description": "Overall dosage information (e.g., '500mg', '2 tablets')"
                        ],
                        "instructions": [
                            "type": ["string", "null"],
                            "description": "Special instructions for the medication"
                        ]
                    ],
                    "required": ["id", "name"],
                    "additionalProperties": false
                ]
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
