//
//  DSBottomSheet.swift
//  WalnutDesignSystem
//
//  Created by Mayank Gandhi on 16/08/25.
//  Copyright © 2025 m. All rights reserved.
//

import SwiftUI

/// A reusable bottom sheet component that provides a consistent presentation style across the app
public struct DSBottomSheet<Content: View>: View {
    
    // MARK: - Properties
    
    let title: String?
    let subtitle: String?
    let onDismiss: () -> Void
    let content: () -> Content
    
    // MARK: - Initializer
    
    /// Creates a bottom sheet with title, optional subtitle, and custom content
    /// - Parameters:
    ///   - title: The main title displayed at the top
    ///   - subtitle: Optional subtitle text below the title
    ///   - onDismiss: Action to perform when dismiss button is tapped
    ///   - content: The main content of the bottom sheet
    public init(
        title: String? = nil,
        subtitle: String? = nil,
        onDismiss: @escaping () -> Void,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.title = title
        self.subtitle = subtitle
        self.onDismiss = onDismiss
        self.content = content
    }
    
    // MARK: - Body
    
    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Spacing.medium) {
                    if let title = title {
                        // Header section with title and subtitle
                        VStack(alignment: .leading, spacing: Spacing.xs) {
                            Text(title)
                                .font(.title2.weight(.bold))
                                .foregroundStyle(.primary)
                                .multilineTextAlignment(.leading)
                            
                            if let subtitle = subtitle {
                                Text(subtitle)
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                                    .multilineTextAlignment(.leading)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    
                    content()
                }
                .padding(.horizontal, Spacing.medium)
                .padding(.bottom, Spacing.medium)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Dismiss") {
                        onDismiss()
                    }
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(Color.healthPrimary)
                }
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.hidden) // We provide our own
        .presentationCornerRadius(Spacing.large)
        .interactiveDismissDisabled(false)
    }
}

// MARK: - Convenience Modifiers

public extension View {
    /// Presents a bottom sheet with the given configuration
    /// - Parameters:
    ///   - isPresented: Binding that controls sheet presentation
    ///   - title: The sheet title
    ///   - subtitle: Optional subtitle
    ///   - content: The sheet content
    func bottomSheet<Content: View>(
        isPresented: Binding<Bool>,
        title: String,
        subtitle: String? = nil,
        @ViewBuilder content: @escaping () -> Content
    ) -> some View {
        self.sheet(isPresented: isPresented) {
            DSBottomSheet(
                title: title,
                subtitle: subtitle,
                onDismiss: { isPresented.wrappedValue = false },
                content: content
            )
        }
    }
    
    /// Presents a bottom sheet with an item-based presentation
    /// - Parameters:
    ///   - item: Binding to an optional item that controls presentation
    ///   - title: The sheet title
    ///   - subtitle: Optional subtitle
    ///   - content: The sheet content that receives the unwrapped item
    func bottomSheet<Item: Identifiable, Content: View>(
        item: Binding<Item?>,
        title: String,
        subtitle: String? = nil,
        @ViewBuilder content: @escaping (Item) -> Content
    ) -> some View {
        self.sheet(item: item) { unwrappedItem in
            DSBottomSheet(
                title: title,
                subtitle: subtitle,
                onDismiss: { item.wrappedValue = nil }
            ) {
                content(unwrappedItem)
            }
        }
    }
}

// MARK: - Preview

#Preview("Basic Bottom Sheet") {
    NavigationStack {
        VStack {
            Text("Main Content")
                .font(.title)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(UIColor.systemGroupedBackground))
        .navigationTitle("Demo")
    }
    .bottomSheet(
        isPresented: .constant(true),
        title: "Settings",
        subtitle: "Configure your preferences"
    ) {
        VStack(spacing: Spacing.medium) {
            HealthCard {
                VStack(alignment: .leading, spacing: Spacing.small) {
                    Text("Notification Settings")
                        .font(.headline.weight(.semibold))
                        .foregroundStyle(.primary)
                    
                    Text("Choose how you want to be notified about important updates.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            
            HealthCard {
                VStack(alignment: .leading, spacing: Spacing.small) {
                    Text("Data Privacy")
                        .font(.headline.weight(.semibold))
                        .foregroundStyle(.primary)
                    
                    Text("Your medical data is encrypted and stored securely.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            
            HealthCard {
                VStack(alignment: .leading, spacing: Spacing.small) {
                    Text("Backup & Sync")
                        .font(.headline.weight(.semibold))
                        .foregroundStyle(.primary)
                    
                    Text("Keep your data synchronized across all your devices.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }
}

#Preview("Simple Bottom Sheet") {
    NavigationStack {
        VStack {
            Text("Main Content")
                .font(.title)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(UIColor.systemGroupedBackground))
        .navigationTitle("Demo")
    }
    .bottomSheet(
        isPresented: .constant(true),
        title: "Quick Actions"
    ) {
        VStack(spacing: Spacing.medium) {
            DSButton("Schedule Appointment", style: .primary, icon: "calendar.badge.plus") {
                
            }
        }
    }
}
