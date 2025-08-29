//
//  OptionalView.swift
//  Walnut
//
//  Created by Mayank Gandhi on 29/08/25.
//  Copyright © 2025 m. All rights reserved.
//


import SwiftUI

struct OptionalView<T, Content: View>: View {
    let optional: T?
    let content: (T) -> Content
    
    init(_ optional: T?, @ViewBuilder content: @escaping (T) -> Content) {
        self.optional = optional
        self.content = content
    }
    
    var body: some View {
        if let value = optional {
            content(value)
        }
    }
}
