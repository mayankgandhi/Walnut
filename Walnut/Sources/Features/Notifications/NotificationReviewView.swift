//
//  NotificationReviewView.swift
//  Walnut
//
//  Created by Claude Code on 16/09/25.
//  Copyright © 2025 m. All rights reserved.
//

import SwiftUI
import SwiftData
import UserNotifications
import WalnutDesignSystem

struct NotificationReviewView: View {

    @Environment(\.modelContext) private var modelContext
    @Environment(\.notificationErrorHandler) private var errorHandler
    @State private var notificationManager = MedicationNotificationManager()
    @State private var upcomingNotifications: [UpcomingNotificationGroup] = []
    @State private var isRefreshing = false

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: Spacing.large) {
                    if upcomingNotifications.isEmpty {
                        emptyStateView
                    } else {
                        notificationSections
                    }
                }
                .padding(.horizontal, Spacing.medium)
                .padding(.top, Spacing.medium)
            }
            .navigationTitle("Medication Reminders")
            .navigationBarTitleDisplayMode(.large)
            .refreshable {
                await refreshNotifications()
            }
            .onAppear {
                Task {
                    await loadUpcomingNotifications()
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Button(action: {
                            Task { await refreshNotifications() }
                        }) {
                            Label("Refresh", systemImage: "arrow.clockwise")
                        }

                        Button(action: {
                            Task { await clearAllNotifications() }
                        }) {
                            Label("Clear All", systemImage: "trash")
                        }
                        .foregroundStyle(.red)

                        Divider()

                        Button(action: {
                            notificationManager.enableNotificationGrouping.toggle()
                            Task { await refreshNotifications() }
                        }) {
                            Label(
                                notificationManager.enableNotificationGrouping ? "Disable Grouping" : "Enable Grouping",
                                systemImage: notificationManager.enableNotificationGrouping ? "rectangle.split.3x1" : "rectangle.stack"
                            )
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
        }
        .notificationErrorHandling()
    }

    // MARK: - Views

    private var emptyStateView: some View {
        VStack(spacing: Spacing.large) {
            Spacer()

            VStack(spacing: Spacing.medium) {
                Circle()
                    .fill(Color.healthPrimary.opacity(0.15))
                    .frame(width: 80, height: 80)
                    .overlay {
                        Image(systemName: "bell.badge")
                            .font(.system(size: 32, weight: .light))
                            .foregroundStyle(Color.healthPrimary)
                    }

                VStack(spacing: Spacing.small) {
                    Text("No Upcoming Reminders")
                        .font(.title3.weight(.semibold))
                        .foregroundStyle(.primary)

                    Text("Add medications to your prescriptions to see upcoming reminders here")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, Spacing.medium)
                }
            }

            Spacer()
        }
    }

    @ViewBuilder
    private var notificationSections: some View {
        let todayNotifications = upcomingNotifications.filter { $0.isToday }
        let tomorrowNotifications = upcomingNotifications.filter { $0.isTomorrow }
        let laterNotifications = upcomingNotifications.filter { !$0.isToday && !$0.isTomorrow }

        if !todayNotifications.isEmpty {
            notificationSection(
                title: "Today",
                subtitle: "\(todayNotifications.count) reminder\(todayNotifications.count == 1 ? "" : "s")",
                notifications: todayNotifications,
                headerColor: .healthPrimary
            )
        }

        if !tomorrowNotifications.isEmpty {
            notificationSection(
                title: "Tomorrow",
                subtitle: "\(tomorrowNotifications.count) reminder\(tomorrowNotifications.count == 1 ? "" : "s")",
                notifications: tomorrowNotifications,
                headerColor: .healthSuccess
            )
        }

        if !laterNotifications.isEmpty {
            notificationSection(
                title: "Later",
                subtitle: "\(laterNotifications.count) reminder\(laterNotifications.count == 1 ? "" : "s")",
                notifications: laterNotifications,
                headerColor: .secondary
            )
        }
    }

    private func notificationSection(
        title: String,
        subtitle: String,
        notifications: [UpcomingNotificationGroup],
        headerColor: Color
    ) -> some View {
        VStack(alignment: .leading, spacing: Spacing.medium) {
            HStack {
                VStack(alignment: .leading, spacing: Spacing.xs) {
                    Text(title)
                        .font(.title2.weight(.bold))
                        .foregroundStyle(headerColor)

                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Spacer()
            }
            .padding(.horizontal, Spacing.small)

            LazyVStack(spacing: Spacing.small) {
                ForEach(notifications) { notification in
                    notificationCard(notification)
                }
            }
        }
    }

    private func notificationCard(_ notificationGroup: UpcomingNotificationGroup) -> some View {
        HealthCard {
            VStack(spacing: Spacing.medium) {
                HStack(spacing: Spacing.medium) {
                    // Medication icon(s)
                    if notificationGroup.isSingle {
                        Circle()
                            .fill(notificationGroup.primaryColor.opacity(0.15))
                            .frame(width: 44, height: 44)
                            .overlay {
                                Image(systemName: "pills.fill")
                                    .font(.system(size: 20, weight: .semibold))
                                    .foregroundStyle(notificationGroup.primaryColor)
                            }
                    } else {
                        ZStack {
                            Circle()
                                .fill(Color.healthPrimary.opacity(0.15))
                                .frame(width: 44, height: 44)

                            Text("\(notificationGroup.medicationCount)")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundStyle(Color.healthPrimary)
                        }
                    }

                    // Medication details
                    VStack(alignment: .leading, spacing: Spacing.xs) {
                        if notificationGroup.isSingle {
                            Text(notificationGroup.displayTitle)
                                .font(.headline.weight(.semibold))
                                .foregroundStyle(.primary)
                                .lineLimit(2)

                            if let dosage = notificationGroup.displaySubtitle {
                                Text(dosage)
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                        } else {
                            Text(notificationGroup.displayTitle)
                                .font(.headline.weight(.semibold))
                                .foregroundStyle(.primary)

                            Text(notificationGroup.displaySubtitle ?? "")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .lineLimit(2)
                        }

                        Text(notificationGroup.timeDisplayText)
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(notificationGroup.isToday ? Color.healthPrimary : .secondary)
                    }

                    Spacer()

                    // Time badge
                    VStack(spacing: Spacing.xs) {
                        Text(notificationGroup.formattedTime)
                            .font(.system(.subheadline, design: .rounded, weight: .semibold))
                            .foregroundStyle(notificationGroup.isToday ? .white : .primary)

                        Text(notificationGroup.formattedDate)
                            .font(.system(.caption2, design: .rounded, weight: .medium))
                            .foregroundStyle(notificationGroup.isToday ? .white.opacity(0.8) : .secondary)
                    }
                    .padding(.horizontal, Spacing.small)
                    .padding(.vertical, Spacing.xs)
                    .background(notificationGroup.isToday ? Color.healthPrimary : Color.secondary.opacity(0.1))
                    .cornerRadius(8)
                }

                // Grouped medications list
                if notificationGroup.isGrouped {
                    VStack(alignment: .leading, spacing: Spacing.xs) {
                        ForEach(Array(notificationGroup.medications.enumerated()), id: \.offset) { index, medication in
                            HStack(spacing: Spacing.small) {
                                Circle()
                                    .fill(Color.secondary.opacity(0.3))
                                    .frame(width: 6, height: 6)

                                Text(medication.name)
                                    .font(.caption)
                                    .foregroundStyle(.primary)

                                if let dosage = medication.dosage {
                                    Text("(\(dosage))")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }

                                Spacer()
                            }
                        }
                    }
                    .padding(.top, Spacing.xs)
                }

                // Instructions if available (for single medication)
                if notificationGroup.isSingle,
                   let instructions = notificationGroup.medications.first?.instructions,
                   !instructions.isEmpty {
                    HStack(spacing: Spacing.small) {
                        Image(systemName: "info.circle")
                            .font(.caption)
                            .foregroundStyle(.blue)

                        Text(instructions)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .lineLimit(3)

                        Spacer()
                    }
                    .padding(.top, Spacing.xs)
                }
            }
        }
    }

    // MARK: - Data Loading

    private func loadUpcomingNotifications() async {
        await MainActor.run { isRefreshing = true }

        // Get all medications from the model context
        let descriptor = FetchDescriptor<Medication>()
        do {
            let medications = try modelContext.fetch(descriptor)
            let notifications = await generateUpcomingNotifications(from: medications)

            await MainActor.run {
                self.upcomingNotifications = notifications.sorted { $0.scheduledDate < $1.scheduledDate }
                self.isRefreshing = false
            }
        } catch {
            await MainActor.run {
                errorHandler.handleError(error)
                isRefreshing = false
            }
        }
    }

    private func generateUpcomingNotifications(from medications: [Medication]) async -> [UpcomingNotificationGroup] {
        // Create notification infos similar to MedicationNotificationManager
        var notificationInfos: [ReviewNotificationInfo] = []
        let calendar = Calendar.current
        let now = Date()
        let endDate = calendar.date(byAdding: .day, value: 7, to: now) ?? now // Next 7 days

        for medication in medications {
            guard let frequencies = medication.frequency, !frequencies.isEmpty else { continue }

            for frequency in frequencies {
                let schedules = generateNotificationSchedulesForFrequency(frequency)

                for schedule in schedules {
                    let scheduleDates = generateScheduleDates(for: schedule, from: now, to: endDate)

                    for date in scheduleDates {
                        let info = ReviewNotificationInfo(
                            medication: medication,
                            frequency: frequency,
                            scheduledDate: date,
                            timeKey: MedicationGroup.TimeKey(
                                hour: calendar.component(.hour, from: date),
                                minute: calendar.component(.minute, from: date)
                            )
                        )
                        notificationInfos.append(info)
                    }
                }
            }
        }

        // Group by date and time
        let groupedByDateTime = Dictionary(grouping: notificationInfos) { info in
            let components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: info.scheduledDate)
            return calendar.date(from: components) ?? info.scheduledDate
        }

        // Convert to notification groups
        let groups = groupedByDateTime.map { dateTime, infos in
            UpcomingNotificationGroup(
                scheduledDate: dateTime,
                medications: infos.map { info in
                    UpcomingNotification(
                        id: "\(info.medication.id?.uuidString ?? UUID().uuidString)_\(dateTime.timeIntervalSince1970)",
                        medicationName: info.medication.name ?? "Medication",
                        dosage: info.medication.dosage,
                        instructions: info.medication.instructions,
                        scheduledDate: dateTime,
                        medicationColor: getColorForMedication(info.medication)
                    )
                }
            )
        }

        return groups.sorted { $0.scheduledDate < $1.scheduledDate }
    }

    private func generateNotificationSchedulesForFrequency(_ frequency: MedicationFrequency) -> [NotificationSchedule] {
        switch frequency {
        case .daily(let times):
            return times.compactMap { timeComponent in
                NotificationSchedule.daily(hour: timeComponent.hour ?? 0, minute: timeComponent.minute ?? 0)
            }

        case .hourly(let interval, let startTime):
            return generateHourlySchedules(interval: interval, startTime: startTime)

        case .weekly(let dayOfWeek, let time):
            return [NotificationSchedule.weekly(
                weekday: dayOfWeek.rawValue,
                hour: time.hour ?? 0,
                minute: time.minute ?? 0
            )]

        case .biweekly(let dayOfWeek, let time):
            return [NotificationSchedule.biweekly(
                weekday: dayOfWeek.rawValue,
                hour: time.hour ?? 0,
                minute: time.minute ?? 0
            )]

        case .monthly(let dayOfMonth, let time):
            return [NotificationSchedule.monthly(
                day: dayOfMonth,
                hour: time.hour ?? 0,
                minute: time.minute ?? 0
            )]

        case .mealBased(let mealTime, let timing):
            return generateMealBasedSchedule(mealTime: mealTime, timing: timing)
        }
    }

    private func generateHourlySchedules(interval: Int, startTime: DateComponents?) -> [NotificationSchedule] {
        let start = startTime ?? DateComponents(hour: 8, minute: 0)
        let startHour = start.hour ?? 8
        var schedules: [NotificationSchedule] = []

        var currentHour = startHour
        repeat {
            schedules.append(.daily(hour: currentHour % 24, minute: start.minute ?? 0))
            currentHour += interval
        } while currentHour < startHour + 24

        return schedules
    }

    private func generateMealBasedSchedule(mealTime: MealTime, timing: MedicationTime?) -> [NotificationSchedule] {
        guard let mealDate = notificationManager.mealTimings[mealTime] else { return [] }

        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: mealDate)
        let hour = components.hour ?? 0
        let minute = components.minute ?? 0

        let adjustedTime = adjustTimeForMealTiming(hour: hour, minute: minute, timing: timing)

        return [NotificationSchedule.daily(hour: adjustedTime.hour, minute: adjustedTime.minute)]
    }

    private func adjustTimeForMealTiming(hour: Int, minute: Int, timing: MedicationTime?) -> (hour: Int, minute: Int) {
        let calendar = Calendar.current
        let mealDate = calendar.date(bySettingHour: hour, minute: minute, second: 0, of: Date()) ?? Date()

        let adjustedDate: Date
        switch timing {
        case .before:
            adjustedDate = mealDate.addingTimeInterval(-15 * 60) // 15 minutes before
        case .after:
            adjustedDate = mealDate.addingTimeInterval(30 * 60) // 30 minutes after
        case .none:
            adjustedDate = mealDate
        }

        let adjustedComponents = calendar.dateComponents([.hour, .minute], from: adjustedDate)
        return (hour: adjustedComponents.hour ?? hour, minute: adjustedComponents.minute ?? minute)
    }

    private func generateScheduleDates(for schedule: NotificationSchedule, from startDate: Date, to endDate: Date) -> [Date] {
        let calendar = Calendar.current
        var dates: [Date] = []
        var currentDate = startDate

        while currentDate <= endDate {
            switch schedule {
            case .daily(let hour, let minute):
                if let scheduledDate = calendar.date(bySettingHour: hour, minute: minute, second: 0, of: currentDate),
                   scheduledDate >= startDate {
                    dates.append(scheduledDate)
                }

            case .weekly(let weekday, let hour, let minute):
                let currentWeekday = calendar.component(.weekday, from: currentDate)
                if currentWeekday == weekday {
                    if let scheduledDate = calendar.date(bySettingHour: hour, minute: minute, second: 0, of: currentDate),
                       scheduledDate >= startDate {
                        dates.append(scheduledDate)
                    }
                }

            case .biweekly(let weekday, let hour, let minute):
                let currentWeekday = calendar.component(.weekday, from: currentDate)
                let weekOfYear = calendar.component(.weekOfYear, from: currentDate)
                if currentWeekday == weekday && weekOfYear % 2 == 0 {
                    if let scheduledDate = calendar.date(bySettingHour: hour, minute: minute, second: 0, of: currentDate),
                       scheduledDate >= startDate {
                        dates.append(scheduledDate)
                    }
                }

            case .monthly(let day, let hour, let minute):
                let currentDay = calendar.component(.day, from: currentDate)
                if currentDay == day {
                    if let scheduledDate = calendar.date(bySettingHour: hour, minute: minute, second: 0, of: currentDate),
                       scheduledDate >= startDate {
                        dates.append(scheduledDate)
                    }
                }
            }

            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate) ?? endDate
        }

        return dates
    }

    private func getColorForMedication(_ medication: Medication) -> Color {
        // Use a hash of the medication name to consistently assign colors
        let colors: [Color] = [.healthPrimary, .blue, .green, .orange, .purple, .pink, .indigo]
        let hash = medication.name?.hashValue ?? 0
        return colors[abs(hash) % colors.count]
    }

    // MARK: - Actions

    private func refreshNotifications() async {
        await loadUpcomingNotifications()
        notificationManager.loadPendingNotifications()
    }

    private func clearAllNotifications() async {
        await notificationManager.cancelAllMedicationNotifications()
        await loadUpcomingNotifications()
    }
}

// MARK: - Supporting Models

struct ReviewNotificationInfo {
    let medication: Medication
    let frequency: MedicationFrequency
    let scheduledDate: Date
    let timeKey: MedicationGroup.TimeKey
}

struct UpcomingNotificationGroup: Identifiable {
    let id = UUID()
    let scheduledDate: Date
    let medications: [UpcomingNotification]

    var isSingle: Bool { medications.count == 1 }
    var isGrouped: Bool { medications.count > 1 }
    var medicationCount: Int { medications.count }

    var isToday: Bool {
        Calendar.current.isDateInToday(scheduledDate)
    }

    var isTomorrow: Bool {
        Calendar.current.isDateInTomorrow(scheduledDate)
    }

    var formattedTime: String {
        scheduledDate.formatted(date: .omitted, time: .shortened)
    }

    var formattedDate: String {
        if isToday {
            return "Today"
        } else if isTomorrow {
            return "Tomorrow"
        } else {
            return scheduledDate.formatted(date: .abbreviated, time: .omitted)
        }
    }

    var timeDisplayText: String {
        if isToday {
            return "Today at \(formattedTime)"
        } else if isTomorrow {
            return "Tomorrow at \(formattedTime)"
        } else {
            return "On \(formattedDate) at \(formattedTime)"
        }
    }

    var displayTitle: String {
        if isSingle {
            return medications.first?.medicationName ?? "Medication"
        } else {
            return "\(medicationCount) Medications"
        }
    }

    var displaySubtitle: String? {
        if isSingle {
            return medications.first?.dosage
        } else {
            let names = medications.prefix(2).map { $0.medicationName }
            let remainingCount = max(0, medicationCount - 2)
            if remainingCount > 0 {
                return "\(names.joined(separator: ", ")) + \(remainingCount) more"
            } else {
                return names.joined(separator: ", ")
            }
        }
    }

    var primaryColor: Color {
        medications.first?.medicationColor ?? .healthPrimary
    }
}

struct UpcomingNotification: Identifiable {
    let id: String
    let medicationName: String
    let dosage: String?
    let instructions: String?
    let scheduledDate: Date
    let medicationColor: Color

    var name: String { medicationName }

    var isToday: Bool {
        Calendar.current.isDateInToday(scheduledDate)
    }

    var isTomorrow: Bool {
        Calendar.current.isDateInTomorrow(scheduledDate)
    }

    var formattedTime: String {
        scheduledDate.formatted(date: .omitted, time: .shortened)
    }

    var formattedDate: String {
        if isToday {
            return "Today"
        } else if isTomorrow {
            return "Tomorrow"
        } else {
            return scheduledDate.formatted(date: .abbreviated, time: .omitted)
        }
    }

    var timeDisplayText: String {
        if isToday {
            return "Today at \(formattedTime)"
        } else if isTomorrow {
            return "Tomorrow at \(formattedTime)"
        } else {
            return "On \(formattedDate) at \(formattedTime)"
        }
    }
}

#Preview {
    NavigationStack {
        NotificationReviewView()
    }
    .modelContainer(for: [Medication.self, Prescription.self], inMemory: true)
}
