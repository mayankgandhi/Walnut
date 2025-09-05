//
//  MedicationDurationPickerItem.swift
//  Walnut
//
//  Created by Mayank Gandhi on 06/09/25.
//  Copyright © 2025 m. All rights reserved.
//

import SwiftUI
import WalnutDesignSystem

// MARK: - Medication Duration Picker Item

/// Specialized dual-picker component for MedicationDuration selection
public struct MedicationDurationPickerItem: View {
    private let icon: String?
    private let title: String
    private let helperText: String?
    private let errorMessage: String?
    private let iconColor: Color
    private let isRequired: Bool
    private let placeholder: String
    
    @Binding private var selectedDuration: MedicationDuration?
    @State private var isPressed = false
    @State private var durationType: DurationType = .days
    @State private var durationValue: Int = 7
    @State private var followUpDate: Date = Date().addingTimeInterval(86400 * 30) // 30 days from now
    
    private enum DurationType: String, CaseIterable {
        case days = "Days"
        case weeks = "Weeks"
        case months = "Months"
        case ongoing = "Ongoing"
        case asNeeded = "As Needed"
        case untilFollowUp = "Until Follow-up"
        
        var needsNumericValue: Bool {
            switch self {
            case .days, .weeks, .months:
                return true
            case .ongoing, .asNeeded, .untilFollowUp:
                return false
            }
        }
        
        var defaultValue: Int {
            switch self {
            case .days: return 7
            case .weeks: return 2
            case .months: return 3
            default: return 1
            }
        }
        
        var valueRange: ClosedRange<Int> {
            switch self {
            case .days: return 1...90
            case .weeks: return 1...12
            case .months: return 1...24
            default: return 1...1
            }
        }
    }
    
    private var validationState: ValidationState {
        if let errorMessage = errorMessage, !errorMessage.isEmpty {
            return .error
        } else if isRequired && selectedDuration == nil {
            return .warning
        } else if selectedDuration != nil {
            return .success
        } else {
            return .normal
        }
    }
    
    init(
        icon: String? = nil,
        title: String,
        selectedDuration: Binding<MedicationDuration?>,
        placeholder: String = "Select duration",
        helperText: String? = nil,
        errorMessage: String? = nil,
        iconColor: Color = .healthPrimary,
        isRequired: Bool = false
    ) {
        self.icon = icon
        self.title = title
        self._selectedDuration = selectedDuration
        self.placeholder = placeholder
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
                    
                    // Dual picker layout
                    HStack(spacing: 8) {
                        // Duration type picker
                        Menu {
                            ForEach(DurationType.allCases, id: \.self) { type in
                                Button(type.rawValue) {
                                    durationType = type
                                    if type.needsNumericValue {
                                        durationValue = type.defaultValue
                                    }
                                    updateSelectedDuration()
                                }
                            }
                        } label: {
                            HStack {
                                Text(durationType.rawValue)
                                    .font(.system(.body, design: .rounded))
                                    .foregroundStyle(.primary)
                                
                                Image(systemName: "chevron.down")
                                    .font(.caption2)
                                    .foregroundStyle(.tertiary)
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color(.systemGray6))
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                        
                        // Numeric value picker (when needed)
                        if durationType.needsNumericValue {
                            Menu {
                                ForEach(Array(durationType.valueRange), id: \.self) { value in
                                    Button("\(value)") {
                                        durationValue = value
                                        updateSelectedDuration()
                                    }
                                }
                            } label: {
                                HStack {
                                    Text("\(durationValue)")
                                        .font(.system(.body, design: .rounded, weight: .medium))
                                        .foregroundStyle(.primary)
                                    
                                    Image(systemName: "chevron.down")
                                        .font(.caption2)
                                        .foregroundStyle(.tertiary)
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(iconColor.opacity(0.1))
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                            }
                        }
                        
                        // Date picker for "Until Follow-up"
                        if durationType == .untilFollowUp {
                            DatePicker(
                                "",
                                selection: $followUpDate,
                                displayedComponents: .date
                            )
                            .labelsHidden()
                            .onChange(of: followUpDate) { _, _ in
                                updateSelectedDuration()
                            }
                        }
                        
                        Spacer()
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
        .onAppear {
            initializeFromSelectedDuration()
        }
    }
    
    private var iconView: some View {
        Circle()
            .fill(iconColor.opacity(0.15))
            .frame(width: 36, height: 36)
            .overlay {
                Image(systemName: icon!)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(iconColor)
            }
    }
    
    private var backgroundView: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(isPressed ? Color(.systemGray6) : Color(.systemBackground))
    }
    
    private var strokeColor: Color {
        if validationState == .error {
            return Color(.systemRed).opacity(0.4)
        } else if validationState == .warning && isRequired && selectedDuration == nil {
            return Color(.systemOrange).opacity(0.4)
        } else {
            return Color(.systemGray5)
        }
    }
    
    private func updateSelectedDuration() {
        switch durationType {
        case .days:
            selectedDuration = .days(durationValue)
        case .weeks:
            selectedDuration = .weeks(durationValue)
        case .months:
            selectedDuration = .months(durationValue)
        case .ongoing:
            selectedDuration = .ongoing
        case .asNeeded:
            selectedDuration = .asNeeded
        case .untilFollowUp:
            selectedDuration = .untilFollowUp(followUpDate)
        }
    }
    
    private func initializeFromSelectedDuration() {
        guard let duration = selectedDuration else {
            durationType = .days
            durationValue = 7
            return
        }
        
        switch duration {
        case .days(let days):
            durationType = .days
            durationValue = days
        case .weeks(let weeks):
            durationType = .weeks
            durationValue = weeks
        case .months(let months):
            durationType = .months
            durationValue = months
        case .ongoing:
            durationType = .ongoing
        case .asNeeded:
            durationType = .asNeeded
        case .untilFollowUp(let date):
            durationType = .untilFollowUp
            followUpDate = date
        }
    }
}
