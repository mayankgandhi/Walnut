//
//  EnhancedUnparsedDocumentListItem.swift
//  Walnut
//
//  Created by Mayank Gandhi on 21/08/25.
//  Copyright © 2025 m. All rights reserved.
//

import SwiftUI
import WalnutDesignSystem

struct EnhancedUnparsedDocumentListItem: View {
    let document: Document
    let isRetrying: Bool
    let onRetry: () -> Void
    @State private var isPressed = false
    
    var body: some View {
        HStack(spacing: Spacing.medium) {
            Circle()
                .fill(Color.orange.opacity(0.15))
                .frame(width: 40, height: 40)
                .overlay {
                    Image(systemName: "doc.badge.ellipsis")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(.orange)
                }
            
            VStack(alignment: .leading, spacing: Spacing.xs) {
                Text(document.fileName)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.primary)
                    .lineLimit(2)
                
                HStack {
                    Text(document.uploadDate, style: .date)
                        .font(.caption.weight(.medium))
                        .foregroundStyle(.secondary)
                    
                    Text("•")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                    
                    Text(ByteCountFormatter.string(fromByteCount: document.fileSize, countStyle: .file))
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }
            }
            
            Spacer()
            
            Button(action: onRetry) {
                HStack(spacing: 4) {
                    if isRetrying {
                        ProgressView()
                            .controlSize(.mini)
                    } else {
                        Image(systemName: "arrow.clockwise.circle.fill")
                            .font(.title3)
                    }
                }
                .foregroundStyle(.orange)
            }
            .disabled(isRetrying)
        }
        .padding(Spacing.small)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(UIColor.secondarySystemGroupedBackground))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.orange.opacity(0.1), lineWidth: 0.5)
                )
        )
        .scaleEffect(isPressed ? 0.98 : 1.0)
        .animation(.easeInOut(duration: 0.1), value: isPressed)
    }
}
