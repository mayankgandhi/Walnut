//
//  WalnutDesignSystemTests.swift
//  WalnutDesignSystemTests
//
//  Created by Mayank Gandhi on 06/08/25.
//  Copyright © 2025 m. All rights reserved.
//

import XCTest
import SwiftUI
@testable import WalnutDesignSystem

final class WalnutDesignSystemTests: XCTestCase {

    
    func testSpacingValues() {
        XCTAssertEqual(Spacing.xs, 4)
        XCTAssertEqual(Spacing.small, 8)
        XCTAssertEqual(Spacing.medium, 16)
        XCTAssertEqual(Spacing.large, 24)
        XCTAssertEqual(Spacing.xl, 32)
    }
    
    func testSizeValues() {
        XCTAssertEqual(Size.touchTarget, 44)
        XCTAssertEqual(Size.avatarSmall, 32)
        XCTAssertEqual(Size.avatarMedium, 44)
        XCTAssertEqual(Size.avatarLarge, 56)
    }
    

    func testButtonStyles() {
        let primaryStyle = DSButtonStyle.primary
        let secondaryStyle = DSButtonStyle.secondary
        let destructiveStyle = DSButtonStyle.destructive
        
        XCTAssertEqual(primaryStyle.backgroundColor, .healthPrimary)
        XCTAssertEqual(secondaryStyle.backgroundColor, .clear)
        XCTAssertEqual(destructiveStyle.backgroundColor, .healthError)
    }
}
