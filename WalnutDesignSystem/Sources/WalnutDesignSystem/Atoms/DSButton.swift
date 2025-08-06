//
//  WalnutButton.swift
//  WalnutDesignSystem
//
//  Created by Mayank Gandhi on 06/08/25.
//  Copyright © 2025 m. All rights reserved.
//

import SwiftUI

/// Simple healthcare button styles
public enum DSButtonStyle {
    case primary
    case secondary
    case destructive
    
    var backgroundColor: Color {
        switch self {
        case .primary: return .healthPrimary
        case .secondary: return .clear
        case .destructive: return .healthError
        }
    }
    
    var foregroundColor: Color {
        switch self {
        case .primary, .destructive: return .white
        case .secondary: return .healthPrimary
        }
    }
    
    var borderColor: Color? {
        switch self {
        case .primary, .destructive: return nil
        case .secondary: return .healthPrimary
        }
    }
}

/// Healthcare-focused button component
public struct DSButton: View {
    private let title: String
    private let style: DSButtonStyle
    private let icon: String?
    private let action: () -> Void
    @State private var isPressed = false
    
    public init(
        _ title: String,
        style: DSButtonStyle = .primary,
        icon: String? = nil,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.style = style
        self.icon = icon
        self.action = action
    }
    
    public var body: some View {
        Button(action: action) {
            HStack(spacing: Spacing.small) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.body.weight(.medium))
                }
                
                Text(title)
                    .font(.body.weight(.semibold))
            }
            .foregroundStyle(style.foregroundColor)
            .padding(.horizontal, Spacing.medium)
            .padding(.vertical, Spacing.small)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(style.backgroundColor)
                    .stroke(style.borderColor ?? .clear, lineWidth: 1)
            )
            .scaleEffect(isPressed ? 0.96 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: isPressed)
        }
        .touchTarget()
        .accessibilityLabel(title)
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity) { isPressing in
            isPressed = isPressing
        } perform: { }
    }
}

/// Icon-only button
public struct HealthIconButton: View {
    private let icon: String
    private let style: DSButtonStyle
    private let action: () -> Void
    @State private var isPressed = false
    
    public init(
        icon: String,
        style: DSButtonStyle = .secondary,
        action: @escaping () -> Void
    ) {
        self.icon = icon
        self.style = style
        self.action = action
    }
    
    public var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.body.weight(.medium))
                .foregroundStyle(style.foregroundColor)
                .frame(width: Size.touchTarget, height: Size.touchTarget)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(style.backgroundColor)
                        .stroke(style.borderColor ?? .clear, lineWidth: 1)
                )
                .scaleEffect(isPressed ? 0.96 : 1.0)
                .animation(.easeInOut(duration: 0.1), value: isPressed)
        }
        .accessibilityLabel(icon)
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity) { isPressing in
            isPressed = isPressing
        } perform: { }
    }
}

// MARK: - Preview

#Preview("Health Buttons") {
    VStack(spacing: Spacing.large) {
        VStack(spacing: Spacing.medium) {
            Text("Button Styles")
                .font(.headline)
            
            DSButton("Primary Action", style: .primary) { }
            DSButton("Secondary Action", style: .secondary) { }
            DSButton("Delete", style: .destructive, icon: "trash") { }
        }
        
        VStack(spacing: Spacing.medium) {
            Text("Icon Buttons")
                .font(.headline)
            
            HStack(spacing: Spacing.medium) {
                HealthIconButton(icon: "heart.fill", style: .primary) { }
                HealthIconButton(icon: "plus", style: .secondary) { }
                HealthIconButton(icon: "gear", style: .secondary) { }
            }
        }
    }
    .padding(Spacing.large)
}
