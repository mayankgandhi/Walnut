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
  
}
