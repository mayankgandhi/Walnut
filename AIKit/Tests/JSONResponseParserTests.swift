//
//  JSONResponseParserTests.swift
//  AIKitTests
//
//  Created by Mayank Gandhi on 11/08/25.
//  Copyright © 2025 m. All rights reserved.
//

import XCTest
@testable import AIKit

final class JSONResponseParserTests: XCTestCase {
    
    // MARK: - Test Models
    
    private struct TestModel: Codable, Equatable {
        let id: String
        let name: String
        let count: Int
        let isActive: Bool
        let tags: [String]?
        
        init(id: String = "test-123", name: String = "Test Item", count: Int = 42, isActive: Bool = true, tags: [String]? = ["tag1", "tag2"]) {
            self.id = id
            self.name = name
            self.count = count
            self.isActive = isActive
            self.tags = tags
        }
    }
    
    private struct ComplexTestModel: Codable, Equatable {
        let patient: PatientInfo
        let medications: [MedicationInfo]
        let lastUpdated: Date
        
        struct PatientInfo: Codable, Equatable {
            let id: String
            let name: String
            let age: Int
        }
        
        struct MedicationInfo: Codable, Equatable {
            let name: String
            let dosage: String
            let frequency: String
        }
    }
    
    // MARK: - Mock Data
    
    private func createMockOpenAIResponse(withContent content: String) -> OpenAIChatResponse {
        return OpenAIChatResponse(
            id: "chatcmpl-test123",
            object: "chat.completion",
            created: 1234567890,
            model: "gpt-4o",
            choices: [
                OpenAIChoice(
                    index: 0,
                    message: OpenAIResponseMessage(
                        role: "assistant",
                        content: content,
                        refusal: nil
                    ),
                    logprobs: nil,
                    finishReason: "stop"
                )
            ],
            usage: OpenAIUsage(
                promptTokens: 100,
                completionTokens: 50,
                totalTokens: 150
            ),
            systemFingerprint: "fp_test"
        )
    }
    
    private func createMockClaudeResponse(withContent content: String) -> ClaudeMessageResponse {
        return ClaudeMessageResponse(
            id: "msg_test123",
            type: "message",
            role: "assistant",
            model: "claude-sonnet-4-20250514",
            content: [
                ClaudeResponseContent(type: "text", text: content)
            ]
        )
    }
    
    // MARK: - OpenAI Response Parsing Tests
    
    func testParseOpenAIResponse_ValidJSON_Success() throws {
        let testModel = TestModel()
        let jsonString = try encodeToJSONString(testModel)
        let mockResponse = createMockOpenAIResponse(withContent: jsonString)
        
        let result = try JSONResponseParser.parseOpenAIResponse(mockResponse, as: TestModel.self)
        
        XCTAssertEqual(result, testModel)
    }
    
    func testParseOpenAIResponse_EmptyContent_ThrowsError() {
        let mockResponse = createMockOpenAIResponse(withContent: "")
        
        XCTAssertThrowsError(try JSONResponseParser.parseOpenAIResponse(mockResponse, as: TestModel.self)) { error in
            if case let AIKitError.parsingError(message) = error {
                XCTAssertTrue(message.contains("No content in OpenAI response"))
            } else {
                XCTFail("Expected AIKitError.parsingError, got \(error)")
            }
        }
    }
    
    func testParseOpenAIResponse_InvalidJSON_ThrowsError() {
        let mockResponse = createMockOpenAIResponse(withContent: "invalid json content")
        
        XCTAssertThrowsError(try JSONResponseParser.parseOpenAIResponse(mockResponse, as: TestModel.self)) { error in
            if case let AIKitError.parsingError(message) = error {
                XCTAssertTrue(message.contains("Failed to decode JSON"))
            } else {
                XCTFail("Expected AIKitError.parsingError, got \(error)")
            }
        }
    }
    
    // MARK: - Claude Response Parsing Tests
    
    func testParseClaudeResponse_ValidJSON_Success() throws {
        let testModel = TestModel()
        let jsonString = try encodeToJSONString(testModel)
        let mockResponse = createMockClaudeResponse(withContent: jsonString)
        
        let result = try JSONResponseParser.parseClaudeResponse(mockResponse, as: TestModel.self)
        
        XCTAssertEqual(result, testModel)
    }
    
    func testParseClaudeResponse_JSONWithMarkdownBlocks_Success() throws {
        let testModel = TestModel()
        let jsonString = try encodeToJSONString(testModel)
        let contentWithMarkdown = "```json\n\(jsonString)\n```"
        let mockResponse = createMockClaudeResponse(withContent: contentWithMarkdown)
        
        let result = try JSONResponseParser.parseClaudeResponse(mockResponse, as: TestModel.self)
        
        XCTAssertEqual(result, testModel)
    }
    
    func testParseClaudeResponse_JSONWithMixedContent_Success() throws {
        let testModel = TestModel()
        let jsonString = try encodeToJSONString(testModel)
        let contentWithText = "Here's the extracted information:\n\n\(jsonString)\n\nThat's all I found."
        let mockResponse = createMockClaudeResponse(withContent: contentWithText)
        
        let result = try JSONResponseParser.parseClaudeResponse(mockResponse, as: TestModel.self)
        
        XCTAssertEqual(result, testModel)
    }
    
    func testParseClaudeResponse_EmptyContent_ThrowsError() {
        let mockResponse = ClaudeMessageResponse(
            id: "msg_test123",
            type: "message",
            role: "assistant",
            model: "claude-sonnet-4-20250514",
            content: []
        )
        
        XCTAssertThrowsError(try JSONResponseParser.parseClaudeResponse(mockResponse, as: TestModel.self)) { error in
            if case let AIKitError.parsingError(message) = error {
                XCTAssertTrue(message.contains("No content in Claude response"))
            } else {
                XCTFail("Expected AIKitError.parsingError, got \(error)")
            }
        }
    }
    
    // MARK: - JSON String Parsing Tests
    
    func testParseJSONString_ValidJSON_Success() throws {
        let testModel = TestModel()
        let jsonString = try encodeToJSONString(testModel)
        
        let result = try JSONResponseParser.parseJSONString(jsonString, as: TestModel.self)
        
        XCTAssertEqual(result, testModel)
    }
    
    func testParseJSONString_ComplexModel_Success() throws {
        let complexModel = ComplexTestModel(
            patient: ComplexTestModel.PatientInfo(id: "p123", name: "John Doe", age: 45),
            medications: [
                ComplexTestModel.MedicationInfo(name: "Aspirin", dosage: "81mg", frequency: "Daily"),
                ComplexTestModel.MedicationInfo(name: "Lisinopril", dosage: "10mg", frequency: "Once daily")
            ],
            lastUpdated: Date(timeIntervalSince1970: 1640995200) // 2022-01-01 00:00:00 UTC
        )
        let jsonString = try encodeToJSONString(complexModel)
        
        let result = try JSONResponseParser.parseJSONString(jsonString, as: ComplexTestModel.self)
        
        XCTAssertEqual(result, complexModel)
    }
    
    func testParseJSONString_InvalidJSON_ThrowsError() {
        let invalidJSON = "{invalid json structure"
        
        XCTAssertThrowsError(try JSONResponseParser.parseJSONString(invalidJSON, as: TestModel.self)) { error in
            if case let AIKitError.parsingError(message) = error {
                XCTAssertTrue(message.contains("Failed to decode JSON"))
            } else {
                XCTFail("Expected AIKitError.parsingError, got \(error)")
            }
        }
    }
    
    // MARK: - Claude Response Cleaning Tests
    
    func testCleanClaudeJSONResponse_BasicJSON_NoChange() {
        let jsonString = "{\"id\":\"test\",\"name\":\"Test Item\"}"
        let result = JSONResponseParser.cleanClaudeJSONResponse(jsonString)
        XCTAssertEqual(result, jsonString)
    }
    
    func testCleanClaudeJSONResponse_WithMarkdownBlocks_Cleaned() {
        let jsonString = "{\"id\":\"test\",\"name\":\"Test Item\"}"
        let contentWithMarkdown = "```json\n\(jsonString)\n```"
        
        let result = JSONResponseParser.cleanClaudeJSONResponse(contentWithMarkdown)
        
        XCTAssertEqual(result, jsonString)
    }
    
    func testCleanClaudeJSONResponse_WithSurroundingText_ExtractsJSON() {
        let jsonString = "{\"id\":\"test\",\"name\":\"Test Item\"}"
        let contentWithText = "Here is the analysis:\\n\\n\(jsonString)\\n\\nEnd of analysis."
        
        let result = JSONResponseParser.cleanClaudeJSONResponse(contentWithText)
        
        XCTAssertEqual(result, jsonString)
    }
    
    func testCleanClaudeJSONResponse_WithWhitespace_Trimmed() {
        let jsonString = "{\"id\":\"test\",\"name\":\"Test Item\"}"
        let contentWithWhitespace = "   \\n\\n\(jsonString)\\n\\n   "
        
        let result = JSONResponseParser.cleanClaudeJSONResponse(contentWithWhitespace)
        
        XCTAssertEqual(result, jsonString)
    }
    
    func testCleanClaudeJSONResponse_ArrayJSON_Cleaned() {
        let jsonString = "[{\"name\":\"Item1\"},{\"name\":\"Item2\"}]"
        let contentWithMarkdown = "```json\n\(jsonString)\n```"
        
        let result = JSONResponseParser.cleanClaudeJSONResponse(contentWithMarkdown)
        
        XCTAssertEqual(result, jsonString)
    }
    
    // MARK: - JSON Structure Validation Tests
    
    func testIsValidJSONStructure_ValidObject_ReturnsTrue() {
        let validJSON = "{\"key\":\"value\"}"
        XCTAssertTrue(JSONResponseParser.isValidJSONStructure(validJSON))
    }
    
    func testIsValidJSONStructure_ValidArray_ReturnsTrue() {
        let validJSON = "[{\"key\":\"value\"},{\"key2\":\"value2\"}]"
        XCTAssertTrue(JSONResponseParser.isValidJSONStructure(validJSON))
    }
    
    func testIsValidJSONStructure_InvalidStructure_ReturnsFalse() {
        let invalidJSON = "not json at all"
        XCTAssertFalse(JSONResponseParser.isValidJSONStructure(invalidJSON))
    }
    
    func testIsValidJSONStructure_IncompleteObject_ReturnsFalse() {
        let incompleteJSON = "{\"key\":\"value\""
        XCTAssertFalse(JSONResponseParser.isValidJSONStructure(incompleteJSON))
    }
    
    func testIsValidJSONStructure_WithWhitespace_ReturnsTrue() {
        let validJSON = "  \\n{\\n  \"key\": \"value\"\\n}\\n  "
        XCTAssertTrue(JSONResponseParser.isValidJSONStructure(validJSON))
    }
    
    // MARK: - Mixed Content Extraction Tests
    
    func testExtractJSONFromMixedContent_ValidJSON_ExtractsJSON() {
        let jsonString = "{\"id\":\"test\",\"name\":\"Test Item\"}"
        let mixedContent = "Here's your data: \(jsonString) - that's all!"
        
        let result = JSONResponseParser.extractJSONFromMixedContent(mixedContent)
        
        XCTAssertNotNil(result)
        XCTAssertEqual(result, jsonString)
    }
    
    func testExtractJSONFromMixedContent_NoValidJSON_ReturnsNil() {
        let mixedContent = "This is just text with no JSON structure"
        
        let result = JSONResponseParser.extractJSONFromMixedContent(mixedContent)
        
        XCTAssertNil(result)
    }
    
    func testExtractJSONFromMixedContent_WithMarkdown_ExtractsJSON() {
        let jsonString = "{\"id\":\"test\",\"name\":\"Test Item\"}"
        let mixedContent = "```json\\n\(jsonString)\\n```"
        
        let result = JSONResponseParser.extractJSONFromMixedContent(mixedContent)
        
        XCTAssertNotNil(result)
        XCTAssertEqual(result, jsonString)
    }
    
    // MARK: - Edge Cases and Error Handling
    
    func testParseJSON_EmptyData_ThrowsError() {
        let emptyData = Data()
        
        XCTAssertThrowsError(try JSONResponseParser.parseJSON(emptyData, as: TestModel.self)) { error in
            if case let AIKitError.parsingError(message) = error {
                XCTAssertTrue(message.contains("Failed to decode JSON"))
            } else {
                XCTFail("Expected AIKitError.parsingError, got \(error)")
            }
        }
    }
    
    func testParseJSON_MalformedJSON_IncludesJSONInError() {
        let malformedJSON = "{\"key\": invalid_value}"
        let jsonData = malformedJSON.data(using: .utf8)!
        
        XCTAssertThrowsError(try JSONResponseParser.parseJSON(jsonData, as: TestModel.self)) { error in
            if case let AIKitError.parsingError(message) = error {
                XCTAssertTrue(message.contains("Failed to decode JSON"))
                XCTAssertTrue(message.contains(malformedJSON))
            } else {
                XCTFail("Expected AIKitError.parsingError, got \(error)")
            }
        }
    }
    
    func testParseJSON_NonUTF8Data_ThrowsError() {
        let invalidUTF8Data = Data([0xFF, 0xFE, 0xFD])
        
        XCTAssertThrowsError(try JSONResponseParser.parseJSON(invalidUTF8Data, as: TestModel.self)) { error in
            if case let AIKitError.parsingError(message) = error {
                XCTAssertTrue(message.contains("Failed to decode JSON"))
                XCTAssertTrue(message.contains("Invalid UTF-8 data"))
            } else {
                XCTFail("Expected AIKitError.parsingError, got \(error)")
            }
        }
    }
    
    // MARK: - Custom Test Cases for Manual Testing
    
    /// Use this test method to manually test any custom model and response string
    /// Replace the model and responseString with your own values
    func testCustomModelAndResponse() throws {
        // MARK: - CUSTOMIZE THIS SECTION
       
        // You can also test with Claude-style responses with markdown
        let claudeStyleResponse = """
        ```json\n{\n  \"testName\": \"Comprehensive Health Panel\",\n  \"labName\": \"VIJAYA DIAGNOSTIC CENTRE\",\n  \"category\": \"Comprehensive\",\n  \"resultDate\": \"2025-08-05T00:00:00Z\",\n  \"notes\": \"Multiple tests performed including kidney function, diabetes screening, thyroid function, blood count, coagulation studies, and infectious disease screening\",\n  \"testResults\": [\n    {\n      \"testName\": \"Creatinine\",\n      \"value\": \"0.6\",\n      \"unit\": \"mg/dL\",\n      \"referenceRange\": \"0.5 - 1.0\",\n      \"isAbnormal\": false\n    },\n    {\n      \"testName\": \"e-GFR (Glomerular Filtration Rate)\",\n      \"value\": \"111.3\",\n      \"unit\": \"ml/min/1.73 m²\",\n      \"referenceRange\": \">/= 90\",\n      \"isAbnormal\": false\n    },\n    {\n      \"testName\": \"Glycated Haemoglobin (HbA1C)\",\n      \"value\": \"6.0\",\n      \"unit\": \"%\",\n      \"referenceRange\": \"Non Diabetic: < 5.7, Pre-Diabetic: 5.7 - 6.4, Diabetic: >/= 6.5\",\n      \"isAbnormal\": true\n    },\n    {\n      \"testName\": \"Post Lunch Glucose\",\n      \"value\": \"156\",\n      \"unit\": \"mg/dL\",\n      \"referenceRange\": \"Normal: <140, Impaired: 140-199, Diabetes: >/= 200\",\n      \"isAbnormal\": true\n    },\n    {\n      \"testName\": \"Fasting Plasma Glucose\",\n      \"value\": \"102\",\n      \"unit\": \"mg/dL\",\n      \"referenceRange\": \"Normal: 70-99, Impaired: 100-125, Diabetes: >/=126\",\n      \"isAbnormal\": true\n    },\n    {\n      \"testName\": \"Bleeding Time\",\n      \"value\": \"01:30\",\n      \"unit\": \"min-sec\",\n      \"referenceRange\": \"1 - 5\",\n      \"isAbnormal\": false\n    },\n    {\n      \"testName\": \"Clotting Time\",\n      \"value\": \"06:00\",\n      \"unit\": \"min-sec\",\n      \"referenceRange\": \"4 - 9\",\n      \"isAbnormal\": false\n    },\n    {\n      \"testName\": \"T3 Total\",\n      \"value\": \"0.89\",\n      \"unit\": \"ng/mL\",\n      \"referenceRange\": \"Non pregnant: 0.60 - 1.81\",\n      \"isAbnormal\": false\n    },\n    {\n      \"testName\": \"T4 Total\",\n      \"value\": \"11.90\",\n      \"unit\": \"µg/dL\",\n      \"referenceRange\": \"Adult: 3.2 - 12.6\",\n      \"isAbnormal\": false\n    },\n    {\n      \"testName\": \"TSH - Ultrasensitive\",\n      \"value\": \"1.143\",\n      \"unit\": \"µIU/mL\",\n      \"referenceRange\": \"Non pregnant: 0.55 - 4.78\",\n      \"isAbnormal\": false\n    },\n    {\n      \"testName\": \"Haemoglobin\",\n      \"value\": \"11.6\",\n      \"unit\": \"gm/dL\",\n      \"referenceRange\": \"12.0 - 15.0\",\n      \"isAbnormal\": true\n    },\n    {\n      \"testName\": \"Total RBC Count\",\n      \"value\": \"3.8\",\n      \"unit\": \"Cells/cumm\",\n      \"referenceRange\": \"3.8 - 4.8\",\n      \"isAbnormal\": false\n    },\n    {\n      \"testName\": \"Packed Cell Volume / Hematocrit\",\n      \"value\": \"34.2\",\n      \"unit\": \"%\",\n      \"referenceRange\": \"36.0 - 46.0\",\n      \"isAbnormal\": true\n    },\n    {\n      \"testName\": \"MCV\",\n      \"value\": \"89.6\",\n      \"unit\": \"fL\",\n      \"referenceRange\": \"83.0 - 101.0\",\n      \"isAbnormal\": false\n    },\n    {\n      \"testName\": \"MCH\",\n      \"value\": \"30.4\",\n      \"unit\": \"pg\",\n      \"referenceRange\": \"27.0 - 32.0\",\n      \"isAbnormal\": false\n    },\n    {\n      \"testName\": \"MCHC\",\n      \"value\": \"33.9\",\n      \"unit\": \"gm/dL\",\n      \"referenceRange\": \"31.5 - 34.5\",\n      \"isAbnormal\": false\n    },\n    {\n      \"testName\": \"RDW\",\n      \"value\": \"16.1\",\n      \"unit\": \"%\",\n      \"referenceRange\": \"11.6 - 14.0\",\n      \"isAbnormal\": true\n    },\n    {\n      \"testName\": \"Total Leucocytes (WBC) Count\",\n      \"value\": \"6000\",\n      \"unit\": \"Cells/cumm\",\n      \"referenceRange\": \"4000 - 10000\",\n      \"isAbnormal\": false\n    },\n    {\n      \"testName\": \"Neutrophils\",\n      \"value\": \"47\",\n      \"unit\": \"%\",\n      \"referenceRange\": \"40 - 80\",\n      \"isAbnormal\": false\n    },\n    {\n      \"testName\": \"Lymphocytes\",\n      \"value\": \"45\",\n      \"unit\": \"%\",\n      \"referenceRange\": \"20 - 40\",\n      \"isAbnormal\": true\n    },\n    {\n      \"testName\": \"Eosinophils\",\n      \"value\": \"3\",\n      \"unit\": \"%\",\n      \"referenceRange\": \"1 - 6\",\n      \"isAbnormal\": false\n    },\n    {\n      \"testName\": \"Monocytes\",\n      \"value\": \"5\",\n      \"unit\": \"%\",\n      \"referenceRange\": \"2 - 10\",\n      \"isAbnormal\": false\n    },\n    {\n      \"testName\": \"Basophils\",\n      \"value\": \"0\",\n      \"unit\": \"%\",\n      \"referenceRange\": \"0-2\",\n      \"isAbnormal\": false\n    },\n    {\n      \"testName\": \"Absolute Neutrophil Count\",\n      \"value\": \"2820\",\n      \"unit\": \"Cells/cumm\",\n      \"referenceRange\": \"2000 - 7000\",\n      \"isAbnormal\": false\n    },\n    {\n      \"testName\": \"Absolute Lymphocyte Count\",\n      \"value\": \"2700\",\n      \"unit\": \"Cells/cumm\",\n      \"referenceRange\": \"1000 - 3000\",\n      \"isAbnormal\": false\n    },\n    {\n      \"testName\": \"Absolute Eosinophil Count\",\n      \"value\": \"180\",\n      \"unit\": \"Cells/cumm\",\n      \"referenceRange\": \"20 - 500\",\n      \"isAbnormal\": false\n    },\n    {\n      \"testName\": \"Absolute Monocyte Count\",\n      \"value\": \"300\",\n      \"unit\": \"Cells/cumm\",\n      \"referenceRange\": \"200 - 1000\",\n      \"isAbnormal\": false\n    },\n    {\n      \"testName\": \"Platelet Count\",\n      \"value\": \"280000\",\n      \"unit\": \"Cells/cumm\",\n      \"referenceRange\": \"150000 - 410000\",\n      \"isAbnormal\": false\n    },\n    {\n      \"testName\": \"Hepatitis B Surface Antigen\",\n      \"value\": \"Non Reactive [<0.030]\",\n      \"unit\": \"IU/mL\",\n      \"referenceRange\": \"Nonreactive: < 0.05 IU/mL\",\n      \"isAbnormal\": false\n    },\n    {\n      \"testName\": \"HIV 1 & 2 Antibodies/Antigen\",\n      \"value\": \"Non Reactive [0.788]\",\n      \"unit\": \"S/CO\",\n      \"referenceRange\": \"Nonreactive: <1.0\",\n      \"isAbnormal\": false\n    },\n    {\n      \"testName\": \"Hepatitis C Antibody\",\n      \"value\": \"Non Reactive [0.017]\",\n      \"unit\": \"S/CO\",\n      \"referenceRange\": \"Non Reactive: <1.0 S/CO\",\n      \"isAbnormal\": false\n    }\n  ]\n}\n```
        """
        
        // MARK: - TEST EXECUTION (Don't modify this part)
    
        
        do {
            let cleanedResponse = createMockClaudeResponse(withContent: claudeStyleResponse)
            let result2 = try JSONResponseParser.parseClaudeResponse(
                cleanedResponse,
                as: ParsedBloodReport.self
            )
            print("\\n✅ Claude-style response parsing successful:")
            print("   Patient: \\(result2.patientName), Age: \\(result2.age)")
            print("   Medications: \\(result2.medications.joined(separator: ", "))")
            print("   Active: \\(result2.isActive), Last Visit: \\(result2.lastVisit ?? \"N/A\")")
        } catch {
            print("\\n❌ Claude-style response parsing failed: \\(error)")
            XCTFail("Claude-style response parsing should succeed")
        }
                
//        let mockClaudeResponse = createMockClaudeResponse(withContent: claudeStyleResponse)
//        do {
//            let result4 = try JSONResponseParser.parseClaudeResponse(mockClaudeResponse, as: ParsedBloodReport.self)
//            print("\\n✅ Mock Claude response parsing successful:")
//            print("   Patient: \\(result4.patientName), Age: \\(result4.age)")
//        } catch {
//            print("\\n❌ Mock Claude response parsing failed: \\(error)")
//            XCTFail("Mock Claude response parsing should succeed")
//        }
        
        print("\\n=== Custom Model Testing Complete ===\\n")
    }
    
    /// Generic test helper that you can call with any model and response
    func testGenericModelParsing<T: Codable & Equatable>(
        model: T.Type,
        jsonResponse: String,
        expectedResult: T? = nil,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        do {
            let result = try JSONResponseParser.parseJSONString(jsonResponse, as: model)
            print("✅ Successfully parsed \\(String(describing: model))")
            print("   Result: \\(result)")
            
            if let expected = expectedResult {
                XCTAssertEqual(result, expected, "Parsed result should match expected", file: file, line: line)
            }
        } catch {
            print("❌ Failed to parse \\(String(describing: model)): \\(error)")
            XCTFail("Should successfully parse \\(String(describing: model))", file: file, line: line)
        }
    }
    
    /// Example usage of the generic test helper
//    func testUsingGenericHelper() {
//        // Example 1: Simple model
//        struct SimpleModel: Codable, Equatable {
//            let name: String
//            let value: Int
//        }
//        
//        let simpleJSON = "{\\"name\\": \\"Test\\", \\"value\\": 42}"
//        let expectedSimple = SimpleModel(name: "Test", value: 42)
//        
//        testGenericModelParsing(
//            model: SimpleModel.self,
//            jsonResponse: simpleJSON,
//            expectedResult: expectedSimple
//        )
//        
//        // Example 2: Array model
//        let arrayJSON = "[\\"apple\\", \\"banana\\", \\"cherry\\"]"
//        testGenericModelParsing(
//            model: [String].self,
//            jsonResponse: arrayJSON,
//            expectedResult: ["apple", "banana", "cherry"]
//        )
//    }
    
    // MARK: - Helper Methods
    
    private func encodeToJSONString<T: Codable>(_ object: T) throws -> String {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(object)
        return String(data: data, encoding: .utf8)!
    }
}
