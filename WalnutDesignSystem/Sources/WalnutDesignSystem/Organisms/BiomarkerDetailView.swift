//
//  BiomarkerDetailView.swift
//  WalnutDesignSystem
//
//  Created by Mayank Gandhi on 08/08/25.
//  Copyright © 2025 m. All rights reserved.
//

import SwiftUI
import Charts

/// Full-screen biomarker detail view with chart and metrics
public struct BiomarkerDetailView: View {
    private let data: [Double]
    private let color: Color
    private let biomarkerInfo: BiomarkerInfo
    private let biomarkerTrends: BiomarkerTrends
    
    public init(
        data: [Double],
        color: Color = .healthPrimary,
        biomarkerInfo: BiomarkerInfo,
        biomarkerTrends: BiomarkerTrends,
    ) {
        self.data = data
        self.color = color
        self.biomarkerInfo = biomarkerInfo
        self.biomarkerTrends = biomarkerTrends
    }
    
    public var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Blue gradient background
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 0.42, green: 0.45, blue: 1.0),
                        Color(red: 0.32, green: 0.35, blue: 0.85)
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Top section with comparison info
                    topComparisonSection
                    
                    Spacer()
                    
                    // Chart section
                    chartSection
                    
                    Spacer()
                    
                    // Bottom biomarker section
                    bottomBiomarkerSection
                }
            }
        }
    }
    
    private var topComparisonSection: some View {
        VStack(spacing: 4) {
            HStack {
                Text(biomarkerTrends.comparisonText)
                    .font(.title3)
                    .fontWeight(.medium)
                    .foregroundColor(.white.opacity(0.9))
                
                Spacer()
                
                Button(action: {}) {
                    Image(systemName: "trash")
                        .foregroundColor(.white.opacity(0.8))
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 60)
            
            HStack {
                Text("Change from last reading")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.7))
                
                Spacer()
            }
            .padding(.horizontal, 20)
            
            HStack {
                HStack(spacing: 4) {
                    Image(systemName: biomarkerTrends.trendDirection.iconName)
                        .foregroundColor(biomarkerTrends.trendDirection.color)
                        .font(.caption)
                    Text(biomarkerTrends.comparisonPercentage)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(biomarkerTrends.trendDirection.color)
                    Text("from previous week")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.7))
                }
                
                Spacer()
            }
            .padding(.horizontal, 20)
        }
    }
    
    private var chartSection: some View {
        chartView
            .padding(.horizontal, 20)
    }
    
    private var chartView: some View {
        Chart {
            ForEach(Array(data.enumerated()), id: \.offset) { index, value in
                let isToday = index == data.count - 1
                
                BarMark(
                    x: .value("Index", index),
                    y: .value("Value", value),
                    width: 30
                )
                .foregroundStyle(isToday ? .white.opacity(0.3) : Color.white.opacity(0.6))
                .cornerRadius(4)
            }
        }
        .chartXAxis(.hidden)
        .chartYAxis(.hidden)
        .chartBackground { _ in
            Color.clear
        }
        .chartLegend(content: {
            Text("Legend")
        })
        .chartLegend(.visible)
        .frame(height: 200)
    }
    
    private var bottomBiomarkerSection: some View {
        VStack(spacing: 0) {
            // Dark section background
            RoundedRectangle(cornerRadius: 30)
                .fill(Color.black)
                .overlay(
                    VStack(spacing: 20) {
                        // Toggle and biomarker value
                        VStack(spacing: 8) {
                            
                            
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(biomarkerTrends.currentValueText)
                                        .font(.system(size: 48, weight: .bold, design: .default))
                                        .foregroundColor(.white)
                                    Text(biomarkerInfo.name)
                                        .font(.title3)
                                        .foregroundColor(.gray)
                                }
                                Spacer()
                            }
                        }
                        
                        // Biomarker metrics row
                        HStack {
                            
                            MetricView(value: biomarkerTrends.normalRange, unit: "g/dL", label: "Normal Range")
                            Spacer()
                            MetricView(value: "Good", unit: "", label: "Status")
                            Spacer()
                            MetricView(value: "Weekly", unit: "", label: "Frequency")
                        }
                        
                        // Biomarker button
                        Button(action: {}) {
                            HStack {
                                Image(systemName: "heart.text.square")
                                    .foregroundColor(.black)
                                Text(biomarkerInfo.name)
                                    .foregroundColor(.black)
                                    .fontWeight(.semibold)
                            }
                            .padding(.horizontal, 40)
                            .padding(.vertical, 12)
                            .background(Color.white)
                            .clipShape(Capsule())
                        }
                    }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 30)
                )
                .ignoresSafeArea(edges: .bottom)
        }
        .frame(height: 280)
    }
}

#Preview {
    BiomarkerDetailView(
        data: [13.8, 12.5, 14.5, 14.1, 14.3, 13.8, 14.2],
        color: .healthPrimary,
        biomarkerInfo: BiomarkerInfo(
            name: "Hemoglobin",
            description: "Hemoglobin carries oxygen in red blood cells",
            normalRange: "12.0-15.5",
            unit: "g/dL"
        ),
        biomarkerTrends: BiomarkerTrends(
            currentValue: 14.2,
            currentValueText: "14.2",
            comparisonText: "0.4 g/dL",
            comparisonPercentage: "3%",
            trendDirection: .up,
            normalRange: "12.0-15.5"
        )
    )
    .ignoresSafeArea()
}
