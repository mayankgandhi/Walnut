//
//  CombinedPulseView.swift
//  Walnut
//
//  Created by Mayank Gandhi on 04/09/25.
//  Copyright © 2025 m. All rights reserved.
//

import SwiftUI

struct CombinedPulseView: View {
    let iconImage: String
    @State private var isPulsating = false
    
    var body: some View {
        Image(iconImage)
            .resizable()
            .frame(width: 36, height: 36)
            .scaleEffect(isPulsating ? 1.0 : 0.9)
            .opacity(isPulsating ? 0.7 : 1.0)
            .animation(
                Animation.spring(duration: 0.4)
                    .repeatForever(autoreverses: true),
                value: isPulsating
            )
            .onAppear {
                isPulsating = true
            }
    }
}

#Preview {
    CombinedPulseView(iconImage: "labresult")
    CombinedPulseView(iconImage: "labresult")
}
