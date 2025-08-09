//
//  LaunchScreen.swift
//  Atlas
//
//  Created by Mayank Gandhi on 09/08/25.
//  Copyright © 2025 m. All rights reserved.
//

import SwiftUI

struct LaunchScreen: View {
    @State private var logoScale: CGFloat = 0.5
    @State private var logoOpacity: Double = 0.0
    @State private var titleOffset: CGFloat = 50
    @State private var titleOpacity: Double = 0.0
    @State private var backgroundGradientOpacity: Double = 0.0
    @State private var pulseAnimation = false
    
    var body: some View {
        ZStack {
            // Gradient Background
            LinearGradient(
                colors: [
                    Color.blue.opacity(0.8),
                    Color.blue.opacity(0.6),
                    Color.white
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .opacity(backgroundGradientOpacity)
            .ignoresSafeArea()
            
            VStack(spacing: 30) {
                // Logo/Icon
                ZStack {
                    // Pulsing ring effect
                    Circle()
                        .stroke(Color.blue.opacity(0.3), lineWidth: 2)
                        .scaleEffect(pulseAnimation ? 1.2 : 1.0)
                        .opacity(pulseAnimation ? 0 : 1)
                    
                    // Main logo circle
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color.blue, Color.blue.opacity(0.8)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 120, height: 120)
                        .overlay {
                            // Atlas "A" symbol
                            Text("A")
                                .font(.system(size: 60, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                        }
                        .shadow(color: .blue.opacity(0.3), radius: 10, x: 0, y: 5)
                }
                .scaleEffect(logoScale)
                .opacity(logoOpacity)
                
                // App Title
                VStack(spacing: 8) {
                    Text("ATLAS")
                        .font(.system(size: 42, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                        .tracking(4)
                    
                    Text("Healthcare Management")
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundColor(.secondary)
                        .tracking(1)
                }
                .offset(y: titleOffset)
                .opacity(titleOpacity)
            }
        }
        .onAppear {
            startAnimationSequence()
        }
    }
    
    private func startAnimationSequence() {
        // Background gradient fade in
        withAnimation(.easeIn(duration: 0.8)) {
            backgroundGradientOpacity = 1.0
        }
        
        // Logo scale and fade in
        withAnimation(.spring(response: 1.2, dampingFraction: 0.6, blendDuration: 0).delay(0.3)) {
            logoScale = 1.0
            logoOpacity = 1.0
        }
        
        // Title slide up and fade in
        withAnimation(.easeOut(duration: 0.8).delay(0.8)) {
            titleOffset = 0
            titleOpacity = 1.0
        }
        
        // Start pulsing animation for the ring
        withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: false).delay(1.5)) {
            pulseAnimation = true
        }
    }
}

#Preview {
    LaunchScreen()
}