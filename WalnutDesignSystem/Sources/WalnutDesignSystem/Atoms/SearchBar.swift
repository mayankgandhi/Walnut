//
//  SearchBar.swift
//  WalnutDesignSystem
//
//  Created by Mayank Gandhi on 15/09/25.
//  Copyright © 2025 m. All rights reserved.
//

import SwiftUI

/// A reusable search bar component consistent with the design system
public struct SearchBar: View {
    private let placeholder: String
    private let onTextChange: (String) -> Void
    private let onClear: () -> Void

    @Binding private var searchText: String
    @FocusState private var isFocused: Bool

    public init(
        searchText: Binding<String>,
        placeholder: String = "Search...",
        onTextChange: @escaping (String) -> Void = { _ in },
        onClear: @escaping () -> Void = { }
    ) {
        self._searchText = searchText
        self.placeholder = placeholder
        self.onTextChange = onTextChange
        self.onClear = onClear
    }

    public var body: some View {
        HStack(spacing: Spacing.medium) {
            HStack(spacing: Spacing.small) {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(.secondary)
                    .font(.system(size: 16, weight: .medium))

                TextField(placeholder, text: $searchText)
                    .font(.system(.body, design: .rounded))
                    .textFieldStyle(PlainTextFieldStyle())
                    .focused($isFocused)
                    .onChange(of: searchText) { _, newValue in
                        onTextChange(newValue)
                    }

                if !searchText.isEmpty {
                    Button(action: {
                        searchText = ""
                        onClear()
                        isFocused = false
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.secondary)
                            .font(.system(size: 16, weight: .medium))
                    }
                    .transition(.opacity.combined(with: .scale))
                }
            }
            .padding(.horizontal, Spacing.medium)
            .padding(.vertical, Spacing.small + 2)
            .background(backgroundView)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(strokeColor, lineWidth: 1)
            )
            .shadow(
                color: Color.black.opacity(0.05),
                radius: 2,
                x: 0,
                y: 1
            )
        }
        .padding(.horizontal, Spacing.medium)
        .animation(.easeInOut(duration: 0.2), value: searchText.isEmpty)
    }

    private var backgroundView: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(isFocused ? Color(.systemBackground) : Color(.systemGray6))
    }

    private var strokeColor: Color {
        isFocused ? Color.healthPrimary.opacity(0.3) : Color(.systemGray5)
    }
}

// MARK: - Convenience Initializers

public extension SearchBar {
    /// Initializer with simple text binding and no callbacks
    init(
        searchText: Binding<String>,
        placeholder: String = "Search..."
    ) {
        self.init(
            searchText: searchText,
            placeholder: placeholder,
            onTextChange: { _ in },
            onClear: { }
        )
    }
}

// MARK: - Previews

#Preview("Search Bar States") {
    VStack(spacing: Spacing.large) {
        Text("Search Bar Examples")
            .font(.title2)
            .fontWeight(.bold)

        VStack(spacing: Spacing.medium) {
            // Empty state
            SearchBar(
                searchText: .constant(""),
                placeholder: "Search cases..."
            )

            // With text
            SearchBar(
                searchText: .constant("Knee injury"),
                placeholder: "Search cases..."
            )

            // Different placeholder
            SearchBar(
                searchText: .constant(""),
                placeholder: "Search biomarkers..."
            )

            // With callbacks
            SearchBar(
                searchText: .constant("Blood test"),
                placeholder: "Search...",
                onTextChange: { text in
                    print("Text changed to: \(text)")
                },
                onClear: {
                    print("Search cleared")
                }
            )
        }

        Spacer()
    }
    .padding()
    .background(Color(.systemGroupedBackground))
}