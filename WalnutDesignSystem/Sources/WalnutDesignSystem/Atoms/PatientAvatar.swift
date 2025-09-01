//
//  PatientAvatar.swift
//  WalnutDesignSystem
//
//  Created by Mayank Gandhi on 01/09/25.
//  Copyright © 2025 m. All rights reserved.
//

import SwiftUI

/// Patient avatar component
public struct PatientAvatar: View {
    private let name: String
    private let color: Color
    private let size: CGFloat
    
    public init(
        name: String,
        color: Color = .healthPrimary,
        size: CGFloat = Size.avatarMedium
    ) {
        self.name = name
        self.color = color
        self.size = size
    }
    
    public var body: some View {
        Circle()
            .fill(color.opacity(0.2))
            .overlay(
                Text(name.prefix(2))
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(color)
            )
            .frame(width: size, height: size)
    }
}
