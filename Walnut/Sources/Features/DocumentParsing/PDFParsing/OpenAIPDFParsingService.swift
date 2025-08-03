//
//  OpenAIPDFParsingService.swift
//  Walnut
//
//  Created by Mayank Gandhi on 03/08/25.
//  Copyright © 2025 m. All rights reserved.
//

import Foundation

/// Service for parsing PDF documents using OpenAI's file upload and structured parsing
final class OpenAIPDFParsingService: ObservableObject {
    
    // MARK: - Dependencies
    
    private let networkClient: OpenAINetworkClient
    
    // MARK: - Initialization
    
    init(apiKey: String) {
        self.networkClient = OpenAINetworkClient(apiKey: apiKey)
    }
    
    // MARK: - PDF Parsing
    
    /// Parse a PDF document by uploading it to OpenAI and using structured parsing
    func parsePDFDocument<T: Codable>(
        from url: URL,
        as type: T.Type
    ) async throws -> T {
        
        // Upload PDF file to OpenAI
        let fileId = try await uploadPDFFile(from: url)
        
        // Create a temporary vector store for this document
        let vectorStoreId = try await createVectorStore(name: "temp_pdf_\(UUID().uuidString)")
        
        // Add file to vector store
        try await addFileToVectorStore(fileId: fileId, vectorStoreId: vectorStoreId)
        
        // Wait for file processing to complete
        try await waitForFileProcessing(fileId: fileId, vectorStoreId: vectorStoreId)
        
        // Parse document using file search
        let result = try await parseDocumentWithFileSearch(vectorStoreId: vectorStoreId, as: type)
        
        // Cleanup resources
        await cleanupResources(fileId: fileId, vectorStoreId: vectorStoreId)
        
        return result
    }
    
    // MARK: - Private Methods
    
    private func uploadPDFFile(from url: URL) async throws -> String {
        let fileData = try Data(contentsOf: url)
        let fileName = url.lastPathComponent
        
        let boundary = "Boundary-\(UUID().uuidString)"
        var body = Data()
        
        // Add purpose field
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"purpose\"\r\n\r\n".data(using: .utf8)!)
        body.append("assistants\r\n".data(using: .utf8)!)
        
        // Add file field
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"\(fileName)\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: application/pdf\r\n\r\n".data(using: .utf8)!)
        body.append(fileData)
        body.append("\r\n".data(using: .utf8)!)
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        
        let request = try networkClient.createFileUploadRequest(
            endpoint: "files",
            body: body,
            contentType: "multipart/form-data; boundary=\(boundary)"
        )
        
        let (data, httpResponse) = try await networkClient.executeRequest(request)
        
        guard httpResponse.statusCode == 200 else {
            let errorMessage = String(data: data, encoding: .utf8) ?? "Upload failed"
            throw OpenAIServiceError.uploadFailed(errorMessage)
        }
        
        let uploadResponse = try JSONDecoder().decode(OpenAIFileUploadResponse.self, from: data)
        return uploadResponse.id
    }
    
    private func createVectorStore(name: String) async throws -> String {
        let createRequest = VectorStoreCreateRequest(name: name)
        let requestData = try JSONEncoder().encode(createRequest)
        
        let request = try networkClient.createChatRequest(endpoint: "vector_stores", body: requestData)
        let (data, httpResponse) = try await networkClient.executeRequest(request)
        
        guard httpResponse.statusCode == 200 else {
            let errorMessage = String(data: data, encoding: .utf8) ?? "Vector store creation failed"
            throw OpenAIServiceError.parseFailed(errorMessage)
        }
        
        let vectorStore = try JSONDecoder().decode(VectorStoreResponse.self, from: data)
        return vectorStore.id
    }
    
    private func addFileToVectorStore(fileId: String, vectorStoreId: String) async throws {
        let addFileRequest = VectorStoreFileRequest(fileId: fileId)
        let requestData = try JSONEncoder().encode(addFileRequest)
        
        let request = try networkClient.createChatRequest(endpoint: "vector_stores/\(vectorStoreId)/files", body: requestData)
        let (data, httpResponse) = try await networkClient.executeRequest(request)
        
        guard httpResponse.statusCode == 200 else {
            let errorMessage = String(data: data, encoding: .utf8) ?? "Failed to add file to vector store"
            throw OpenAIServiceError.parseFailed(errorMessage)
        }
    }
    
    private func waitForFileProcessing(fileId: String, vectorStoreId: String, maxAttempts: Int = 30) async throws {
        for _ in 0..<maxAttempts {
            let request = try networkClient.createGetRequest(endpoint: "vector_stores/\(vectorStoreId)/files/\(fileId)")
            let (data, httpResponse) = try await networkClient.executeRequest(request)
            
            guard httpResponse.statusCode == 200 else {
                throw OpenAIServiceError.parseFailed("Failed to check file status")
            }
            
            let fileStatus = try JSONDecoder().decode(VectorStoreFileStatus.self, from: data)
            
            switch fileStatus.status {
            case "completed":
                return
            case "failed":
                throw OpenAIServiceError.parseFailed("File processing failed: \(fileStatus.lastError?.message ?? "Unknown error")")
            case "in_progress":
                try await Task.sleep(nanoseconds: 2_000_000_000) // Wait 2 seconds
            default:
                try await Task.sleep(nanoseconds: 1_000_000_000) // Wait 1 second
            }
        }
        
        throw OpenAIServiceError.parseFailed("File processing timeout")
    }
    
    private func parseDocumentWithFileSearch<T: Codable>(vectorStoreId: String, as type: T.Type) async throws -> T {
        let prompt = generatePrompt(for: type)
        let jsonSchema = generateJSONSchema(for: type)
        
        let parseRequest = FileSearchParseRequest(
            model: "gpt-4o",
            input: prompt,
            tools: [
                FileSearchTool(
                    type: "file_search",
                    vectorStoreIds: [vectorStoreId]
                )
            ],
            responseFormat: OpenAIResponseFormat(
                type: "json_schema",
                jsonSchema: OpenAIJSONSchemaWrapper(
                    name: type == ParsedPrescription.self ? "ParsedPrescription" : "ParsedBloodReport",
                    strict: true,
                    schema: jsonSchema
                )
            )
        )
        
        let requestData = try JSONEncoder().encode(parseRequest)
        let request = try networkClient.createChatRequest(endpoint: "responses", body: requestData)
        let (data, httpResponse) = try await networkClient.executeRequest(request)
        
        guard httpResponse.statusCode == 200 else {
            let errorMessage = String(data: data, encoding: .utf8) ?? "Parsing failed"
            throw OpenAIServiceError.parseFailed(errorMessage)
        }
        
        let response = try JSONDecoder().decode(FileSearchResponse.self, from: data)
        
        // Extract the message content from the response
        guard let anyOutput = response.output.first(where: { $0.type == "message" }),
              let messageOutput = anyOutput.output as? MessageOutput,
              let content = messageOutput.content.first?.text else {
            throw OpenAIServiceError.parseFailed("No content in response")
        }
        
        // Parse the JSON content
        guard let jsonData = content.data(using: .utf8) else {
            throw OpenAIServiceError.parseFailed("Could not convert response to data")
        }
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode(type, from: jsonData)
    }
    
    private func cleanupResources(fileId: String, vectorStoreId: String) async {
        // Delete vector store (this also removes the file association)
        do {
            let request = try networkClient.createDeleteRequest(endpoint: "vector_stores/\(vectorStoreId)")
            _ = try await networkClient.executeRequest(request)
        } catch {
            print("Warning: Failed to cleanup vector store: \(error)")
        }
        
        // Delete uploaded file
        do {
            let request = try networkClient.createDeleteRequest(endpoint: "files/\(fileId)")
            _ = try await networkClient.executeRequest(request)
        } catch {
            print("Warning: Failed to cleanup uploaded file: \(error)")
        }
    }
    
    // MARK: - Helper Methods
    
    private func generatePrompt<T: Codable>(for type: T.Type) -> String {
        switch type {
        case is ParsedPrescription.Type:
            return """
            Please analyze the uploaded prescription document and extract all relevant information. Pay attention to:
            - Patient demographics and visit details
            - Doctor and facility information
            - Prescribed medications with dosages, frequencies, and instructions
            - Follow-up appointments or tests
            - Any additional notes
            
            Use the file search tool to find and analyze the content of the uploaded document.
            """
        case is ParsedBloodReport.Type:
            return """
            Please analyze the uploaded blood/lab report document and extract all test results. Pay attention to:
            - Lab name and test information
            - Test date and category
            - Individual test results with values, units, and reference ranges
            - Any abnormal values or flags
            - Additional notes or comments
            
            Use the file search tool to find and analyze the content of the uploaded document.
            """
        default:
            fatalError("Unsupported type \(String(describing: type))")
        }
    }
    
    private func generateJSONSchema<T: Codable>(for type: T.Type) -> OpenAIJSONSchema {
        // Reuse the same schema generation logic from OpenAIDocumentParser
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
            fatalError("Unsupported type \(String(describing: type))")
        }
    }
}

// MARK: - Supporting Types

struct VectorStoreCreateRequest: Codable {
    let name: String
}

struct VectorStoreResponse: Codable {
    let id: String
    let object: String
    let name: String
}

struct VectorStoreFileRequest: Codable {
    let fileId: String
    
    enum CodingKeys: String, CodingKey {
        case fileId = "file_id"
    }
}

struct VectorStoreFileStatus: Codable {
    let id: String
    let status: String
    let lastError: VectorStoreError?
    
    enum CodingKeys: String, CodingKey {
        case id, status
        case lastError = "last_error"
    }
}

struct VectorStoreError: Codable {
    let code: String
    let message: String
}

struct FileSearchParseRequest: Codable {
    let model: String
    let input: String
    let tools: [FileSearchTool]
    
    enum CodingKeys: String, CodingKey {
        case model, input, tools
    }
}

struct FileSearchTool: Codable {
    let type: String
    let vectorStoreIds: [String]
    let maxNumResults: Int?
    
    enum CodingKeys: String, CodingKey {
        case type
        case vectorStoreIds = "vector_store_ids"
        case maxNumResults = "max_num_results"
    }
}

struct FileSearchResponse: Codable {
    let output: [AnyResponseOutput]
}

protocol ResponseOutput: Codable {
    var type: String { get }
}

struct FileSearchCallOutput: ResponseOutput, Codable {
    let type: String
    let id: String
    let status: String
}

struct MessageOutput: ResponseOutput, Codable {
    let type: String
    let id: String
    let role: String
    let content: [MessageContent]
}

struct MessageContent: Codable {
    let type: String
    let text: String
}

struct AnyResponseOutput: ResponseOutput, Codable {
    let type: String
    private let _output: ResponseOutput
    
    var output: ResponseOutput {
        return _output
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(String.self, forKey: .type)
        self.type = type
        
        switch type {
        case "file_search_call":
            self._output = try FileSearchCallOutput(from: decoder)
        case "message":
            self._output = try MessageOutput(from: decoder)
        default:
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Unknown response output type: \(type)"))
        }
    }
    
    func encode(to encoder: Encoder) throws {
        try _output.encode(to: encoder)
    }
    
    private enum CodingKeys: String, CodingKey {
        case type
    }
}
