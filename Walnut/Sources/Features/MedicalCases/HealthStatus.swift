//
//  HealthStatus.swift
//  Walnut
//
//  Created by Mayank Gandhi on 01/09/25.
//  Copyright © 2025 m. All rights reserved.
//

import Foundation
import WalnutDesignSystem
import SwiftUI

/// Simple health status indicator
public enum HealthStatus: CaseIterable {
    case optimal, good, warning, critical
    
    public var color: Color {
        switch self {
        case .optimal: return .healthSuccess
        case .good: return .healthPrimary
        case .warning: return .healthWarning
        case .critical: return .healthError
        }
    }
    
    public var displayName: String {
        switch self {
        case .optimal: return "Optimal"
        case .good: return "Good"
        case .warning: return "Warning"
        case .critical: return "Critical"
        }
    }
    
    public var icon: String {
        switch self {
        case .good: return "checkmark.circle.fill"
        case .warning: return "exclamationmark.triangle.fill"
        case .critical: return "xmark.circle.fill"
        case .optimal: return "exclamationmark.triangle.fill"
        }
    }
}
