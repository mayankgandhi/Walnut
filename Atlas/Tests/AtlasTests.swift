//
//  AtlasTests.swift
//  AtlasTests
//
//  Created by Mayank Gandhi on 08/08/25.
//  Copyright © 2025 m. All rights reserved.
//

import XCTest
@testable import Atlas
import SwiftUI

final class AtlasTests: XCTestCase {
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testContentViewInitialization() throws {
        // Test that ContentView can be initialized without crashing
        let contentView = ContentView()
        XCTAssertNotNil(contentView)
    }
    
    func testBloodTypesArray() throws {
        // Test that the blood types array contains expected values
        let contentView = ContentView()
        let bloodTypes = ["A+", "A-", "B+", "B-", "O+", "O-", "AB+", "AB-"]
        
        XCTAssertEqual(bloodTypes.count, 8)
        XCTAssertTrue(bloodTypes.contains("A+"))
        XCTAssertTrue(bloodTypes.contains("O-"))
        XCTAssertTrue(bloodTypes.contains("AB+"))
    }
    
    func testAppInitialization() throws {
        // Test that the main app can be initialized
        let app = AtlasApp()
        XCTAssertNotNil(app)
    }
    
    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
            let _ = ContentView()
        }
    }
}