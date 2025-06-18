//
//  FormSection.swift
//  Walnut
//
//  Created by Mayank Gandhi on 07/06/25.
//  Copyright © 2025 m. All rights reserved.
//

import SwiftUI

struct FormSection<Content: View>: View {
    let title: String
    let icon: String
    let content: Content
    
    init(title: String, icon: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.icon = icon
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .foregroundColor(.healthBlue)
                    .font(.system(size: 16, weight: .medium))
                
                Text(title)
                    .font(.headline)
                    .foregroundColor(.textPrimary)
                    .fontWeight(.semibold)
            }
            
            content
        }
        .padding(20)
        .background(Color.walnutSecondaryBackground)
        .cornerRadius(16)
        .shadow(color: .shadowColor.opacity(0.08), radius: 8, x: 0, y: 2)
    }
}
