//
//  AIKitTests.swift
//  AIKitTests
//
//  Created by Mayank Gandhi on 05/08/25.
//  Copyright © 2025 m. All rights reserved.
//

import XCTest
@testable import AIKit

final class AIKitTests: XCTestCase {
    
    func testAIKitVersion() {
        XCTAssertEqual(AIKit.version, "1.0.0")
    }
    
    func testMimeTypeResolver() {
        XCTAssertEqual(MimeTypeResolver.mimeType(for: "test.pdf"), "application/pdf")
        XCTAssertEqual(MimeTypeResolver.mimeType(for: "test.jpg"), "image/jpeg")
        XCTAssertEqual(MimeTypeResolver.mimeType(for: "test.png"), "image/png")
    }
    
    func testConfiguration() {
        let config = AIKitConfiguration(openAIAPIKey: "test-key")
        XCTAssertEqual(config.openAIAPIKey, "test-key")
        XCTAssertNil(config.claudeAPIKey)
    }
    
    func testFactoryMethods() {
        let unified = AIKitFactory.createUnifiedService(openAIAPIKey: "test-key")
        XCTAssertNotNil(unified)
        
        let openAI = AIKitFactory.createOpenAIService(apiKey: "test-key")
        XCTAssertNotNil(openAI)
    }
}