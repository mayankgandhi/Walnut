//
//  HealthDashboard.swift
//  WalnutDesignSystem
//
//  Created by Mayank Gandhi on 06/08/25.
//  Copyright © 2025 m. All rights reserved.
//

import SwiftUI

/// Heart condition card (matching the design)
public struct HeartConditionCard: View {
    private let title: String
    private let bloodPressure: String
    private let heartRate: String
    private let chartData: [Double]
    
    public init(
        title: String = "My Heart Condition",
        bloodPressure: String,
        heartRate: String,
        chartData: [Double]
    ) {
        self.title = title
        self.bloodPressure = bloodPressure
        self.heartRate = heartRate
        self.chartData = chartData
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: Spacing.medium) {
            Text(title)
                .font(.headline.weight(.semibold))
                .foregroundStyle(.white)
            
            HStack(spacing: Spacing.large) {
                // Blood pressure
                VStack(alignment: .leading, spacing: Spacing.xs) {
                    HStack(spacing: Spacing.xs) {
                        Circle()
                            .fill(.white)
                            .frame(width: 8, height: 8)
                        
                        Text(bloodPressure)
                            .font(.title2.weight(.bold))
                            .foregroundStyle(.white)
                    }
                }
                
                // Heart rate indicator
                VStack(spacing: Spacing.xs) {
                    Circle()
                        .fill(.black)
                        .frame(width: 32, height: 32)
                        .overlay(
                            Text(heartRate)
                                .font(.caption.weight(.bold))
                                .foregroundStyle(.white)
                        )
                }
            }
            
            // Chart representation
            HStack(alignment: .bottom, spacing: 2) {
                ForEach(Array(chartData.enumerated()), id: \.offset) { index, value in
                    RoundedRectangle(cornerRadius: 1)
                        .fill(.white.opacity(0.7))
                        .frame(width: 3, height: max(4, value * 30))
                }
            }
            .frame(height: 40)
        }
        .padding(Spacing.medium)
        .background(
            Color.healthPrimary,
            in: RoundedRectangle(cornerRadius: 16)
        )
    }
}

/// Medical chart card (matching the personal card design)
public struct MedicalChartCard: View {
    private let patientName: String
    private let patientInfo: String
    private let testType: String
    private let value: String
    private let date: String
    private let chartData: [Double]
    
    public init(
        patientName: String,
        patientInfo: String,
        testType: String,
        value: String,
        date: String,
        chartData: [Double]
    ) {
        self.patientName = patientName
        self.patientInfo = patientInfo
        self.testType = testType
        self.value = value
        self.date = date
        self.chartData = chartData
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: Spacing.medium) {
            // Header
            HStack {
                Button(action: {}) {
                    Image(systemName: "arrow.left")
                        .font(.title3)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                Text("Personal Card")
                    .font(.headline.weight(.medium))
                    .foregroundStyle(.primary)
                
                Spacer()
                
                Button(action: {}) {
                    Image(systemName: "arrow.clockwise")
                        .font(.title3)
                        .foregroundStyle(.secondary)
                }
            }
            
            // Patient info
            HStack(spacing: Spacing.medium) {
                PatientAvatar(initials: "AW", size: Size.avatarMedium)
                
                VStack(alignment: .leading, spacing: Spacing.xs) {
                    Text(patientName)
                        .font(.headline.weight(.semibold))
                        .foregroundStyle(.primary)
                    
                    Text(patientInfo)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                Button(action: {}) {
                    Image(systemName: "ellipsis")
                        .font(.title3)
                        .foregroundStyle(.secondary)
                }
            }
            
            // Test results
            HStack {
                VStack(alignment: .leading, spacing: Spacing.xs) {
                    HStack(spacing: Spacing.xs) {
                        Image(systemName: "heart.fill")
                            .font(.caption)
                            .foregroundStyle(.red)
                        
                        Text(value)
                            .font(.title.weight(.bold))
                            .foregroundStyle(.primary)
                    }
                    
                    Text(testType)
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(.primary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: Spacing.xs) {
                    Circle()
                        .fill(.blue)
                        .frame(width: 12, height: 12)
                    
                    Text(date)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            
            // Chart
            HStack(alignment: .bottom, spacing: 3) {
                ForEach(Array(chartData.enumerated()), id: \.offset) { index, value in
                    RoundedRectangle(cornerRadius: 2)
                        .fill(.blue.opacity(0.7))
                        .frame(width: 6, height: max(8, value * 60))
                }
            }
            .frame(height: 80)
            
            // Lab results section
            VStack(alignment: .leading, spacing: Spacing.small) {
                Text("Lab Results")
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(.primary)
                
                HStack {
                    Text("O2")
                        .font(.caption.weight(.medium))
                        .foregroundStyle(.secondary)
                    
                    Spacer()
                    
                    Text("Check-up")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                HStack {
                    Text("schedule")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    
                    Spacer()
                    
                    Text("Next may")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(Spacing.small)
            .background(.blue.opacity(0.1), in: RoundedRectangle(cornerRadius: 8))
        }
        .padding(Spacing.medium)
        .cardStyle()
    }
}

/// Info card with icon (matching the "Do you know that" design)
public struct InfoCard: View {
    private let title: String
    private let subtitle: String
    private let buttonText: String
    private let backgroundColor: Color
    
    public init(
        title: String,
        subtitle: String,
        buttonText: String,
        backgroundColor: Color = .healthPrimary
    ) {
        self.title = title
        self.subtitle = subtitle
        self.buttonText = buttonText
        self.backgroundColor = backgroundColor
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: Spacing.large) {
            // Decorative elements
            HStack {
                Spacer()
                
                Image(systemName: "plus")
                    .font(.system(size: 40, weight: .light))
                    .foregroundStyle(.yellow)
                    .rotationEffect(.degrees(15))
            }
            
            Spacer()
            
            VStack(alignment: .leading, spacing: Spacing.medium) {
                Text(title)
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.leading)
                
                HealthButton(buttonText, style: .secondary) { }
            }
        }
        .padding(Spacing.medium)
        .frame(height: 200)
        .background(backgroundColor, in: RoundedRectangle(cornerRadius: 16))
    }
}
