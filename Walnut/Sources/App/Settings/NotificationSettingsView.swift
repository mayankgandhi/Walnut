//
//  NotificationSettingsView.swift
//  Walnut
//
//  Created by Mayank Gandhi on 05/09/25.
//  Copyright © 2025 m. All rights reserved.
//

import SwiftUI
import WalnutDesignSystem
import UserNotifications
import UIKit

struct NotificationSettingsView: View {
    @State private var notificationsPermissionGranted = false
    @State private var alarmPermissionGranted = false
    @State private var preferredNotificationType: NotificationType = .pushNotifications
    
    @State private var mealTimings: [MealTime: Date] = [
        .breakfast: Date().startOfDay.addingTimeInterval(8 * 3600), // 8 AM
        .lunch: Date().startOfDay.addingTimeInterval(12 * 3600), // 12 PM
        .dinner: Date().startOfDay.addingTimeInterval(19 * 3600), // 7 PM
        .bedtime: Date().startOfDay.addingTimeInterval(22 * 3600) // 10 PM
    ]
    
    @Environment(\.dismiss) private var dismiss
    
    enum NotificationType: String, CaseIterable {
        case pushNotifications = "Push Notifications"
        case alarms = "Alarms"
        
        var icon: String {
            switch self {
            case .pushNotifications:
                return "bell.fill"
            case .alarms:
                return "alarm.fill"
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Spacing.large) {
                    // Header
                    headerSection
                    
                    // Permissions Status
                    permissionsSection
                    
                    // Notification Type Preference
                    if notificationsPermissionGranted || alarmPermissionGranted {
                        notificationTypeSection
                    }
                    
                    // Meal Timing Settings
                    if notificationsPermissionGranted || alarmPermissionGranted {
                        mealTimingsSection
                    }
                    
                    // Information Section
                    informationSection
                    
                    Spacer()
                }
                .padding(.horizontal, Spacing.medium)
                .padding(.top, Spacing.medium)
            }
            .navigationTitle("Notifications")
            .navigationBarTitleDisplayMode(.large)
            .navigationBarBackButtonHidden(false)
            .onAppear {
                checkPermissions()
            }
        }
    }
    
    // MARK: - View Components
    
    private var headerSection: some View {
        VStack(spacing: Spacing.medium) {
            Image(systemName: "bell.badge")
                .font(.system(size: 64, weight: .light))
                .foregroundStyle(Color.healthPrimary)
            
            VStack(spacing: Spacing.xs) {
                Text("Medication Reminders")
                    .font(.title2.weight(.semibold))
                    .foregroundStyle(.primary)
                
                Text("Never miss your medication with personalized reminders")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(.vertical, Spacing.large)
    }
    
    private var permissionsSection: some View {
        VStack(spacing: Spacing.medium) {
            Text("Permissions")
                .font(.headline)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            VStack(spacing: Spacing.medium) {
                // Notification Permission
                HealthCard {
                    VStack(spacing: Spacing.medium) {
                        HStack {
                            VStack(alignment: .leading, spacing: Spacing.xs) {
                                Text("Push Notifications")
                                    .font(.headline.weight(.semibold))
                                    .foregroundStyle(.primary)
                                
                                Text("Receive gentle notification reminders")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                            
                            Spacer()
                            
                            HStack(spacing: Spacing.small) {
                                if notificationsPermissionGranted {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundStyle(Color.healthSuccess)
                                } else {
                                    Button("Enable") {
                                        requestNotificationPermission()
                                    }
                                    .buttonStyle(.bordered)
                                    .controlSize(.small)
                                    .tint(Color.healthPrimary)
                                }
                            }
                        }
                    }
                }
                
                // Alarm Permission
                HealthCard {
                    VStack(spacing: Spacing.medium) {
                        HStack {
                            VStack(alignment: .leading, spacing: Spacing.xs) {
                                Text("Critical Alerts")
                                    .font(.headline.weight(.semibold))
                                    .foregroundStyle(.primary)
                                
                                Text("Persistent alarm-style reminders that bypass Do Not Disturb")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                            
                            Spacer()
                            
                            HStack(spacing: Spacing.small) {
                                if alarmPermissionGranted {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundStyle(Color.healthSuccess)
                                } else {
                                    Button("Enable") {
                                        requestAlarmPermission()
                                    }
                                    .buttonStyle(.bordered)
                                    .controlSize(.small)
                                    .tint(Color.healthWarning)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    private var notificationTypeSection: some View {
        VStack(spacing: Spacing.medium) {
            Text("Reminder Style")
                .font(.headline)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            HealthCard {
                VStack(spacing: Spacing.medium) {
                    HStack {
                        Text("Preferred Notification Type")
                            .font(.headline.weight(.semibold))
                            .foregroundStyle(.primary)
                        
                        Spacer()
                    }
                    
                    VStack(spacing: Spacing.small) {
                        ForEach(NotificationType.allCases, id: \.self) { type in
                            notificationTypeOption(type)
                        }
                    }
                }
            }
        }
    }
    
    private func notificationTypeOption(_ type: NotificationType) -> some View {
        Button {
            preferredNotificationType = type
        } label: {
            HStack(spacing: Spacing.medium) {
                Image(systemName: type.icon)
                    .font(.title3)
                    .foregroundStyle(preferredNotificationType == type ? Color.healthPrimary : .secondary)
                    .frame(width: 24, height: 24)
                
                VStack(alignment: .leading, spacing: Spacing.xs) {
                    Text(type.rawValue)
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(preferredNotificationType == type ? .primary : .secondary)
                    
                    Text(type == .pushNotifications ? "Gentle banner notifications" : "Persistent alarms that bypass silence mode")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }
                
                Spacer()
                
                if preferredNotificationType == type {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(Color.healthPrimary)
                }
            }
            .padding(Spacing.small)
            .background(preferredNotificationType == type ? Color.healthPrimary.opacity(0.1) : Color.clear)
            .cornerRadius(8)
        }
        .buttonStyle(.plain)
    }
    
    private var mealTimingsSection: some View {
        VStack(spacing: Spacing.medium) {
            HStack {
                Text("Meal Times")
                    .font(.headline)
                    .foregroundStyle(.secondary)
                
                Spacer()
            }
            
            VStack(spacing: Spacing.small) {
                ForEach(MealTime.allCases, id: \.self) { mealTime in
                    mealTimingCard(for: mealTime)
                }
            }
            
            // Timing Information Card
            HealthCard {
                VStack(alignment: .leading, spacing: Spacing.small) {
                    HStack {
                        Image(systemName: "info.circle.fill")
                            .font(.title3)
                            .foregroundStyle(.blue)
                        
                        Text("Reminder Timing")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.primary)
                    }
                    
                    VStack(alignment: .leading, spacing: Spacing.xs) {
                        HStack(spacing: Spacing.small) {
                            Circle()
                                .fill(.blue.opacity(0.3))
                                .frame(width: 6, height: 6)
                            
                            Text("**Before meal:** 15 minutes prior to meal time")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        
                        HStack(spacing: Spacing.small) {
                            Circle()
                                .fill(.blue.opacity(0.3))
                                .frame(width: 6, height: 6)
                            
                            Text("**After meal:** 30 minutes after meal time")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
        }
    }
    
    private func mealTimingCard(for mealTime: MealTime) -> some View {
        HealthCard {
            HStack(spacing: Spacing.medium) {
                Image(systemName: mealTime.icon)
                    .font(.title2)
                    .foregroundStyle(mealTime.color)
                    .frame(width: 32, height: 32)
                
                VStack(alignment: .leading, spacing: Spacing.xs) {
                    Text(mealTime.rawValue.capitalized)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.primary)
                    
                    Text("Medication reminder time")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                DatePicker(
                    "",
                    selection: Binding(
                        get: { mealTimings[mealTime] ?? Date() },
                        set: { mealTimings[mealTime] = $0 }
                    ),
                    displayedComponents: .hourAndMinute
                )
                .labelsHidden()
                .scaleEffect(0.9)
            }
        }
    }
    
    private var informationSection: some View {
        VStack(alignment: .leading, spacing: Spacing.medium) {
            Text("How It Works")
                .font(.headline)
                .foregroundStyle(.secondary)
            
            VStack(alignment: .leading, spacing: Spacing.small) {
                informationItem(
                    icon: "clock.fill",
                    title: "Smart Scheduling",
                    description: "Reminders are automatically scheduled based on your meal times and medication timing preferences"
                )
                
                informationItem(
                    icon: "bell.fill",
                    title: "Gentle Reminders",
                    description: "Push notifications provide subtle reminders that won't disrupt your day"
                )
                
                informationItem(
                    icon: "alarm.fill",
                    title: "Critical Alerts",
                    description: "Alarms ensure you never miss important medications, even in Do Not Disturb mode"
                )
                
                informationItem(
                    icon: "gear.badge",
                    title: "Customizable",
                    description: "Adjust meal times and notification preferences to match your schedule"
                )
            }
            
            if !notificationsPermissionGranted && !alarmPermissionGranted {
                VStack(alignment: .leading, spacing: Spacing.small) {
                    Text("To enable medication reminders:")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(.primary)
                    
                    VStack(alignment: .leading, spacing: Spacing.xs) {
                        Text("1. Grant notification permissions above")
                        Text("2. Choose your preferred reminder style")
                        Text("3. Set your meal times")
                        Text("4. Your medications will remind you automatically")
                    }
                    .font(.caption)
                    .foregroundStyle(.secondary)
                }
                .padding(Spacing.medium)
                .background(Color.healthPrimary.opacity(0.1))
                .cornerRadius(12)
            }
        }
    }
    
    @ViewBuilder
    private func informationItem(icon: String, title: String, description: String) -> some View {
        HStack(spacing: Spacing.medium) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(Color.healthPrimary)
                .frame(width: 24, height: 24)
            
            VStack(alignment: .leading, spacing: Spacing.xs) {
                Text(title)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.primary)
                
                Text(description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
        }
    }
    
    // MARK: - Permission Handling
    
    private func checkPermissions() {
        // Check notification permissions
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                notificationsPermissionGranted = settings.authorizationStatus == .authorized
            }
        }
        
        // For alarms, we'll assume they're available if notifications are granted for now
        // In a real implementation, you'd check for critical alert permissions
        alarmPermissionGranted = notificationsPermissionGranted
    }
    
    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            DispatchQueue.main.async {
                notificationsPermissionGranted = granted
                // For demonstration, also enable alarm permissions
                alarmPermissionGranted = granted
            }
        }
    }
    
    private func requestAlarmPermission() {
        // In a real implementation, you'd request critical alert permissions here
        // For now, redirect to notification settings
        if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(settingsURL)
        }
    }
}

// MARK: - Date Extensions

extension Date {
    var startOfDay: Date {
        Calendar.current.startOfDay(for: self)
    }
}

#Preview("Notification Settings") {
    NavigationStack {
        NotificationSettingsView()
    }
}

#Preview("Notification Settings - Permissions Granted") {
    NavigationStack {
        NotificationSettingsView()
    }
}
