//
//  MedicationScheduleHeader.swift
//  Walnut
//
//  Created by Mayank Gandhi on 10/09/25.
//  Copyright © 2025 m. All rights reserved.
//

import SwiftUI
import WalnutDesignSystem

/// Header component for medication schedule with date selector and summary metrics
struct MedicationScheduleHeader: View {
    
    // MARK: - Properties
    
    @Binding var selectedDate: Date
    @Binding var showingDatePicker: Bool
    let scheduleMetrics: ScheduleMetrics
    
    // MARK: - Body
    
    var body: some View {
        HealthCard {
            VStack(spacing: Spacing.medium) {
                MedicationDateSelector(
                    selectedDate: $selectedDate,
                    showingDatePicker: $showingDatePicker
                )
                
                if scheduleMetrics.totalDoses > 0 {
                    MedicationScheduleSummary(metrics: scheduleMetrics)
                }
            }
            .padding(Spacing.medium)
        }
        .padding(.horizontal, Spacing.medium)
    }
}

// MARK: - Date Selector Component

/// Component for selecting the medication schedule date
struct MedicationDateSelector: View {
    
    // MARK: - Properties
    
    @Binding var selectedDate: Date
    @Binding var showingDatePicker: Bool
    
    // MARK: - Body
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("Schedule")
                    .font(.title2.weight(.bold))
                    .foregroundStyle(.primary)
                
                Text(formatSelectedDate())
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            Button {
                showingDatePicker.toggle()
            } label: {
                Image(systemName: "calendar")
                    .font(.title2)
                    .foregroundStyle(Color.healthPrimary)
            }
        }
        .sheet(isPresented: $showingDatePicker) {
            MedicationDatePickerSheet(selectedDate: $selectedDate)
        }
    }
    
    // MARK: - Helper Methods
    
    private func formatSelectedDate() -> String {
        let formatter = DateFormatter()
        if Calendar.current.isDateInToday(selectedDate) {
            return "Today"
        } else if Calendar.current.isDateInTomorrow(selectedDate) {
            return "Tomorrow"
        } else if Calendar.current.isDateInYesterday(selectedDate) {
            return "Yesterday"
        } else {
            formatter.dateStyle = .medium
            return formatter.string(from: selectedDate)
        }
    }
}

// MARK: - Schedule Summary Component

/// Component displaying medication schedule summary metrics
struct MedicationScheduleSummary: View {
    
    // MARK: - Properties
    
    let metrics: ScheduleMetrics
    
    // MARK: - Body
    
    var body: some View {
        HStack(spacing: Spacing.large) {
            ScheduleMetricItem(
                icon: "pills.fill",
                value: metrics.totalDoses,
                label: "Total",
                color: .healthPrimary
            )
            
            ScheduleMetricItem(
                icon: "checkmark.circle.fill",
                value: metrics.takenDoses,
                label: "Taken",
                color: .green
            )
            
            if metrics.overdueDoses > 0 {
                ScheduleMetricItem(
                    icon: "exclamationmark.triangle.fill",
                    value: metrics.overdueDoses,
                    label: "Overdue",
                    color: .red
                )
            }
            
            if metrics.upcomingDoses > 0 {
                ScheduleMetricItem(
                    icon: "clock.fill",
                    value: metrics.upcomingDoses,
                    label: "Upcoming",
                    color: .orange
                )
            }
        }
    }
}

// MARK: - Metric Item Component

/// Individual metric display component for schedule summary
struct ScheduleMetricItem: View {
    
    // MARK: - Properties
    
    let icon: String
    let value: Int
    let label: String
    let color: Color
    
    // MARK: - Body
    
    var body: some View {
        VStack(spacing: Spacing.xs) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(color)
            
            Text("\(value)")
                .font(.title3.weight(.bold))
                .foregroundStyle(.primary)
            
            Text(label)
                .font(.caption.weight(.medium))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Date Picker Sheet Component

/// Sheet view for selecting medication schedule date
struct MedicationDatePickerSheet: View {
    
    // MARK: - Properties
    
    @Binding var selectedDate: Date
    @Environment(\.dismiss) private var dismiss
    
    // MARK: - Body
    
    var body: some View {
        NavigationView {
            VStack {
                DatePicker(
                    "Select Date",
                    selection: $selectedDate,
                    displayedComponents: [.date]
                )
                .datePickerStyle(.graphical)
                .padding()
                
                Spacer()
            }
            .navigationTitle("Select Date")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Supporting Models

/// Data model for schedule metrics
struct ScheduleMetrics {
    let totalDoses: Int
    let takenDoses: Int
    let overdueDoses: Int
    let upcomingDoses: Int
    
    static let empty = ScheduleMetrics(
        totalDoses: 0,
        takenDoses: 0,
        overdueDoses: 0,
        upcomingDoses: 0
    )
}

// MARK: - Preview

#Preview {
    VStack {
        MedicationScheduleHeader(
            selectedDate: .constant(Date()),
            showingDatePicker: .constant(false),
            scheduleMetrics: ScheduleMetrics(
                totalDoses: 8,
                takenDoses: 5,
                overdueDoses: 1,
                upcomingDoses: 2
            )
        )
    }
    .background(Color(.systemGroupedBackground))
}
