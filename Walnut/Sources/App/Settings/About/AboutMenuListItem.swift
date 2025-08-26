//
//  AboutMenuListItem.swift
//  Walnut
//
//  Created by Mayank Gandhi on 26/08/25.
//  Copyright © 2025 m. All rights reserved.
//

import SwiftUI
import WalnutDesignSystem

struct AboutMenuListItem: View {
    
    @State private var showAboutSheet = false
    
    var body: some View {
        
        MenuListItem(
            icon: "info.circle.fill",
            title: "About",
            subtitle: "App version and info",
            iconColor: .gray
        ) {
            showAboutSheet = true
        }
        .sheet(isPresented: $showAboutSheet) {
            AboutSheet()
                .presentationDetents([.medium])
                .presentationCornerRadius(Spacing.large)
                .presentationDragIndicator(.visible)
        }
    }
}
