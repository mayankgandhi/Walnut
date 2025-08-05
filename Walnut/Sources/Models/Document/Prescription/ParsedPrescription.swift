//
//  ParsedPrescription.swift
//  Walnut
//
//  Created by Mayank Gandhi on 11/07/25.
//  Copyright © 2025 m. All rights reserved.
//

import Foundation
import AIKit

struct ParsedPrescription: ParseableModel, OpenAISchemaDefinable {
    
    struct Medication: Codable {
        var id: UUID
        var name: String
        var frequency: [MedicationSchedule]
        var numberOfDays: Int
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
        Swift prescription parsing model: ParsedPrescription
        ParsedPrescription: dateIssued(Date), doctorName(String?), facilityName(String?), followUpDate(Date?), followUpTests([String]), notes(String?), medications([Medication])
        Medication: id(UUID), name(String), frequency([MedicationSchedule]), numberOfDays(Int), dosage(String?), instructions(String?)
        MedicationSchedule: mealTime(MealTime), timing(MedicationTime?), dosage(String?)
        Enums: MealTime(.breakfast/.lunch/.dinner/.bedtime), MedicationTime(.before/.after)
        """
    }
    
    static var jsonSchema: OpenAIJSONSchema {
        OpenAIJSONSchema(
            properties: [
                "dateIssued": [
                    "type": "string",
                    "format": "date-time",
                    "description": "Date when the prescription was issued"
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
                    "description": "Date for follow-up appointment"
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
                                    "properties": [
                                        "mealTime": [
                                            "type": "string",
                                            "enum": ["breakfast", "lunch", "dinner", "bedtime"],
                                            "description": "Meal time for medication"
                                        ],
                                        "timing": [
                                            "type": ["string", "null"],
                                            "enum": ["before", "after", NSNull()],
                                            "description": "Before or after meal timing"
                                        ],
                                        "dosage": [
                                            "type": ["string", "null"],
                                            "description": "Dosage for this schedule"
                                        ]
                                    ],
                                    "required": ["mealTime", "timing", "dosage"],
                                    "additionalProperties": false
                                ]
                            ],
                            "numberOfDays": [
                                "type": "integer",
                                "description": "Number of days to take the medication"
                            ],
                            "dosage": [
                                "type": ["string", "null"],
                                "description": "Overall dosage information"
                            ],
                            "instructions": [
                                "type": ["string", "null"],
                                "description": "Special instructions for the medication"
                            ]
                        ],
                        "required": ["id", "name", "frequency", "numberOfDays", "dosage", "instructions"],
                        "additionalProperties": false
                    ]
                ]
            ],
            required: ["dateIssued", "doctorName", "facilityName", "followUpDate", "followUpTests", "notes", "medications"],
            additionalProperties: false
        )
    }

    
}
