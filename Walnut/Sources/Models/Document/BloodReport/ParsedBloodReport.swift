//
//  ParsedBloodReport.swift
//  Walnut
//
//  Created by Mayank Gandhi on 28/07/25.
//  Copyright © 2025 m. All rights reserved.
//

import Foundation
import AIKit

struct ParsedBloodReport: ParseableModel {
  
    let testName: String
    let labName: String
    let category: String
    let resultDate: Date
    let notes: String
    let testResults: [ParsedBloodTestResult]
    
    static var tool: AIKit.ClaudeTool {
        AIKit.ClaudeTool(
            name: "parse_blood_report",
            description: "Parse a Blood Report document and extract structured Test Result data",
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
            name: "parse_blood_report"
        )
    }
    
    static var jsonSchema: OpenAIJSONSchema  = {
        OpenAIJSONSchema(
            properties: [
                "testName": [
                    "type": "string",
                    "description": "Name of the blood test or panel"
                ],
                "labName": [
                    "type": "string",
                    "description": "Name of the laboratory"
                ],
                "category": [
                    "type": "string",
                    "description": "Category or type of blood test"
                ],
                "resultDate": [
                    "type": "string",
                    "format": "date-time",
                    "description": "Date when the test results were obtained"
                ],
                "notes": [
                    "type": "string",
                    "description": "Additional notes or comments"
                ],
                "testResults": [
                    "type": "array",
                    "items": [
                        "type": "object",
                        "properties": [
                            "testName": [
                                "type": "string",
                                "description": "Name of the individual test"
                            ],
                            "value": [
                                "type": "string",
                                "description": "Test result value"
                            ],
                            "unit": [
                                "type": "string",
                                "description": "Unit of measurement"
                            ],
                            "referenceRange": [
                                "type": "string",
                                "description": "Normal reference range"
                            ],
                            "isAbnormal": [
                                "type": "boolean",
                                "description": "Whether the result is abnormal"
                            ]
                        ],
                        "required": ["testName", "value", "unit", "referenceRange", "isAbnormal"],
                        "additionalProperties": false
                    ]
                ]
            ],
            required: ["testName", "labName", "category", "resultDate", "notes", "testResults"],
            additionalProperties: false
        )
    }()

}

struct ParsedBloodTestResult: Codable {
    let testName: String
    let value: String
    let unit: String
    let referenceRange: String
    let isAbnormal: Bool
}
