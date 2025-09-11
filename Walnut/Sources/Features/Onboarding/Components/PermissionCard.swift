//
//  PermissionCard.swift
//  Walnut
//
//  Created by Mayank Gandhi on 11/09/25.
//  Copyright © 2025 m. All rights reserved.
//


import SwiftUI
import WalnutDesignSystem

// MARK: - Permission Card
struct PermissionCard: View {
    let icon: String
    let title: String
    let description: String
    let isRequired: Bool
    let status: PermissionStatus
    let action: () -> Void
    
    var body: some View {
        HealthCard {
            VStack(spacing: Spacing.medium) {
                HStack(spacing: Spacing.medium) {
                    // Icon
                    Image(systemName: icon)
                        .font(.title2)
                        .foregroundStyle(iconColor)
                        .frame(width: 30)
                    
                    // Content
                    VStack(alignment: .leading, spacing: Spacing.xs) {
                        HStack {
                            Text(title)
                                .font(.headline)
                                .foregroundStyle(.primary)
                            
                            if isRequired {
                                Text("Required")
                                    .font(.caption2.weight(.semibold))
                                    .foregroundStyle(.white)
                                    .padding(.horizontal, Spacing.small)
                                    .padding(.vertical, 2)
                                    .background(Color.healthError, in: Capsule())
                            }
                            
                            Spacer()
                        }
                        
                        Text(description)
                            .font(.body)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.leading)
                    }
                    
                    Spacer()
                }
                
                // Action button
                if status == .notDetermined {
                    DSButton(
                        "Allow \(title)",
                        style: .primary,
                        icon: "checkmark"
                    ) {
                        action()
                    }
                } else {
                    HStack {
                        Image(systemName: statusIcon)
                            .foregroundStyle(statusColor)
                        
                        Text(statusText)
                            .font(.body.weight(.medium))
                            .foregroundStyle(statusColor)
                        
                        Spacer()
                    }
                }
            }
        }
    }
    
    private var iconColor: Color {
        switch status {
        case .granted: return .healthSuccess
        case .denied: return .healthError
        case .notDetermined: return .healthPrimary
        }
    }
    
    private var statusIcon: String {
        switch status {
        case .granted: return "checkmark.circle.fill"
        case .denied: return "xmark.circle.fill"
        case .notDetermined: return "questionmark.circle"
        }
    }
    
    private var statusColor: Color {
        switch status {
        case .granted: return .healthSuccess
        case .denied: return .healthError
        case .notDetermined: return .secondary
        }
    }
    
    private var statusText: String {
        switch status {
        case .granted: return "Permission Granted"
        case .denied: return "Permission Denied"
        case .notDetermined: return "Permission Not Set"
        }
    }
}
