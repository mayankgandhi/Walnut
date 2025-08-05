//
//  OpenAIDocumentParser.swift
//  AIKit
//
//  Created by Mayank Gandhi on 05/08/25.
//  Copyright © 2025 m. All rights reserved.
//

import Foundation

/// Handles document parsing and AI communication with OpenAI API
public final class OpenAIDocumentParser: DocumentParserProtocol {
    
    // MARK: - Dependencies
    
    private let networkClient: OpenAINetworkClient
    
    // MARK: - Initialization
    
    public init(networkClient: OpenAINetworkClient) {
        self.networkClient = networkClient
    }
    
    // MARK: - DocumentParserProtocol
    
    public func parseDocument<T: Codable>(data: Data, fileName: String, as type: T.Type) async throws -> T {
        // Check if the file is a supported image type for OpenAI vision
        guard isImageFile(fileName: fileName) else {
            throw OpenAIServiceError.unsupportedFileType("OpenAI vision only supports image files (JPEG, PNG, GIF, WebP). PDF files require a different parsing approach.")
        }
        
        // For OpenAI, we need to encode the document as base64 for vision models
        let base64Data = data.base64EncodedString()
        let mimeType = MimeTypeResolver.mimeType(for: fileName)
        
        // Create parsing prompt
        let prompt = generatePrompt(for: type)
        let jsonSchema = generateJSONSchema(for: type)
        
        let chatRequest = OpenAIChatRequest(
            model: "gpt-4o",
            messages: [
                OpenAIMessage(
                    role: "user",
                    content: [
                        .text(OpenAITextContent(text: prompt)),
                        .imageUrl(OpenAIImageContent(
                            imageUrl: OpenAIImageUrl(url: "data:\(mimeType);base64,\(base64Data)")
                        ))
                    ]
                )
            ],
            maxTokens: 4096,
            temperature: 0.1,
            responseFormat: OpenAIResponseFormat(
                type: "json_schema",
                jsonSchema: OpenAIJSONSchemaWrapper(
                    name: type == ParsedPrescription.self ? "ParsedPrescription" : "ParsedBloodReport",
                    strict: true,
                    schema: jsonSchema
                )
            )
        )
        
        do {
            let requestData = try JSONEncoder().encode(chatRequest)
            let request = try networkClient.createChatRequest(endpoint: "chat/completions", body: requestData)
            let (data, httpResponse) = try await networkClient.executeRequest(request)
            
            guard httpResponse.statusCode == 200 else {
                let errorMessage = String(data: data, encoding: .utf8) ?? "Unknown error"
                throw OpenAIServiceError.parseFailed(errorMessage)
            }
            
            let chatResponse = try JSONDecoder().decode(OpenAIChatResponse.self, from: data)
            
            guard let content = chatResponse.choices.first?.message.content else {
                throw OpenAIServiceError.parseFailed("No content in response")
            }
            
            // With structured outputs, the response should be valid JSON
            guard let jsonData = content.data(using: .utf8) else {
                throw OpenAIServiceError.parseFailed("Could not convert response to data")
            }
            
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let parsedObject = try decoder.decode(type, from: jsonData)
            return parsedObject
            
        } catch let error as DecodingError {
            throw OpenAIServiceError.decodingError(error)
        } catch let error as OpenAIServiceError {
            throw error
        } catch {
            throw OpenAIServiceError.networkError(error)
        }
    }
    
    // MARK: - Private Helpers
    
    private func isImageFile(fileName: String) -> Bool {
        let pathExtension = (fileName as NSString).pathExtension.lowercased()
        let supportedImageTypes = ["jpg", "jpeg", "png", "gif", "webp", "heic", "heif"]
        return supportedImageTypes.contains(pathExtension)
    }
    
    private func generatePrompt<T: Codable>(for type: T.Type) -> String {
        switch type {
        case is ParsedPrescription.Type:
            return """
            Please analyze this prescription document and extract all relevant information. Pay attention to:
            - Patient demographics and visit details
            - Doctor and facility information
            - Prescribed medications with dosages, frequencies, and instructions
            - Follow-up appointments or tests
            - Any additional notes
            """
        case is ParsedBloodReport.Type:
            return """
            Please analyze this blood/lab report document and extract all test results. Pay attention to:
            - Lab name and test information
            - Test date and category
            - Individual test results with values, units, and reference ranges
            - Any abnormal values or flags
            - Additional notes or comments
            """
        default:
            return "Please analyze this document and extract the relevant information according to the provided schema."
        }
    }
    
    private func generateJSONSchema<T: Codable>(for type: T.Type) -> OpenAIJSONSchema {
        switch type {
        case is ParsedPrescription.Type:
            return OpenAIJSONSchema(
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
        case is ParsedBloodReport.Type:
            return OpenAIJSONSchema(
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
        default:
            return OpenAIJSONSchema(
                properties: [:],
                required: [],
                additionalProperties: true
            )
        }
    }
}