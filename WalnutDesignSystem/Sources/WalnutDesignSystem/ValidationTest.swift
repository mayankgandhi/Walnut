//
//  ValidationTest.swift
//  WalnutDesignSystem
//
//  Created by Mayank Gandhi on 06/08/25.
//  Copyright © 2025 m. All rights reserved.
//

import SwiftUI

/// Validation test to ensure all components compile and work together
struct ValidationTest: View {
    var body: some View {
        ScrollView {
            VStack(spacing: Spacing.medium) {
                // Test all atomic components
                DSButton("Test Button", style: .primary) {}
                
                PatientAvatar(name: "JD", size: Size.avatarMedium)
                            
                
                DSItemCard(
                    name: "Test Food",
                    calories: "250",
                    details: "Test details",
                    color: .cyan
                )
                
                MenuListItem(
                    icon: "heart.fill",
                    title: "Test Menu Item",
                    iconColor: .healthPrimary
                )
              
                SuccessNotification(
                    timestamp: "Now",
                    value: "5.0",
                    unit: "mmol/L",
                    status: "Perfect!"
                )
                
                
                // Test molecules
                HealthDashboard()
                    .frame(height: 400)
                
                // Test colors
                HStack {
                    Rectangle().fill(Color.healthPrimary).frame(width: 50, height: 50)
                    Rectangle().fill(Color.healthSuccess).frame(width: 50, height: 50)
                    Rectangle().fill(Color.healthWarning).frame(width: 50, height: 50)
                    Rectangle().fill(Color.healthError).frame(width: 50, height: 50)
                }
            }
            .padding()
        }
    }
}

#Preview {
    ValidationTest()
}
