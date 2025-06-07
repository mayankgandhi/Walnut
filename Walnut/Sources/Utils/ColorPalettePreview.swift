//
//  ColorPalettePreview.swift
//  Walnut
//
//  Created by Mayank Gandhi on 07/06/25.
//


import SwiftUI

struct ColorPalettePreview: View {
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(spacing: 24) {
                    // Brand Colors Section
                    ColorSection(
                        title: "Brand Colors",
                        colors: [
                            ("Walnut Brown", .walnutBrown),
                            ("Walnut Background", .walnutBackground),
                            ("Walnut Secondary Background", .walnutSecondaryBackground)
                        ]
                    )
                    
                    // Health Colors Section
                    ColorSection(
                        title: "Health Colors",
                        colors: [
                            ("Health Green", .healthGreen),
                            ("Health Blue", .healthBlue),
                            ("Health Coral", .healthCoral)
                        ]
                    )
                    
                    // Lab Result Colors Section
                    ColorSection(
                        title: "Lab Result Colors",
                        colors: [
                            ("Lab Normal", .labNormal),
                            ("Lab Warning", .labWarning),
                            ("Lab Critical", .labCritical)
                        ]
                    )
                    
                    // Text Colors Section
                    ColorSection(
                        title: "Text Colors",
                        colors: [
                            ("Text Primary", .textPrimary),
                            ("Text Secondary", .textSecondary),
                            ("Text Tertiary", .textTertiary)
                        ]
                    )
                    
                    // UI Elements Section
                    ColorSection(
                        title: "UI Elements",
                        colors: [
                            ("Border Color", .borderColor),
                            ("Shadow Color", .shadowColor)
                        ]
                    )
                    
                    // Charts Section
                    ColorSection(
                        title: "Charts",
                        colors: [
                            ("Chart Blue", .chartBlue),
                            ("Chart Purple", .chartPurple),
                            ("Chart Orange", .chartOrange)
                        ]
                    )
                }
                .padding()
            }
            .navigationTitle("Color Palette")
            .background(Color(.systemGroupedBackground))
        }
    }
}

struct ColorSection: View {
    let title: String
    let colors: [(String, Color)]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
                .foregroundColor(.primary)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                ForEach(colors, id: \.0) { colorName, color in
                    ColorCard(name: colorName, color: color)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }
}

struct ColorCard: View {
    let name: String
    let color: Color
    @State private var showingCopiedAlert = false
    
    var body: some View {
        VStack(spacing: 8) {
            RoundedRectangle(cornerRadius: 8)
                .fill(color)
                .frame(height: 60)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color(.systemGray4), lineWidth: 1)
                )
            
            Text(name)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
        }
        .onTapGesture {
            copyColorName()
        }
        .alert("Copied!", isPresented: $showingCopiedAlert) {
            Button("OK") { }
        } message: {
            Text("\(name) copied to clipboard")
        }
    }
    
    private func copyColorName() {
        UIPasteboard.general.string = "Color.\(name.replacingOccurrences(of: " ", with: "").lowercased())"
        showingCopiedAlert = true
    }
}

// MARK: - Preview
struct ColorPalettePreview_Previews: PreviewProvider {
    static var previews: some View {
        ColorPalettePreview()
    }
}