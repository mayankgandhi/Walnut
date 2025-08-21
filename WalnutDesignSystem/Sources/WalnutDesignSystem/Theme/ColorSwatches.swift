//
//  ColorSwatches.swift
//  WalnutDesignSystem
//
//  Created by Mayank Gandhi on 21/08/25.
//  Copyright © 2025 m. All rights reserved.
//

import SwiftUI

struct ColorSwatches: View {
    
    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.large) {
            // Colors
            VStack(alignment: .leading, spacing: Spacing.medium) {
                Text("Healthcare Colors")
                    .font(.headline.weight(.semibold))
                
                HStack(spacing: Spacing.small) {
                    ColorSwatch("Primary", color: .healthPrimary)
                    ColorSwatch("Success", color: .healthSuccess)
                    ColorSwatch("Warning", color: .healthWarning)
                    ColorSwatch("Error", color: .healthError)
                }
            }
            
            // Typography
            VStack(alignment: .leading, spacing: Spacing.medium) {
                
                Text("Typography")
                    .font(.headline.weight(.semibold))
                
                VStack(alignment: .leading, spacing: Spacing.small) {
                    Text("Large Title")
                        .font(.largeTitle.weight(.bold))
                    Text("Title")
                        .font(.title.weight(.semibold))
                    Text("Headline")
                        .font(.headline.weight(.medium))
                    Text("Body Text")
                        .font(.body)
                    Text("Caption")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            
            // Buttons
            VStack(alignment: .leading, spacing: Spacing.medium) {
                Text("Buttons")
                    .font(.headline.weight(.semibold))
                
                HStack(spacing: Spacing.medium) {
                    DSButton("Primary", style: .primary) {}
                    DSButton("Secondary", style: .secondary) {}
                }
            }
            
            Spacer()
        }
        .padding()
        .navigationTitle("Design Tokens")
    }
    
}

#Preview {
    ColorSwatches()
}
