//
//  MedicationFrequencyBottomSheet.swift
//  Walnut
//
//  Created by Mayank Gandhi on 06/09/25.
//  Copyright © 2025 m. All rights reserved.
//

import SwiftUI
import WalnutDesignSystem

struct MedicationFrequencyBottomSheet: View {
    @Binding var selectedFrequencies: [MedicationFrequency]
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedFrequencyType: FrequencyType? = .daily
    @State private var dailyTimes: [DateComponents] = [DateComponents(hour: 8, minute: 0)]
    @State private var hourlyInterval: Int? = 4
    @State private var hourlyStartTime: DateComponents = DateComponents(hour: 8, minute: 0)
    @State private var weeklyDay: Weekday? = .monday
    @State private var weeklyTime: DateComponents = DateComponents(hour: 9, minute: 0)
    @State private var monthlyDay: Int? = 1
    @State private var monthlyTime: DateComponents = DateComponents(hour: 10, minute: 0)
    @State private var selectedMealTimes: [MealTime] = [.breakfast]
    @State private var selectedMedicationTime: MedicationTime? = .after
    
    private var isAddButtonEnabled: Bool {
        guard let frequencyType = selectedFrequencyType else { return false }

        switch frequencyType {
        case .mealBased:
            return !selectedMealTimes.isEmpty
        default:
            return true
        }
    }

    enum FrequencyType: String, CaseIterable, CustomStringConvertible {
        case daily = "Daily"
        case hourly = "Hourly"
        case weekly = "Weekly"
        case biweekly = "Bi-weekly"
        case monthly = "Monthly"
        case mealBased = "Meal-based"
        
        var icon: String {
            switch self {
            case .daily: return "clock.fill"
            case .hourly: return "timer"
            case .weekly, .biweekly: return "calendar.badge.clock"
            case .monthly: return "calendar.circle.fill"
            case .mealBased: return "fork.knife"
            }
        }
        
        var color: Color {
            switch self {
            case .daily: return .blue
            case .hourly: return .green
            case .weekly, .biweekly: return .orange
            case .monthly: return .purple
            case .mealBased: return .red
            }
        }
        
        var description: String {
            return rawValue
        }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Spacing.large) {
                    // Frequency Type Selection
                    VStack(alignment: .leading, spacing: Spacing.xs) {
                        Text("Frequency Type")
                            .font(.headline)
                            .foregroundStyle(.secondary)
                            .padding(.horizontal, Spacing.medium)
                        
                        MenuPickerItem(
                            icon: "clock.arrow.2.circlepath",
                            title: "Type",
                            selectedOption: $selectedFrequencyType,
                            options: FrequencyType.allCases,
                            placeholder: "Select frequency type",
                            iconColor: .healthPrimary
                        )
                    }
                    
                    // Dynamic input fields based on frequency type
                    frequencySpecificInputs
                    
                    Spacer(minLength: Spacing.xl)
                }
                .padding(.horizontal, Spacing.medium)
                .padding(.top, Spacing.medium)
            }
            .navigationTitle("Add Frequency")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        addFrequency()
                        dismiss()
                    }
                    .font(.system(size: 16, weight: .semibold))
                    .disabled(!isAddButtonEnabled)
                }
                
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", role: .cancel) {
                        dismiss()
                    }
                    .font(.system(size: 16, weight: .medium))
                }
            }
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
    }
    
    @ViewBuilder
    private var frequencySpecificInputs: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            Text("Schedule Details")
                .font(.headline)
                .foregroundStyle(.secondary)
                .padding(.horizontal, Spacing.medium)
            
            VStack(spacing: Spacing.medium) {
                switch selectedFrequencyType {
                case .daily:
                    dailyInputs
                case .hourly:
                    hourlyInputs
                case .weekly, .biweekly:
                    weeklyInputs
                case .monthly:
                    monthlyInputs
                case .mealBased:
                    mealBasedInputs
                case .none:
                        EmptyView()
                }
            }
        }
    }
    
    @ViewBuilder
    private var dailyInputs: some View {
        VStack(spacing: Spacing.medium) {
            ForEach(Array(dailyTimes.enumerated()), id: \.offset) { index, timeComponent in
                DatePickerItem(
                    icon: "clock",
                    title: "Time \(index + 1)",
                    selectedDate: Binding(
                        get: {
                            Calendar.current.date(from: timeComponent) ?? Date()
                        },
                        set: { newDate in
                            dailyTimes[index] = Calendar.current.dateComponents([.hour, .minute], from: newDate ?? Date())
                        }
                    ),
                    iconColor: .blue,
                    displayedComponents: [.hourAndMinute]
                )
            }
            
            Button {
                dailyTimes.append(DateComponents(hour: 8, minute: 0))
            } label: {
                HStack {
                    Image(systemName: "plus.circle")
                    Text("Add Another Time")
                }
                .font(.system(.body, design: .rounded, weight: .medium))
                .foregroundStyle(.blue)
            }
            .buttonStyle(PlainButtonStyle())
        }
    }
    
    @ViewBuilder
    private var hourlyInputs: some View {
        VStack(spacing: Spacing.medium) {
            MenuPickerItem(
                icon: "timer",
                title: "Interval",
                selectedOption: $hourlyInterval,
                options: Array(1...12),
                placeholder: "Select hours",
                helperText: "Every how many hours",
                iconColor: .green
            )
            
            DatePickerItem(
                icon: "clock.arrow.circlepath",
                title: "Start Time",
                selectedDate: Binding(
                    get: {
                        Calendar.current.date(from: hourlyStartTime) ?? Date()
                    },
                    set: { newDate in
                        hourlyStartTime = Calendar.current.dateComponents([.hour, .minute], from: newDate ?? Date())
                    }
                ),
                helperText: "When to start taking",
                iconColor: .green,
                displayedComponents: [.hourAndMinute]
            )
        }
    }
    
    @ViewBuilder
    private var weeklyInputs: some View {
        VStack(spacing: Spacing.medium) {
            MenuPickerItem(
                icon: "calendar",
                title: "Day of Week",
                selectedOption: $weeklyDay,
                options: Weekday.allCases,
                placeholder: "Select day",
                iconColor: .orange
            )
            
            DatePickerItem(
                icon: "clock",
                title: "Time",
                selectedDate: Binding(
                    get: {
                        Calendar.current.date(from: weeklyTime) ?? Date()
                    },
                    set: { newDate in
                        weeklyTime = Calendar.current.dateComponents([.hour, .minute], from: newDate ?? Date())
                    }
                ),
                iconColor: .orange,
                displayedComponents: [.hourAndMinute]
            )
        }
    }
    
    @ViewBuilder
    private var monthlyInputs: some View {
        VStack(spacing: Spacing.medium) {
            MenuPickerItem(
                icon: "calendar.circle",
                title: "Day of Month",
                selectedOption: $monthlyDay,
                options: Array(1...31),
                placeholder: "Select day",
                iconColor: .purple
            )
            
            DatePickerItem(
                icon: "clock",
                title: "Time",
                selectedDate: Binding(
                    get: {
                        Calendar.current.date(from: monthlyTime) ?? Date()
                    },
                    set: { newDate in
                        monthlyTime = Calendar.current.dateComponents([.hour, .minute], from: newDate ?? Date())
                    }
                ),
                iconColor: .purple,
                displayedComponents: [.hourAndMinute]
            )
        }
    }
    
    @ViewBuilder
    private var mealBasedInputs: some View {
        VStack(spacing: Spacing.medium) {
            // Multiple meal time selection
            VStack(alignment: .leading, spacing: Spacing.small) {
                HStack(spacing: Spacing.medium) {
                    Circle()
                        .fill(Color.red.opacity(0.15))
                        .frame(width: 36, height: 36)
                        .overlay {
                            Image(systemName: "fork.knife")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundStyle(.red)
                        }

                    VStack(alignment: .leading, spacing: 2) {
                        Text("Meal Times")
                            .font(.system(.subheadline, design: .rounded, weight: .medium))
                            .foregroundStyle(.secondary)

                        Text("Select one or more meal times")
                            .font(.caption)
                            .foregroundStyle(.tertiary)
                    }

                    Spacer()
                }
                .padding(.horizontal, Spacing.medium)
                .padding(.vertical, Spacing.small + 4)
                .background(Color(.systemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color(.systemGray5), lineWidth: 1)
                )

                // Meal time selection grid
                LazyVGrid(
                    columns: [
                        GridItem(.flexible(), spacing: Spacing.small),
                        GridItem(.flexible(), spacing: Spacing.small)
                    ],
                    spacing: Spacing.small
                ) {
                    ForEach(MealTime.allCases, id: \.self) { mealTime in
                        MealTimeSelectionChip(
                            mealTime: mealTime,
                            isSelected: selectedMealTimes.contains(mealTime)
                        ) {
                            toggleMealTimeSelection(mealTime)
                        }
                    }
                }
                .padding(.horizontal, Spacing.medium)
            }

            MenuPickerItem(
                icon: "clock.arrow.2.circlepath",
                title: "Timing",
                selectedOption: $selectedMedicationTime,
                options: MedicationTime.allCases,
                placeholder: "Before or after meal",
                iconColor: .red
            )
        }
    }
    
    private func addFrequency() {
        let newFrequency: MedicationFrequency?
        
        switch selectedFrequencyType {
        case .daily:
            newFrequency = .daily(times: dailyTimes)
        case .hourly:
            newFrequency = .hourly(interval: hourlyInterval ?? 0, startTime: hourlyStartTime)
        case .weekly:
            newFrequency = .weekly(dayOfWeek: weeklyDay ?? .monday, time: weeklyTime)
        case .biweekly:
            newFrequency = .biweekly(dayOfWeek: weeklyDay ?? .monday, time: weeklyTime)
        case .monthly:
            newFrequency = .monthly(dayOfMonth: monthlyDay ?? 1, time: monthlyTime)
        case .mealBased:
            // Create a frequency for each selected meal time
            for mealTime in selectedMealTimes {
                let mealFrequency = MedicationFrequency.mealBased(
                    mealTime: mealTime,
                    timing: selectedMedicationTime
                )
                selectedFrequencies.append(mealFrequency)
            }
            return // Exit early since we've added multiple frequencies
        default:
            newFrequency = nil
        }
        if let newFrequency {
            selectedFrequencies.append(newFrequency)
        }
    }

    private func toggleMealTimeSelection(_ mealTime: MealTime) {
        if selectedMealTimes.contains(mealTime) {
            // Don't allow deselecting if it's the only selected meal time
            if selectedMealTimes.count > 1 {
                selectedMealTimes.removeAll { $0 == mealTime }
            }
        } else {
            selectedMealTimes.append(mealTime)
        }
    }
}

// MARK: - Meal Time Selection Chip Component

struct MealTimeSelectionChip: View {
    let mealTime: MealTime
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: Spacing.small) {
                Image(systemName: mealTime.icon)
                    .font(.caption)
                    .foregroundStyle(isSelected ? .white : mealTime.color)

                Text(mealTime.displayName)
                    .font(.system(.caption, design: .rounded, weight: .medium))
                    .foregroundStyle(isSelected ? .white : .primary)
                    .lineLimit(1)
            }
            .padding(.horizontal, Spacing.small)
            .padding(.vertical, 6)
            .background(
                isSelected ? mealTime.color : mealTime.color.opacity(0.1)
            )
            .clipShape(Capsule())
            .overlay(
                Capsule()
                    .stroke(
                        isSelected ? mealTime.color : mealTime.color.opacity(0.3),
                        lineWidth: isSelected ? 2 : 1
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

