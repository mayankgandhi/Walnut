//
//  WalnutTextEditor.swift
//  Walnut
//
//  Created by Mayank Gandhi on 07/06/25.
//  Copyright © 2025 m. All rights reserved.
//

import SwiftUI

struct WalnutTextEditor: View {
    @Binding var text: String
    let placeholder: String
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.walnutSecondaryBackground)
                .stroke(Color.borderColor, lineWidth: 1)
                .frame(height: 100)
            
            if text.isEmpty {
                Text(placeholder)
                    .foregroundColor(.textSecondary)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
            }
            
            TextEditor(text: $text)
                .scrollContentBackground(.hidden)
                .background(Color.clear)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
        }
    }
}
