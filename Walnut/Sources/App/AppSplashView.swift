//
//  AppSplashView.swift
//  Walnut
//
//  Created by Mayank Gandhi on 22/09/25.
//  Copyright © 2025 m. All rights reserved.
//

import SwiftUI
import WalnutDesignSystem

struct AppSplashView: View {
    @State private var isAnimating = false
    @State private var pulseScale: CGFloat = 1.0
    @State private var rotationAngle: Double = 0
    @State private var opacity: Double = 0
    @State private var textOffset: CGFloat = 50
    @State private var progressOpacity: Double = 0

    var body: some View {
        ZStack {
            // Animated background gradient
            AnimatedGradientBackground()

            // Floating particles
            FloatingParticles()

            VStack(spacing: 40) {
                // App Icon with animations
                VStack {
                    ZStack {
                        // Pulsing background circle
                        Circle()
                            .fill(
                                RadialGradient(
                                    colors: [
                                        Color.healthPrimary.opacity(0.3),
                                        Color.healthPrimary.opacity(0.1),
                                        Color.clear
                                    ],
                                    center: .center,
                                    startRadius: 30,
                                    endRadius: 120
                                )
                            )
                            .frame(width: 200, height: 200)
                            .scaleEffect(pulseScale)
                            .animation(
                                .easeInOut(duration: 2.0)
                                .repeatForever(autoreverses: true),
                                value: pulseScale
                            )

                        // App Icon with glow effect
                        Image("display-app-icon")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 100, height: 100)
                            .shadow(color: Color.healthPrimary.opacity(0.5), radius: 20, x: 0, y: 0)
                            .rotation3DEffect(
                                .degrees(rotationAngle),
                                axis: (x: 0, y: 1, z: 0)
                            )
                            .scaleEffect(isAnimating ? 1.05 : 0.95)
                            .animation(
                                .easeInOut(duration: 1.5)
                                .repeatForever(autoreverses: true),
                                value: isAnimating
                            )
                    }
                }
                .opacity(opacity)

                VStack(spacing: 24) {
                    // App Name with gradient text
                    Text("HealthStack")
                        .font(.system(size: 48, weight: .bold, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [
                                    Color.healthPrimary,
                                    Color.healthSuccess,
                                    Color.healthPrimary
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .offset(y: textOffset)
                        .opacity(opacity)

                    // Subtitle
                    Text("Healthcare Management")
                        .font(.title3.weight(.medium))
                        .foregroundStyle(.secondary)
                        .offset(y: textOffset)
                        .opacity(opacity * 0.8)

                    // Loading section
                    VStack(spacing: 16) {
                        // Custom loading animation
                        HStack(spacing: 8) {
                            ForEach(0..<3) { index in
                                Circle()
                                    .fill(Color.healthPrimary)
                                    .frame(width: 12, height: 12)
                                    .scaleEffect(isAnimating ? 1.2 : 0.8)
                                    .animation(
                                        .easeInOut(duration: 0.6)
                                        .repeatForever(autoreverses: true)
                                        .delay(Double(index) * 0.2),
                                        value: isAnimating
                                    )
                            }
                        }
                        .opacity(progressOpacity)

                        Text("Initializing your health journey...")
                            .font(.callout.weight(.medium))
                            .foregroundStyle(.secondary)
                            .opacity(progressOpacity)
                    }
                }
            }
            .padding(.horizontal, 40)
        }
        .onAppear {
            startAnimations()
        }
    }

    private func startAnimations() {
        // Staggered entrance animations
        withAnimation(.easeOut(duration: 1.0)) {
            opacity = 1.0
            textOffset = 0
        }

        withAnimation(.easeOut(duration: 1.0).delay(0.3)) {
            progressOpacity = 1.0
        }

        // Continuous animations
        withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
            pulseScale = 1.1
        }

        withAnimation(.linear(duration: 8.0).repeatForever(autoreverses: false)) {
            rotationAngle = 360
        }

        isAnimating = true
    }
}

// MARK: - Supporting Views

struct AnimatedGradientBackground: View {
    @State private var animateGradient = false

    var body: some View {
        LinearGradient(
            colors: [
                Color.healthPrimary.opacity(0.1),
                Color.healthSuccess.opacity(0.05),
                Color.healthPrimary.opacity(0.08),
                Color(.systemBackground)
            ],
            startPoint: animateGradient ? .topLeading : .bottomTrailing,
            endPoint: animateGradient ? .bottomTrailing : .topLeading
        )
        .ignoresSafeArea()
        .onAppear {
            withAnimation(.easeInOut(duration: 4.0).repeatForever(autoreverses: true)) {
                animateGradient.toggle()
            }
        }
    }
}

struct FloatingParticles: View {
    @State private var particleOffsets: [CGSize] = Array(repeating: CGSize.zero, count: 8)
    @State private var particleOpacities: [Double] = Array(repeating: 0.0, count: 8)

    var body: some View {
        ZStack {
            ForEach(0..<8, id: \.self) { index in
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.healthPrimary.opacity(0.3),
                                Color.healthSuccess.opacity(0.2)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: CGFloat.random(in: 20...40))
                    .offset(particleOffsets[index])
                    .opacity(particleOpacities[index])
                    .blur(radius: 1)
            }
        }
        .onAppear {
            animateParticles()
        }
    }

    private func animateParticles() {
        for index in 0..<8 {
            let randomDelay = Double.random(in: 0...2)
            let randomDuration = Double.random(in: 3...6)
            let randomX = CGFloat.random(in: -200...200)
            let randomY = CGFloat.random(in: -300...300)

            withAnimation(
                .easeInOut(duration: randomDuration)
                .repeatForever(autoreverses: true)
                .delay(randomDelay)
            ) {
                particleOffsets[index] = CGSize(width: randomX, height: randomY)
                particleOpacities[index] = Double.random(in: 0.1...0.4)
            }
        }
    }
}

#Preview {
    AppSplashView()
}
