//
//  Colors.swift
//  WalnutDesignSystem
//
//  Created by Mayank Gandhi on 06/08/25.
//  Copyright © 2025 m. All rights reserved.
//

import SwiftUI

/// Walnut Design System Colors
/// Uses native SwiftUI system colors with healthcare-specific additions
public extension Color {
    
    // MARK: - Healthcare Brand Colors
    
    /// Primary healthcare blue - supports light/dark mode
    static let healthPrimary = Color(light: Color(red: 0.42, green: 0.45, blue: 1.0),
                                   dark: Color(red: 0.52, green: 0.55, blue: 1.0))
    
    /// Healthcare success green
    static let healthSuccess = Color(light: Color(red: 0.0, green: 0.78, blue: 0.59),
                                   dark: Color(red: 0.0, green: 0.88, blue: 0.69))
    
    /// Healthcare warning orange
    static let healthWarning = Color(light: Color(red: 1.0, green: 0.72, blue: 0.0),
                                   dark: Color(red: 1.0, green: 0.82, blue: 0.3))
    
    /// Healthcare error red
    static let healthError = Color(light: Color(red: 1.0, green: 0.34, blue: 0.34),
                                 dark: Color(red: 1.0, green: 0.44, blue: 0.44))
    
    // MARK: - Health-Specific Semantic Colors
    
    /// Heart rate and cardiovascular metrics
    static let heartRate = Color.red
    
    /// Blood glucose and diabetes metrics
    static let glucose = Color.orange
    
    /// Medication and prescription colors
    static let medication = Color.purple
    
    /// Lab results and test indicators
    static let labResults = Color.cyan
}

// MARK: - Light/Dark Mode Helper

private extension Color {
    init(light: Color, dark: Color) {
        self.init(UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark ? UIColor(dark) : UIColor(light)
        })
    }
}