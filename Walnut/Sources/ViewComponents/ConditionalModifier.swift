//
//  ConditionalModifier.swift
//  Walnut
//
//  Created by Mayank Gandhi on 04/09/25.
//  Copyright © 2025 m. All rights reserved.
//


import SwiftUI

// Custom view modifier that applies another modifier conditionally
struct ConditionalModifier<ModifiedContent: View>: ViewModifier {
    let condition: Bool
    let modifier: (AnyView) -> ModifiedContent
    
    func body(content: Content) -> some View {
        if condition {
            modifier(AnyView(content))
        } else {
            content
        }
    }
}

// Extension to make it easier to use
extension View {
    func conditionalModifier<ModifiedContent: View>(
        when condition: Bool,
        apply modifier: @escaping (AnyView) -> ModifiedContent
    ) -> some View {
        self.modifier(ConditionalModifier(condition: condition, modifier: modifier))
    }
}