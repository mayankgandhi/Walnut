//
//  ProgressIndicatorView.swift
//  Walnut
//
//  Created by Mayank Gandhi on 11/09/25.
//  Copyright © 2025 m. All rights reserved.
//

import SwiftUI
import WalnutDesignSystem

// MARK: - Progress Indicator
struct ProgressIndicatorView: View {
    let progress: Double
    
    var body: some View {
        VStack(spacing: Spacing.small) {
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(.quaternary)
                        .frame(height: 4)
                        .clipShape(Capsule())
                    
                    Rectangle()
                        .fill(Color.healthPrimary)
                        .frame(width: geometry.size.width * progress, height: 4)
                        .clipShape(Capsule())
                        .animation(.easeInOut(duration: 0.3), value: progress)
                }
            }
            .frame(height: 4)
            
            HStack {
                Text("Step \(Int(progress * 6)) of 6")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                Spacer()
                
                Text("\(Int(progress * 100))% Complete")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
}
