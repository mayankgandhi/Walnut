//
//  ParsedBloodReport.swift
//  Walnut
//
//  Created by Mayank Gandhi on 28/07/25.
//  Copyright © 2025 m. All rights reserved.
//

import Foundation
import AIKit

struct ParsedBloodReport: ParseableModel, OpenAISchemaDefinable {
    
    let testName: String
    let labName: String
    let category: String
    let resultDate: Date
    let notes: String
    let testResults: [ParsedBloodTestResult]
    
    static var parseDefinition: String {
        """
        Swift blood report parsing model: ParsedBloodReport
        ParsedBloodReport: testName(String), labName(String), category(String), resultDate(Date:ISO8601-format), notes(String), testResults([ParsedBloodTestResult])
        ParsedBloodTestResult: testName(String), value(String), unit(String), referenceRange(String), isAbnormal(Bool)
        
        Please extract all blood test results from the lab report. The resultDate should be the date when the tests were performed or results were available.
        Strictly Follow this rule: Expected all date strings to be ISO8601-format.
        """
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
