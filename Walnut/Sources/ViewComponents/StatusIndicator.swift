//
//  StatusIndicator.swift
//  Walnut-Playground
//
//  Created by Mayank Gandhi on 02/07/25.
//  Copyright © 2025 m. All rights reserved.
//

import SwiftUI

// Status Indicator Component
struct StatusIndicator: View {
    let isActive: Bool
    
    var body: some View {
        VStack(spacing: 4) {
            Circle()
                .fill(isActive ? Color.green : Color.gray)
                .frame(width: 12, height: 12)
                .overlay(
                    Circle()
                        .stroke(isActive ? Color.green.opacity(0.3) : Color.gray.opacity(0.3), lineWidth: 3)
                )
                .scaleEffect(isActive ? 1.0 : 0.8)
                .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: isActive)
            
            Text(isActive ? "Active" : "Closed")
                .font(.caption2)
                .fontWeight(.medium)
                .foregroundColor(isActive ? .green : .gray)
        }
    }
}
