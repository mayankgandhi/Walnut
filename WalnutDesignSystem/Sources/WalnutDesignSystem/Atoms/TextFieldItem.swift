//
//  TextFieldItem.swift
//  WalnutDesignSystem
//
//  Created by Mayank Gandhi on 08/08/25.
//  Copyright © 2025 m. All rights reserved.
//

import SwiftUI

/// Elegant text field component with MenuListItem-inspired design
public struct TextFieldItem: View {
    private let icon: String?
    private let title: String
    private let placeholder: String
    private let helperText: String?
    private let errorMessage: String?
    private let iconColor: Color
    private let isRequired: Bool
    private let keyboardType: UIKeyboardType
    private let contentType: UITextContentType?
    
    @Binding private var text: String
    @FocusState private var isFocused: Bool
    @State private var isPressed = false
    
    private var validationState: ValidationState {
        if let errorMessage = errorMessage, !errorMessage.isEmpty {
            return .error
        } else if isRequired && text.isEmpty {
            return .warning
        } else if !text.isEmpty {
            return .success
        } else {
            return .normal
        }
    }
    
    private enum ValidationState {
        case normal, success, warning, error
        
        var color: Color {
            switch self {
            case .normal: return Color(.systemGray2)
            case .success: return Color(.systemGreen).opacity(0.7)
            case .warning: return Color(.systemOrange).opacity(0.8)
            case .error: return Color(.systemRed).opacity(0.8)
            }
        }
        
        var iconName: String {
            switch self {
            case .normal: return ""
            case .success: return "checkmark.circle.fill"
            case .warning: return "exclamationmark.circle.fill"
            case .error: return "xmark.circle.fill"
            }
        }
    }
    
    public init(
        icon: String? = nil,
        title: String,
        text: Binding<String>,
        placeholder: String = "",
        helperText: String? = nil,
        errorMessage: String? = nil,
        iconColor: Color = .healthPrimary,
        isRequired: Bool = false,
        keyboardType: UIKeyboardType = .default,
        contentType: UITextContentType? = nil
    ) {
        self.icon = icon
        self.title = title
        self._text = text
        self.placeholder = placeholder
        self.helperText = helperText
        self.errorMessage = errorMessage
        self.iconColor = iconColor
        self.isRequired = isRequired
        self.keyboardType = keyboardType
        self.contentType = contentType
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            // Main text field container
            HStack(spacing: Spacing.medium) {
                // Icon section (similar to MenuListItem)
                if let icon = icon {
                    iconView
                }
                
                // Content section
                VStack(alignment: .leading, spacing: 2) {
                    // Title with required indicator
                    HStack(spacing: 4) {
                        Text(title)
                            .font(.system(.subheadline, design: .rounded, weight: .medium))
                            .foregroundStyle(isFocused ? .primary : .secondary)
                        
                        if isRequired {
                            Text("*")
                                .font(.system(.subheadline, design: .rounded, weight: .medium))
                                .foregroundStyle(Color(.systemRed).opacity(0.7))
                        }
                        
                        Spacer()
                        
                        // Validation icon
                        if !validationState.iconName.isEmpty && validationState != .normal {
                            Image(systemName: validationState.iconName)
                                .font(.caption)
                                .foregroundStyle(validationState.color)
                        }
                    }
                    
                    // Text field
                    TextField(placeholder, text: $text)
                        .font(.system(.body, design: .rounded))
                        .foregroundStyle(.primary)
                        .focused($isFocused)
                        .keyboardType(keyboardType)
                        .textContentType(contentType)
                        .submitLabel(.done)
                }
            }
            .padding(.horizontal, Spacing.medium)
            .padding(.vertical, Spacing.small + 4)
            .background(backgroundView)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(strokeColor, lineWidth: isFocused ? 2 : 1)
            )
            .scaleEffect(isPressed ? 0.99 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: isPressed)
            .animation(.easeInOut(duration: 0.2), value: isFocused)
            .shadow(
                color: isFocused ? Color.black.opacity(0.1) : Color.black.opacity(0.05),
                radius: isFocused ? 6 : 2,
                x: 0,
                y: isFocused ? 3 : 1
            )
            .onTapGesture {
                isFocused = true
            }
            .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, perform: {}, onPressingChanged: { pressing in
                isPressed = pressing
            })
            
            // Helper text or error message
            if let message = errorMessage, !message.isEmpty {
                Text(message)
                    .font(.system(.caption, design: .rounded))
                    .foregroundStyle(Color(.systemRed).opacity(0.8))
                    .padding(.horizontal, Spacing.medium)
            } else if let helper = helperText, !helper.isEmpty {
                Text(helper)
                    .font(.system(.caption, design: .rounded))
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, Spacing.medium)
            }
        }
    }
    
    private var iconView: some View {
        ZStack {
            // Gradient background (similar to MenuListItem)
            Circle()
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            (isFocused ? Color(.systemGray3) : iconColor).opacity(0.08),
                            (isFocused ? Color(.systemGray3) : iconColor).opacity(0.12)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 44, height: 44)
            
            // Subtle ring
            Circle()
                .stroke((isFocused ? Color(.systemGray4) : iconColor).opacity(0.12), lineWidth: 1)
                .frame(width: 44, height: 44)
            
            // Icon
            Image(systemName: icon!)
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(
                    isFocused ? Color(.systemGray) : iconColor.opacity(0.8)
                )
        }
        .scaleEffect(isFocused ? 1.05 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: isFocused)
    }
    
    private var backgroundView: some View {
        Group {
            if isFocused {
                RoundedRectangle(cornerRadius: 12)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(.systemGray6).opacity(0.3))
                    )
            } else {
                RoundedRectangle(cornerRadius: 12)
                    .fill(isPressed ? Color(.systemGray6) : Color(.systemBackground))
            }
        }
    }
    
    private var strokeColor: Color {
        if isFocused {
            return Color(.systemGray3).opacity(0.8)
        } else if validationState == .error {
            return Color(.systemRed).opacity(0.4)
        } else if validationState == .warning && isRequired && text.isEmpty {
            return Color(.systemOrange).opacity(0.4)
        } else {
            return Color(.systemGray5)
        }
    }
}

#Preview("Text Field Examples") {
    ScrollView {
        VStack(spacing: Spacing.large) {
            Text("Text Field Components")
                .font(.title2)
                .fontWeight(.bold)
                .padding(.horizontal)
            
            VStack(spacing: Spacing.medium) {
                TextFieldItem(
                    icon: "person.fill",
                    title: "Full Name",
                    text: .constant(""),
                    placeholder: "Enter your full name",
                    helperText: "This will be displayed on your profile",
                    isRequired: true
                )
                
                TextFieldItem(
                    icon: "envelope.fill",
                    title: "Email Address",
                    text: .constant("john.doe@example.com"),
                    placeholder: "Enter your email",
                    iconColor: .blue,
                    keyboardType: .emailAddress,
                    contentType: .emailAddress
                )
                
                TextFieldItem(
                    icon: "phone.fill",
                    title: "Phone Number",
                    text: .constant(""),
                    placeholder: "(555) 123-4567",
                    iconColor: .green,
                    isRequired: true,
                    keyboardType: .phonePad,
                    contentType: .telephoneNumber
                )
                
                TextFieldItem(
                    icon: "calendar",
                    title: "Date of Birth",
                    text: .constant("March 15, 1985"),
                    placeholder: "Select date",
                    helperText: "Used for age calculations",
                    iconColor: .purple
                )
                
                TextFieldItem(
                    icon: "heart.text.square",
                    title: "Blood Type",
                    text: .constant(""),
                    placeholder: "e.g. A+, O-, B+",
                    errorMessage: "Please enter a valid blood type",
                    iconColor: .red
                )
                
                TextFieldItem(
                    title: "Notes",
                    text: .constant("Patient has a history of hypertension"),
                    placeholder: "Additional notes...",
                    helperText: "Optional additional information"
                )
            }
            .padding(.horizontal)
        }
    }
    .background(Color(.systemGroupedBackground))
}

#Preview("Validation States") {
    VStack(spacing: Spacing.large) {
        Text("Validation States")
            .font(.title2)
            .fontWeight(.bold)
            .padding(.horizontal)
        
        VStack(spacing: Spacing.small) {
            TextFieldItem(
                icon: "checkmark.circle.fill",
                title: "Valid Field",
                text: .constant("Valid input"),
                placeholder: "Enter text",
                iconColor: .green
            )
            
            TextFieldItem(
                icon: "exclamationmark.triangle.fill",
                title: "Required Field",
                text: .constant(""),
                placeholder: "This field is required",
                iconColor: .orange,
                isRequired: true
            )
            
            TextFieldItem(
                icon: "xmark.circle.fill",
                title: "Error Field",
                text: .constant("invalid@"),
                placeholder: "Enter email",
                errorMessage: "Please enter a valid email address",
                iconColor: .red
            )
        }
        .padding(.horizontal)
        
        Spacer()
    }
    .background(Color(.systemGroupedBackground))
}
