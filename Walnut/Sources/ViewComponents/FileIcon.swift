//
//  FileIcon.swift
//  WalnutDesignSystem
//
//  Created by Mayank Gandhi on 21/08/25.
//  Copyright © 2025 m. All rights reserved.
//

import SwiftUI

public struct FileIcon: View {
    // Required properties
    let filename: String
    let subtitle: String
    let documentType: DocumentType

    // Optional properties with defaults
    let iconColor: Color?
    let backgroundColor: Color?
    let size: FileIconSize
    
    public init(
        filename: String,
        subtitle: String,
        documentType: DocumentType,
        iconColor: Color? = nil,
        backgroundColor: Color? = nil,
        size: FileIconSize = .medium
    ) {
        self.filename = filename
        self.subtitle = subtitle
        self.documentType = documentType
        self.iconColor = iconColor
        self.backgroundColor = backgroundColor
        self.size = size
    }
    
    public var body: some View {
        HStack(spacing: 12) {
            // Icon container
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(effectiveBackgroundColor.opacity(0.1))
                    .frame(width: iconContainerSize, height: iconContainerSize)
                
                Image(systemName: documentType.typeIcon)
                    .font(.system(size: iconSize, weight: .semibold))
                    .foregroundStyle(effectiveIconColor)
            }
            
            // File information
            VStack(alignment: .leading, spacing: 2) {
                Text(filename)
                    .font(.headline)
                    .foregroundColor(.primary)
                    .lineLimit(1)
                    .truncationMode(.middle)
                
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                    .truncationMode(.tail)
            }
            
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemGray6))
                .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
        )
        .contentShape(Rectangle())
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(filename), \(documentType.accessibilityDescription)")
        .accessibilityHint("Double tap to open document")
        .accessibilityAddTraits(.isButton)
    }
    
    // MARK: - Computed Properties
    
    private var effectiveIconColor: Color {
        iconColor ?? documentType.backgroundColor
    }
    
    private var effectiveBackgroundColor: Color {
        backgroundColor ?? documentType.backgroundColor
    }
    
    private var iconContainerSize: CGFloat {
        switch size {
        case .small: return 40
        case .medium: return 48
        case .large: return 56
        }
    }
    
    private var iconSize: CGFloat {
        switch size {
        case .small: return 20
        case .medium: return 24
        case .large: return 28
        }
    }
}

// MARK: - FileIcon Size Enum
public enum FileIconSize {
    case small
    case medium
    case large
    
    var iconSize: CGFloat {
        switch self {
        case .small: return 60
        case .medium: return 80
        case .large: return 100
        }
    }
}



#Preview {
    ScrollView {
        VStack(spacing: 16) {
            // Basic usage examples
            VStack(alignment: .leading, spacing: 8) {
                Text("Basic Examples")
                    .font(.headline)
                    .padding(.horizontal)
                
                FileIcon(
                    filename: "Blood Test Results - Complete Panel",
                    subtitle: "Jan 15, 2024 • Quest Diagnostics",
                    documentType: .labResult
                )
                
                FileIcon(
                    filename: "Amoxicillin Prescription",
                    subtitle: "Dr. Sarah Smith • 2 days ago",
                    documentType: .prescription
                )
                
                FileIcon(
                    filename: "Chest X-Ray Report",
                    subtitle: "Dec 20, 2023 • 2.3 MB",
                    documentType: .imaging
                )
            }
            
            // Size variations
            VStack(alignment: .leading, spacing: 8) {
                Text("Size Variations")
                    .font(.headline)
                    .padding(.horizontal)
                
                FileIcon(
                    filename: "MRI Brain Scan",
                    subtitle: "Large size example",
                    documentType: .imaging,
                    size: .large
                )
                
                FileIcon(
                    filename: "Consultation Notes",
                    subtitle: "Medium size (default)",
                    documentType: .consultation,
                    size: .medium
                )
                
                FileIcon(
                    filename: "Insurance Card",
                    subtitle: "Small size example",
                    documentType: .insurance,
                    size: .small
                )
            }
        }
        .padding()
    }
}

// MARK: - Utility Extensions


public extension Int64 {
    /// Formats file size in bytes to human-readable string
    var formattedFileSize: String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useKB, .useMB, .useGB]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: self)
    }
}

