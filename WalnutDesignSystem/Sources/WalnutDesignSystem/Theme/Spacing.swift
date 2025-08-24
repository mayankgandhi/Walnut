//
//  Spacing.swift
//  WalnutDesignSystem
//
//  Created by Mayank Gandhi on 06/08/25.
//  Copyright © 2025 m. All rights reserved.
//

import SwiftUI

/// Essential spacing values following 8pt grid
public struct Spacing {
    public static let xs: CGFloat = 4
    public static let small: CGFloat = 8
    public static let medium: CGFloat = 16
    public static let large: CGFloat = 24
    public static let xl: CGFloat = 32
}

/// Essential sizing values
public struct Size {
    /// iOS HIG minimum touch target
    public static let touchTarget: CGFloat = 44
    
    /// Standard avatar sizes
    public static let avatarSmall: CGFloat = 32
    public static let avatarMedium: CGFloat = 44
    public static let avatarLarge: CGFloat = 56
}

// MARK: - View Extensions

public extension View {
    /// Apply card styling with native materials
    func cardStyle() -> some View {
        self
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
    }
    
    /// Apply subtle card styling
    func subtleCardStyle() -> some View {
        self
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 8))
    }
    
    /// Ensure minimum touch target size
    func touchTarget() -> some View {
        self
            .frame(minWidth: Size.touchTarget, minHeight: Size.touchTarget)
    }
}
