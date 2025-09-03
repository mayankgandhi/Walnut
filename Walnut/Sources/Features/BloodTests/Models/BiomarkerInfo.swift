//
//  BiomarkerInfo.swift
//  WalnutDesignSystem
//
//  Created by Mayank Gandhi on 08/08/25.
//  Copyright © 2025 m. All rights reserved.
//

import Foundation
import SwiftUI

/// Biomarker information model
public struct BiomarkerInfo {
    let name: String
    let normalRange: String
    let unit: String
    
    public init(name: String, normalRange: String, unit: String) {
        self.name = name
        self.normalRange = normalRange
        self.unit = unit
    }
}

