//
//  HealthCard.swift
//  WalnutDesignSystem
//
//  Created by Mayank Gandhi on 06/08/25.
//  Copyright © 2025 m. All rights reserved.
//

import SwiftUI

/// Simple healthcare card with native materials
public struct HealthCard<Content: View>: View {
    private let content: Content
    private let padding: CGFloat
    
    public init(
        @ViewBuilder content: () -> Content
    ) {
        self.content = content()
        self.padding = Spacing.medium
    }
    
    public var body: some View {
        content
            .padding(padding)
            .subtleCardStyle()
    }
}


// MARK: - Preview

#Preview("Health Cards") {
    ScrollView {
        VStack(spacing: Spacing.large) {
            HealthCard {
                VStack(alignment: .leading, spacing: Spacing.small) {
                    HStack {
                        PatientAvatar(name: "WW")
                        
                        VStack(alignment: .leading) {
                            Text("John Doe")
                                .font(.headline)
                            Text("35 years old")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        
                        Spacer()
                        
                    }
                    
                    Divider()
                    
                  
                }
            }
            
            
        }
        .padding(Spacing.large)
    }
}
