//
//  InputFieldItems.swift
//  WalnutDesignSystem
//
//  Created by Mayank Gandhi on 08/08/25.
//  Copyright © 2025 m. All rights reserved.
//

import SwiftUI

// MARK: - Menu Picker Item

/// Menu picker component with TextFieldItem styling
public struct MenuPickerItem<T: Hashable & CustomStringConvertible>: View {
    private let icon: String?
    private let title: String
    private let options: [T]
    private let helperText: String?
    private let errorMessage: String?
    private let iconColor: Color
    private let isRequired: Bool
    private let placeholder: String
    
    @Binding private var selectedOption: T?
    @State private var isPressed = false
    
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
                    HStack {
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
            .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, perform: {}, onPressingChanged: { pressing in
                isPressed = pressing
            })
            .overlay(
                Menu {
                    ForEach(options, id: \.self) { option in
                        Button(action: {
                            selectedOption = option
                        }) {
                            Text(option.description)
                        }
                    }
                } label: {
                    Color.clear
                        .contentShape(Rectangle())
                }
            )
            
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

// MARK: - Date Picker Item

/// Date picker component with TextFieldItem styling
public struct DatePickerItem: View {
    private let icon: String?
    private let title: String
    private let helperText: String?
    private let errorMessage: String?
    private let iconColor: Color
    private let isRequired: Bool
    private let displayedComponents: DatePicker.Components
    
    @Binding private var selectedDate: Date?
    @State private var isPressed = false
    @State private var showingPicker = false
    
    private var validationState: ValidationState {
        if let errorMessage = errorMessage, !errorMessage.isEmpty {
            return .error
        } else if isRequired && selectedDate == nil {
            return .warning
        } else if selectedDate != nil {
            return .success
        } else {
            return .normal
        }
    }
    
    public init(
        icon: String? = nil,
        title: String,
        selectedDate: Binding<Date?>,
        helperText: String? = nil,
        errorMessage: String? = nil,
        iconColor: Color = .healthPrimary,
        isRequired: Bool = false,
        displayedComponents: DatePicker.Components = [.date]
    ) {
        self.icon = icon
        self.title = title
        self._selectedDate = selectedDate
        self.helperText = helperText
        self.errorMessage = errorMessage
        self.iconColor = iconColor
        self.isRequired = isRequired
        self.displayedComponents = displayedComponents
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            // Main date picker container
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
                    
                    // Selected date or placeholder
                    HStack {
                        if let date = selectedDate {
                            Text(formatDate(date))
                                .font(.system(.body, design: .rounded))
                                .foregroundStyle(.primary)
                        } else {
                            Text("Select date")
                                .font(.system(.body, design: .rounded))
                                .foregroundStyle(.secondary)
                        }
                        
                        Spacer()
                        
                        Image(systemName: "calendar")
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
                showingPicker = true
            }
            .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, perform: {}, onPressingChanged: { pressing in
                isPressed = pressing
            })
            .sheet(isPresented: $showingPicker) {
                NavigationView {
                    VStack {
                        DatePicker(
                            "Select Date",
                            selection: Binding(
                                get: { selectedDate ?? Date() },
                                set: { selectedDate = $0 }
                            ),
                            displayedComponents: displayedComponents
                        )
                        .datePickerStyle(.wheel)
                        .labelsHidden()
                        
                        Spacer()
                    }
                    .padding()
                    .navigationTitle(title)
                    .navigationBarTitleDisplayMode(.inline)
                    .navigationBarItems(
                        leading: Button("Cancel") {
                            showingPicker = false
                        },
                        trailing: Button("Done") {
                            showingPicker = false
                        }
                    )
                }
                .presentationDetents([.medium])
            }
            
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
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        if displayedComponents == [.date] {
            formatter.dateStyle = .medium
        } else if displayedComponents == [.hourAndMinute] {
            formatter.timeStyle = .short
        } else {
            formatter.dateStyle = .short
            formatter.timeStyle = .short
        }
        return formatter.string(from: date)
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
        } else if validationState == .warning && isRequired && selectedDate == nil {
            return Color(.systemOrange).opacity(0.4)
        } else {
            return Color(.systemGray5)
        }
    }
}

// MARK: - Toggle Item

/// Toggle switch component with TextFieldItem styling
public struct ToggleItem: View {
    private let icon: String?
    private let title: String
    private let subtitle: String?
    private let helperText: String?
    private let iconColor: Color
    
    @Binding private var isOn: Bool
    @State private var isPressed = false
    
    public init(
        icon: String? = nil,
        title: String,
        subtitle: String? = nil,
        isOn: Binding<Bool>,
        helperText: String? = nil,
        iconColor: Color = .healthPrimary
    ) {
        self.icon = icon
        self.title = title
        self.subtitle = subtitle
        self._isOn = isOn
        self.helperText = helperText
        self.iconColor = iconColor
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            // Main toggle container
            HStack(spacing: Spacing.medium) {
                // Icon section
                if let icon = icon {
                    iconView
                }
                
                // Content section
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(.body, design: .rounded, weight: .medium))
                        .foregroundStyle(.primary)
                    
                    if let subtitle = subtitle {
                        Text(subtitle)
                            .font(.system(.caption, design: .rounded))
                            .foregroundStyle(.secondary)
                            .lineLimit(2)
                    }
                }
                
                Spacer()
                
                // Toggle switch
                Toggle("", isOn: $isOn)
                    .labelsHidden()
            }
            .padding(.horizontal, Spacing.medium)
            .padding(.vertical, Spacing.small + 4)
            .background(backgroundView)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color(.systemGray5), lineWidth: 1)
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
            
            // Helper text
            if let helper = helperText, !helper.isEmpty {
                Text(helper)
                    .font(.system(.caption, design: .rounded))
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, Spacing.medium)
            }
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
}

// MARK: - Validation State Helper

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

// MARK: - Previews

enum BloodType: String, CaseIterable, CustomStringConvertible {
    case aPositive = "A+"
    case aNegative = "A-"
    case bPositive = "B+"
    case bNegative = "B-"
    case oPositive = "O+"
    case oNegative = "O-"
    case abPositive = "AB+"
    case abNegative = "AB-"
    
    var description: String { rawValue }
}

enum Gender: String, CaseIterable, CustomStringConvertible {
    case male = "Male"
    case female = "Female"
    case other = "Other"
    case preferNotToSay = "Prefer not to say"
    
    var description: String { rawValue }
}

#Preview("Menu Picker Examples") {
   
    
     ScrollView {
        VStack(spacing: Spacing.large) {
            Text("Menu Picker Examples")
                .font(.title2)
                .fontWeight(.bold)
                .padding(.horizontal)
            
            VStack(spacing: Spacing.medium) {
                MenuPickerItem(
                    icon: "drop.fill",
                    title: "Blood Type",
                    selectedOption: .constant(BloodType.aPositive),
                    options: BloodType.allCases,
                    helperText: "Select your blood type",
                    iconColor: .red
                )
                
                MenuPickerItem(
                    icon: "person.fill",
                    title: "Gender",
                    selectedOption: .constant(nil),
                    options: Gender.allCases,
                    placeholder: "Select gender",
                    iconColor: .purple,
                    isRequired: true
                )
                
                MenuPickerItem(
                    title: "Priority Level",
                    selectedOption: .constant(nil),
                    options: ["Low", "Medium", "High", "Critical"],
                    errorMessage: "Please select a priority level"
                )
            }
            .padding(.horizontal)
        }
    }
    .background(Color(.systemGroupedBackground))
}

#Preview("Date Picker Examples") {
    ScrollView {
        VStack(spacing: Spacing.large) {
            Text("Date Picker Examples")
                .font(.title2)
                .fontWeight(.bold)
                .padding(.horizontal)
            
            VStack(spacing: Spacing.medium) {
                DatePickerItem(
                    icon: "calendar",
                    title: "Date of Birth",
                    selectedDate: .constant(nil),
                    helperText: "Used for age calculations",
                    iconColor: .blue,
                    isRequired: true
                )
                
                DatePickerItem(
                    icon: "clock.fill",
                    title: "Appointment Time",
                    selectedDate: .constant(Date()),
                    iconColor: .green,
                    displayedComponents: [.hourAndMinute]
                )
                
                DatePickerItem(
                    title: "Last Updated",
                    selectedDate: .constant(Date()),
                    displayedComponents: [.date, .hourAndMinute]
                )
            }
            .padding(.horizontal)
        }
    }
    .background(Color(.systemGroupedBackground))
}

#Preview("Toggle Examples") {
    ScrollView {
        VStack(spacing: Spacing.large) {
            Text("Toggle Examples")
                .font(.title2)
                .fontWeight(.bold)
                .padding(.horizontal)
            
            VStack(spacing: Spacing.medium) {
                ToggleItem(
                    icon: "bell.fill",
                    title: "Medication Reminders",
                    subtitle: "Get notified when it's time to take medication",
                    isOn: .constant(true),
                    helperText: "Push notifications will be sent to your device",
                    iconColor: .orange
                )
                
                ToggleItem(
                    icon: "heart.fill",
                    title: "Health Data Sharing",
                    isOn: .constant(false),
                    iconColor: .red
                )
                
                ToggleItem(
                    title: "Emergency Contacts Access",
                    subtitle: "Allow emergency contacts to view your health information",
                    isOn: .constant(true)
                )
            }
            .padding(.horizontal)
        }
    }
    .background(Color(.systemGroupedBackground))
}

#Preview("All Input Types") {
    ScrollView {
        VStack(spacing: Spacing.large) {
            Text("All Input Types")
                .font(.title2)
                .fontWeight(.bold)
                .padding(.horizontal)
            
            VStack(spacing: Spacing.medium) {
                TextFieldItem(
                    icon: "person.fill",
                    title: "Full Name",
                    text: .constant("John Doe"),
                    placeholder: "Enter name"
                )
                
                MenuPickerItem(
                    icon: "drop.fill",
                    title: "Blood Type",
                    selectedOption: .constant("A+"),
                    options: ["A+", "A-", "B+", "B-", "O+", "O-"],
                    iconColor: .red
                )
                
                DatePickerItem(
                    icon: "calendar",
                    title: "Date of Birth",
                    selectedDate: .constant(nil),
                    iconColor: Color.blue,
                    isRequired: true
                )
                
                ToggleItem(
                    icon: "bell.fill",
                    title: "Notifications",
                    isOn: .constant(true),
                    iconColor: Color.orange
                )
            }
            .padding(.horizontal)
        }
    }
    .background(Color(.systemGroupedBackground))
}
