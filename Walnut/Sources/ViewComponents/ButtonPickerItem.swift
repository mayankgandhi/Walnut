//
//  ButtonPickerItem.swift
//  Walnut
//
//  Created by Mayank Gandhi on 01/09/25.
//  Copyright © 2025 m. All rights reserved.
//

import SwiftUI
import WalnutDesignSystem

public protocol ButtonPickable: Hashable {
    var description: String { get }
    var icon: String { get }
}

/// Button picker component that shows a bottom sheet for selection
public struct ButtonPickerItem<T: ButtonPickable>: View {
    private let icon: String?
    private let title: String
    private let options: [T]
    private let helperText: String?
    private let errorMessage: String?
    private let iconColor: Color
    private let isRequired: Bool
    private let placeholder: String
    private let bottomSheetTitle: String
    
    @Binding private var selectedOption: T?
    @State private var isPressed = false
    @State private var showBottomSheet = false
    
    private var validationState: ValidationState {
        if let errorMessage = errorMessage, !errorMessage.isEmpty {
            return .error
        } else if isRequired && selectedOption == nil {
            return .warning
        } else if selectedOption != nil {
            return .success
        } else {
            return .normal
        }
    }
    
    public init(
        icon: String? = nil,
        title: String,
        selectedOption: Binding<T?>,
        options: [T],
        placeholder: String = "Select an option",
        bottomSheetTitle: String? = nil,
        helperText: String? = nil,
        errorMessage: String? = nil,
        iconColor: Color = .healthPrimary,
        isRequired: Bool = false
    ) {
        self.icon = icon
        self.title = title
        self._selectedOption = selectedOption
        self.options = options
        self.placeholder = placeholder
        self.bottomSheetTitle = bottomSheetTitle ?? title
        self.helperText = helperText
        self.errorMessage = errorMessage
        self.iconColor = iconColor
        self.isRequired = isRequired
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            // Main picker container
            HStack(spacing: Spacing.medium) {
                // Icon section
                if let icon = icon {
                    iconView
                }
                
                // Content section
                VStack(alignment: .leading, spacing: 2) {
                    // Title with required indicator
                    HStack(spacing: 4) {
                        Text(title)
                            .font(.system(.subheadline, design: .rounded, weight: .medium))
                            .foregroundStyle(.secondary)
                        
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
                    
                    // Selected value or placeholder
                    HStack(spacing: Spacing.small) {
                        if let icon = selectedOption?.icon {
                            Image(icon)
                                .resizable()
                                .frame(width: 24, height: 24)
                        }
                        
                        
                        Text(selectedOption?.description ?? placeholder)
                            .font(.system(.body, design: .rounded))
                            .foregroundStyle(selectedOption != nil ? .primary : .secondary)
                        
                        Spacer()
                        
                        Image(systemName: "chevron.up.chevron.down")
                            .font(.caption)
                            .foregroundStyle(.tertiary)
                    }
                }
            }
            .padding(.horizontal, Spacing.medium)
            .padding(.vertical, Spacing.small + 4)
            .background(backgroundView)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(strokeColor, lineWidth: 1)
            )
            .scaleEffect(isPressed ? 0.99 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: isPressed)
            .shadow(
                color: Color.black.opacity(0.05),
                radius: 2,
                x: 0,
                y: 1
            )
            .onTapGesture {
                showBottomSheet = true
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
        .sheet(isPresented: $showBottomSheet) {
            NavigationStack {
                    VStack(alignment: .leading, spacing: Spacing.medium) {
                        NavBarHeader(title: bottomSheetTitle)
                        
                        ScrollView {

                        LazyVGrid(
                            columns: [
                                .init(.flexible(), spacing: Spacing.medium),
                                .init(.flexible(), spacing: Spacing.medium)
                            ],
                            alignment: .leading,
                            spacing: Spacing.medium
                        ) {
                            ForEach(options, id: \.self) { option in
                                Button {
                                    selectedOption = option
                                    showBottomSheet = false
                                } label: {
                                    OptionButton(
                                        type: option,
                                        isSelected: selectedOption == option,
                                    )
                                }
                                .buttonStyle(.plain)
                                .padding(Spacing.xs)
                            }
                        }
                        .padding(.horizontal, Spacing.medium)

                    }
                }
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("Cancel") {
                            showBottomSheet = false
                        }
                    }
                    
                    if selectedOption != nil {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button("Done") {
                                showBottomSheet = false
                            }
                            .fontWeight(.semibold)
                        }
                    }
                }
            }
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.visible)
            .presentationCornerRadius(12)
            .interactiveDismissDisabled(false)
        }
    }
    
    private var iconView: some View {
        ZStack {
            Circle()
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            iconColor.opacity(0.08),
                            iconColor.opacity(0.12)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 44, height: 44)
            
            Circle()
                .stroke(iconColor.opacity(0.12), lineWidth: 1)
                .frame(width: 44, height: 44)
            
            Image(systemName: icon!)
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(iconColor.opacity(0.8))
        }
    }
    
    private var backgroundView: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(isPressed ? Color(.systemGray6) : Color(.systemBackground))
    }
    
    private var strokeColor: Color {
        if validationState == .error {
            return Color(.systemRed).opacity(0.4)
        } else if validationState == .warning && isRequired && selectedOption == nil {
            return Color(.systemOrange).opacity(0.4)
        } else {
            return Color(.systemGray5)
        }
    }
}

// MARK: - Supporting Views

struct OptionButton<T: ButtonPickable>: View {
    
    let type: T
    let isSelected: Bool
    
    var body: some View {
        HStack(spacing: Spacing.small) {
            // Icon with enhanced styling
            Image(type.icon)
                .resizable()
                .frame(width: 36, height: 36)
            
            Text(type.description)
                .font(.subheadline.weight(isSelected ? .semibold : .medium))
                .foregroundStyle(textColor)
                .lineLimit(2)
                .minimumScaleFactor(0.8)
        }
        .padding(Spacing.small)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(backgroundColor)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(borderColor, lineWidth: isSelected ? 2 : 1)
        )
        .animation(.easeInOut(duration: 0.2), value: isSelected)
        
    }
    
    // MARK: - Computed Properties
    
    private var backgroundColor: Color {
        if isSelected {
            return Color(UIColor.systemBackground)
        } else {
            return Color(UIColor.secondarySystemGroupedBackground)
        }
    }
    
    private var borderColor: Color {
        if isSelected {
            return Color.blue
        } else {
            return Color(UIColor.separator).opacity(0.5)
        }
    }
    
    private var textColor: Color {
        if isSelected {
            return Color.blue
        } else {
            return .primary
        }
    }
    
}


#Preview("Medical Specialty Picker") {
    @Previewable
    @State var selectedSpecialty: MedicalSpecialty? = nil
    
    VStack(spacing: Spacing.large) {
        
        
        if let selected = selectedSpecialty {
            Text("Selected: \(selected.description)")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        
        Spacer()
    }
    .padding()
}
