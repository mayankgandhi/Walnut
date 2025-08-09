//
//  AppRootView.swift
//  Atlas
//
//  Created by Mayank Gandhi on 09/08/25.
//  Copyright © 2025 m. All rights reserved.
//

import SwiftUI

struct AppRootView: View {
    @State private var showLaunchScreen = true
    @State private var launchScreenOpacity: Double = 1.0
    
    var body: some View {
        ZStack {
            // Main App Content
            ContentView()
                .opacity(showLaunchScreen ? 0 : 1)
            
            // Launch Screen Overlay
            if showLaunchScreen {
                LaunchScreen()
                    .opacity(launchScreenOpacity)
                    .onAppear {
                        // Start the transition after launch screen animations complete
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                            withAnimation(.easeOut(duration: 0.8)) {
                                launchScreenOpacity = 0.0
                            }
                            
                            // Remove launch screen from view hierarchy after fade out
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                                showLaunchScreen = false
                            }
                        }
                    }
            }
        }
        .animation(.easeInOut(duration: 0.5), value: showLaunchScreen)
    }
}

#Preview {
    AppRootView()
}
