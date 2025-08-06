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
    
    func testDesignSystemVersion() {
        XCTAssertEqual(WalnutDesignSystem.version, "1.0.0")
    }
    
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
    
    func testHealthStatusColors() {
        let goodStatus = HealthStatus.good
        let warningStatus = HealthStatus.warning
        let criticalStatus = HealthStatus.critical
        
        XCTAssertEqual(goodStatus.color, .healthSuccess)
        XCTAssertEqual(warningStatus.color, .healthWarning)
        XCTAssertEqual(criticalStatus.color, .healthError)
    }
    
    func testHealthStatusIcons() {
        XCTAssertEqual(HealthStatus.good.icon, "checkmark.circle.fill")
        XCTAssertEqual(HealthStatus.warning.icon, "exclamationmark.triangle.fill")
        XCTAssertEqual(HealthStatus.critical.icon, "xmark.circle.fill")
    }
    
    func testButtonStyles() {
        let primaryStyle = HealthButtonStyle.primary
        let secondaryStyle = HealthButtonStyle.secondary
        let destructiveStyle = HealthButtonStyle.destructive
        
        XCTAssertEqual(primaryStyle.backgroundColor, .healthPrimary)
        XCTAssertEqual(secondaryStyle.backgroundColor, .clear)
        XCTAssertEqual(destructiveStyle.backgroundColor, .healthError)
    }
}