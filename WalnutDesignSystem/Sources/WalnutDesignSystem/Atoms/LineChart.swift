//
//  LineChart.swift
//  WalnutDesignSystem
//
//  Created by Mayank Gandhi on 06/08/25.
//  Copyright © 2025 m. All rights reserved.
//

import SwiftUI

/// Line chart component (matching the monitoring chart)
public struct LineChart: View {
    private let data: [Double]
    private let color: Color
    private let showPoints: Bool
    
    public init(data: [Double], color: Color = .healthPrimary, showPoints: Bool = true) {
        self.data = data
        self.color = color
        self.showPoints = showPoints
    }
    
    public var body: some View {
        GeometryReader { geometry in
            let maxValue = data.max() ?? 1
            let minValue = data.min() ?? 0
            let range = maxValue - minValue
            let stepX = geometry.size.width / CGFloat(data.count - 1)
            
            ZStack {
                // Line path
                Path { path in
                    guard !data.isEmpty else { return }
                    
                    let firstPoint = CGPoint(
                        x: 0,
                        y: geometry.size.height * (1 - (data[0] - minValue) / range)
                    )
                    path.move(to: firstPoint)
                    
                    for (index, value) in data.enumerated().dropFirst() {
                        let point = CGPoint(
                            x: stepX * CGFloat(index),
                            y: geometry.size.height * (1 - (value - minValue) / range)
                        )
                        path.addLine(to: point)
                    }
                }
                .stroke(color, style: StrokeStyle(lineWidth: 2, lineCap: .round))
                
                // Data points
                if showPoints {
                    ForEach(Array(data.enumerated()), id: \.offset) { index, value in
                        Circle()
                            .fill(color)
                            .frame(width: 6, height: 6)
                            .position(
                                x: stepX * CGFloat(index),
                                y: geometry.size.height * (1 - (value - minValue) / range)
                            )
                    }
                }
                
                // Highlight current point
                if let lastValue = data.last {
                    Circle()
                        .fill(.orange)
                        .frame(width: 8, height: 8)
                        .position(
                            x: stepX * CGFloat(data.count - 1),
                            y: geometry.size.height * (1 - (lastValue - minValue) / range)
                        )
                }
            }
        }
        .frame(height: 80)
    }
}

#Preview {
    LineChart(data: [1,2,4,5,6,7,7], color: .accentColor, showPoints: true)
}
